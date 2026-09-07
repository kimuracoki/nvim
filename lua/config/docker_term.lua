-- コンテナ用の端末ウィンドウ（フロート / 専用タブの全画面）を開く。
--
-- 【なぜ toggleterm 越しか】terminal.lua の lazygit と同じ土台に乗せることで、
-- Esc やウィンドウ移動の扱い・フロートの枠を既存の端末と揃えられる。
--
-- 【全画面タブの狙い】コンテナの中で Neovim を動かすとき（config/docker_nvim.lua）は、
-- 外側の飾り（タブライン・ステータスライン・winbar）とタブに紛れ込む他のウィンドウを畳んで、
-- 画面をコンテナ側に明け渡す。VSCode の Reopen in Container がウィンドウごと切り替わるのに合わせる。
--
-- 【この実装で踏んだ地雷】
--   1. バッファを先に消すと、表示に回せる通常バッファが無いとき Neovim が空バッファを
--      割り当て、タブ（やフロート）が残る。必ず「ウィンドウ/タブを閉じてからバッファ削除」。
--   2. 割り込みウィンドウの掃除を WinEnter / BufWinEnter に張ると、閉じる → 再発火 → 閉じる
--      の往復で Neovim ごと固まる。掃除は一度きり、枠の切り替えは TabEnter だけに限定する。
local M = {}

-- key -> Terminal。同じ用途のキーを押し直したとき、セッションを増やさず前の画面に戻れるようにする
local terms = {}

-- 在席インジケータの色。透過設定（config/highlight.lua）は透過が有効なときしか走らないので
-- あちらには置けない。テーマを変えても消えないよう、開くたびに定義し直す
local INDICATOR_HL = "DockerContainerBar"

---外側の飾りを畳む／戻す組を作る（畳む前の値を覚えておく）
local function chrome()
  local saved
  return {
    hide = function()
      saved = saved or { showtabline = vim.o.showtabline, laststatus = vim.o.laststatus }
      vim.o.showtabline = 0
      vim.o.laststatus = 0
    end,
    restore = function()
      if not saved then
        return
      end
      vim.o.showtabline = saved.showtabline
      vim.o.laststatus = saved.laststatus
      saved = nil
    end,
  }
end

---端末ウィンドウの見た目を整える。行番号などを消し、上端に「今どこに居るか」を出す
local function decorate(bufnr, indicator)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
      vim.wo[win].winbar = indicator or ""
      vim.wo[win].number = false
      vim.wo[win].relativenumber = false
      vim.wo[win].signcolumn = "no"
    end
  end
end

---専用タブから割り込みウィンドウ（neo-tree など）を追い出す。
---※ WinEnter / BufWinEnter からは呼ばないこと（上のコメント 2 を参照）。
---   呼んでよいのは WinNew（ウィンドウが「増えた」ときだけ飛び、閉じても飛ばない）と一度きりの defer。
local function claim_tab(state, bufnr, indicator)
  if state.claiming then
    return -- 念のための再入防止
  end
  state.claiming = true
  local tab = state.tabpage
  local ok = tab and vim.api.nvim_tabpage_is_valid(tab) and vim.api.nvim_buf_is_valid(bufnr)
  if ok then
    local wins = vim.api.nvim_tabpage_list_wins(tab)
    local has_ours = false
    for _, w in ipairs(wins) do
      if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_buf(w) == bufnr then
        has_ours = true
        break
      end
    end
    -- このタブに端末が居ないなら、もう専用タブではないので何もしない
    if has_ours then
      for _, w in ipairs(wins) do
        if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_buf(w) ~= bufnr then
          pcall(vim.api.nvim_win_close, w, true)
        end
      end
      decorate(bufnr, indicator)
    end
  end
  state.claiming = false
end

---ホスト側のターミナルマッピングを外し、キーを中の Neovim へ素通しする。
---外側が食ってしまうと、中の nvim に Esc も C-hjkl もリーダーキーも届かない。
---特に <leader>w*（Space 始まり）が残ると、Space を押すたび外側が 300ms 待ち受けて固まって見える。
local function passthrough_keys(bufnr)
  vim.b[bufnr].nested_nvim = true
  -- TermOpen はこのフラグより先に走っているので、既に張られたローカルマップを剥がす
  for _, lhs in ipairs(vim.g.term_window_keys or {}) do
    pcall(vim.keymap.del, "t", lhs, { buffer = bufnr })
  end
  pcall(vim.keymap.del, "t", "jk", { buffer = bufnr })
  -- toggleterm の open_mapping（<C-\>）はグローバルで消せないので、同じ長さのローカルマップで
  -- 上書きしてそのまま送る（中の nvim で <C-\><C-n> を効かせるため）
  vim.keymap.set("t", "<C-\\>", "<C-\\>", {
    buffer = bufnr,
    noremap = true,
    desc = "Terminal: Pass key to nested Neovim (コンテナ内 nvim へ透過)",
  })
end

