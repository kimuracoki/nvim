-- 通知ログ（<leader>hm / :MessageLog）
--
-- 画面に一瞬出て消える通知を「後から読める・コピーできる」状態で残すための仕組み。
-- noice の view_history だけだと取りこぼしがあった（noice を経由しない通知や、
-- noice のロード前に出たもの、フロート表示のまま消えるものは履歴に入らない）。
-- そこで vim.notify 自体を包んで全部リングバッファに溜め、通常バッファに出して yank できるようにする。
local M = {}

local MAX = 500 -- 保持する件数（古いものから捨てる）
M.entries = {}

local level_name = {
  [vim.log.levels.TRACE] = "TRACE",
  [vim.log.levels.DEBUG] = "DEBUG",
  [vim.log.levels.INFO] = "INFO",
  [vim.log.levels.WARN] = "WARN",
  [vim.log.levels.ERROR] = "ERROR",
}

local function record(msg, level, opts)
  local text
  if type(msg) == "string" then
    text = msg
  elseif type(msg) == "table" then
    text = table.concat(vim.tbl_map(tostring, msg), " ")
  else
    text = tostring(msg)
  end
  -- 同じ内容が同じ時刻に続けて入るのは二重計上（notify の実装が内部で echo を呼ぶ等）なので捨てる
  local last = M.entries[#M.entries]
  local now = os.date("%H:%M:%S")
  if last and last.text == text and last.time == now then
    return
  end

  M.entries[#M.entries + 1] = {
    time = now,
    level = level_name[level] or "INFO",
    title = type(opts) == "table" and opts.title or nil,
    text = text,
  }
  if #M.entries > MAX then
    table.remove(M.entries, 1)
  end
end

-- 通知の出口を包む。noice などが後から差し替えるので、起動後にもう一度呼んで包み直す
-- （二重ラップは同一性チェックで防ぐ）。
--
-- vim.notify だけでは足りない: プラグインによっては vim.print や nvim_echo で出してくる。
-- 実際 kulala は GUI 判定（has("gui_running")）で分岐して端末では vim.print を使っており、
-- grammar 取得エラーがどの通知履歴にも残らなかった。両方とも捕まえる。
--
-- 【重要】noice のロード後は vim.notify を包み直さない。noice はヘルスチェックで
-- 「vim.notify が自分のハンドラのままか」を見ており、包み直すと
-- "`vim.notify` has been overwritten by another plugin?" を毎回エラー通知してくる
-- （しかもそれが右上トーストで出る）。noice 到達後の通知は noice 自身が履歴を持っているので、
-- 表示時に noice の履歴（M.noice_history）を取り込む方式にする。
function M.wrap()
  -- noice がまだ vim.notify を握っていない起動直後だけ包む
  if not M._noice_taken and vim.notify ~= M._wrapped then
    local prev = vim.notify
    M._wrapped = function(msg, level, opts)
      pcall(record, msg, level, opts)
      return prev(msg, level, opts)
    end
    vim.notify = M._wrapped
  end

  if vim.print ~= M._wrapped_print then
    local prev_print = vim.print
    M._wrapped_print = function(...)
      local args = { ... }
      pcall(function()
        local parts = {}
        for _, a in ipairs(args) do
          parts[#parts + 1] = type(a) == "string" and a or vim.inspect(a)
        end
        if #parts > 0 then
          record(table.concat(parts, " "), vim.log.levels.INFO, { title = "print" })
        end
      end)
      return prev_print(...)
    end
    vim.print = M._wrapped_print
  end

  if vim.api.nvim_echo ~= M._wrapped_echo then
    local prev_echo = vim.api.nvim_echo
    M._wrapped_echo = function(chunks, history, opts)
      pcall(function()
        local parts = {}
        for _, c in ipairs(chunks or {}) do
          parts[#parts + 1] = tostring(c[1])
        end
        local text = table.concat(parts)
        if text:match("%S") then
          record(text, vim.log.levels.INFO, { title = "echo" })
        end
      end)
      return prev_echo(chunks, history, opts)
    end
    vim.api.nvim_echo = M._wrapped_echo
  end
end

-- noice が持っている履歴を取り出す（noice 到達後の通知はこちらに入る）。
-- 内部 API なので、取れなければ黙って空を返す。
local function noice_history()
  local out = {}
  if not package.loaded["noice"] then
    return out
  end
  local ok, manager = pcall(require, "noice.message.manager")
  if not ok then
    return out
  end
  local ok2, messages = pcall(manager.get, nil, { history = true, sort = true })
  if not ok2 or type(messages) ~= "table" then
    return out
  end
  for _, msg in ipairs(messages) do
    local ok3, content = pcall(function()
      return msg:content()
    end)
    if ok3 and type(content) == "string" and content:match("%S") then
      out[#out + 1] = {
        level = (msg.level and tostring(msg.level):upper()) or "INFO",
        title = "noice",
        text = content,
      }
    end
  end
  return out
end

-- ログを通常バッファ（yank 可能）で開く。
-- 自前の通知ログ（print / echo / 起動直後の notify）+ noice の履歴 + :messages をまとめる。
function M.open()
  local lines = {
    "── 通知ログ（新しい順・yy / V で選択してコピー可・q で閉じる） ──",
    "",
  }
  if #M.entries == 0 then
    lines[#lines + 1] = "  (通知はまだありません)"
  else
    for i = #M.entries, 1, -1 do
      local e = M.entries[i]
      local head = ("[%s] %s%s: "):format(e.time, e.level, e.title and (" " .. e.title) or "")
      local first = true
      for _, l in ipairs(vim.split(e.text, "\n", { plain = true })) do
        lines[#lines + 1] = first and (head .. l) or (string.rep(" ", 4) .. l)
        first = false
      end
    end
  end

  local nh = noice_history()
  if #nh > 0 then
    lines[#lines + 1] = ""
    lines[#lines + 1] = "── noice の履歴（新しい順） ──"
    lines[#lines + 1] = ""
    for i = #nh, 1, -1 do
      local e = nh[i]
      local first = true
      for _, l in ipairs(vim.split(e.text, "\n", { plain = true })) do
        if l:match("%S") then
          lines[#lines + 1] = first and ("[noice] " .. l) or (string.rep(" ", 4) .. l)
          first = false
        end
      end
    end
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = "── :messages（Vim 本体のメッセージ履歴） ──"
  lines[#lines + 1] = ""
  local ok, msgs = pcall(vim.fn.execute, "messages")
  if ok and msgs and msgs ~= "" then
    for _, l in ipairs(vim.split(msgs, "\n", { plain = true })) do
      if l ~= "" then
        lines[#lines + 1] = l
      end
    end
  else
    lines[#lines + 1] = "  (なし)"
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_set_name(buf, "MessageLog")

  vim.cmd("botright split")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_win_set_height(win, math.min(20, math.max(10, math.floor(vim.o.lines * 0.4))))
  vim.wo[win].wrap = true
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false

  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true, desc = "閉じる" })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, nowait = true, desc = "閉じる" })
  return buf
end

function M.setup()
  M.wrap()

  -- noice が vim.notify を持っていったら、こちらは手を引く（上の説明を参照）。
  -- vim.print / nvim_echo のラップは noice と競合しないのでそのまま残す。
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      vim.defer_fn(function()
        M._noice_taken = package.loaded["noice"] ~= nil and vim.notify ~= M._wrapped
        M.wrap() -- notify は noice が持っていれば触らない。print / echo は張り直す
      end, 200)
    end,
    desc = "Stop wrapping vim.notify once noice owns it",
  })

  vim.api.nvim_create_user_command("MessageLog", M.open, { desc = "通知と :messages をコピー可能なバッファで開く" })
end

return M