---プロセス終了後の後始末。順序が重要（先にウィンドウ/タブ、最後にバッファ）
local function close_terminal(state, term, key)
  terms[key] = nil
  if state.group then
    pcall(vim.api.nvim_del_augroup_by_id, state.group)
    state.group = nil
  end
  if state.chrome then
    state.chrome.restore()
  end

  -- 専用タブは、中身が何に差し替わっていても開いた側が畳む
  if state.tabpage and vim.api.nvim_tabpage_is_valid(state.tabpage) and #vim.api.nvim_list_tabpages() > 1 then
    pcall(vim.cmd, vim.api.nvim_tabpage_get_number(state.tabpage) .. "tabclose")
    state.tabpage = nil
  end

  -- フロートなど、まだ端末を映しているウィンドウを閉じる
  local bufnr = term.bufnr
  if vim.api.nvim_buf_is_valid(bufnr) then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
        local only_window = #vim.api.nvim_tabpage_list_wins(vim.api.nvim_win_get_tabpage(win)) == 1
        local more_tabs = #vim.api.nvim_list_tabpages() > 1
        -- 最後のタブの最後のウィンドウは閉じられない（Neovim が拒否する）
        if not (only_window and not more_tabs) then
          pcall(vim.api.nvim_win_close, win, true)
        end
      end
    end
  end
  if term:is_open() then
    pcall(function()
      term:close()
    end)
  end
  if vim.api.nvim_buf_is_valid(bufnr) then
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  end
end

---全画面表示（専用タブ）のための設定を仕込む
local function setup_fullscreen(state, bufnr, opts)
  state.chrome = chrome()
  vim.api.nvim_set_hl(0, INDICATOR_HL, { fg = "#1e1e2e", bg = "#89b4fa", bold = true })

  local group = vim.api.nvim_create_augroup("DockerTerm" .. bufnr, { clear = true })
  state.group = group

  if state.tabpage then
    -- 枠の切り替えはタブを跨いだときだけ。ウィンドウ移動には反応させない
    vim.api.nvim_create_autocmd("TabEnter", {
      group = group,
      callback = function()
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return true -- 端末が消えたらこの autocmd 自体を捨てる
        end
        if vim.api.nvim_get_current_tabpage() == state.tabpage then
          state.chrome.hide()
          decorate(bufnr, opts.indicator)
        else
          state.chrome.restore()
        end
      end,
    })
    -- 割り込みウィンドウの掃除は WinNew だけに紐づける。
    -- WinNew は「ウィンドウが増えたとき」にしか飛ばず、閉じたときは WinClosed なので、
    -- 閉じる → 再発火 → 閉じる の往復（＝フリーズ）が起きない。
    vim.api.nvim_create_autocmd("WinNew", {
      group = group,
      callback = function()
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return true -- 端末が消えたらこの autocmd 自体を捨てる
        end
        if vim.api.nvim_get_current_tabpage() ~= state.tabpage then
          return
        end
        -- WinNew の時点ではバッファが未確定なことがあるので 1 tick 遅らせる
        vim.schedule(function()
          claim_tab(state, bufnr, opts.indicator)
        end)
      end,
    })
    -- 開いた直後に既に割り込んでいる分（タブ生成と同時に開く neo-tree など）も掃除する
    vim.defer_fn(function()
      claim_tab(state, bufnr, opts.indicator)
    end, 200)
  else
    vim.api.nvim_create_autocmd({ "BufEnter", "TermEnter" }, {
      group = group,
      buffer = bufnr,
      callback = state.chrome.hide,
    })
    vim.api.nvim_create_autocmd("BufLeave", { group = group, buffer = bufnr, callback = state.chrome.restore })
  end
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = bufnr,
    once = true,
    callback = state.chrome.restore,
  })

  decorate(bufnr, opts.indicator)
  state.chrome.hide()
end

---端末を 1 枚開く。同じ key なら前のセッションに戻る。
---@param key string 再利用キー（"shell:<id>" など）
---@param cmd string シェルに渡すコマンド行
---@param opts? { on_exit?: fun(code:integer), keep_on_error?: boolean, nested?: boolean, direction?: string, fullscreen?: boolean, display_name?: string, indicator?: string }
function M.open(key, cmd, opts)
  opts = opts or {}
  local cached = terms[key]
  if cached and cached.bufnr and vim.api.nvim_buf_is_valid(cached.bufnr) then
    cached:toggle()
    return cached
  end

  local Terminal = require("toggleterm.terminal").Terminal
  local direction = opts.direction or "float"
  local state = {}
  local exit_code = 0
  local term

  term = Terminal:new({
    cmd = cmd,
    display_name = opts.display_name, -- フロートの枠に出る名前
    direction = direction,
    hidden = true, -- <c-\>（通常ターミナルのトグル）の巡回対象に混ぜない
    close_on_exit = false, -- 後始末の順序を自分で決めるため toggleterm には任せない
    float_opts = {
      border = "rounded",
      title_pos = "center",
      width = function()
        return math.floor(vim.o.columns * 0.9)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.9)
      end,
    },
    on_open = function(t)
      vim.cmd("startinsert!")
      if direction == "tab" then
        state.tabpage = vim.api.nvim_get_current_tabpage()
      end
      if opts.fullscreen then
        setup_fullscreen(state, t.bufnr, opts)
      end
      if opts.nested then
        passthrough_keys(t.bufnr)
      end
      vim.api.nvim_create_autocmd("TermClose", {
        buffer = t.bufnr,
        once = true,
        callback = function()
          vim.schedule(function()
            -- 失敗したビルドログなどは読めるように残す
            if opts.keep_on_error and exit_code ~= 0 then
              return
            end
            close_terminal(state, t, key)
          end)
        end,
      })
    end,
    on_exit = function(_, _, code)
      exit_code = code or 0
      if opts.on_exit then
        vim.schedule(function()
          opts.on_exit(exit_code)
        end)
      end
    end,
  })

  terms[key] = term
  term:open()
  return term
end

return M
