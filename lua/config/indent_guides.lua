-- ネストの背景色ガイド（自作）
-- インデント幅を「深さごとに虹色の背景ブロック」で塗る。縦線（│）ではなく面で表現するため、
-- コード中の | と見間違えない。indent-blankline の代替として editor.lua から外し、こちらを使う。
--
-- 仕組み: 表示中のウィンドウの可視行だけを走査し、各インデント段（shiftwidth 幅）に
-- overlay の仮想テキスト（空白 + 背景ハイライト）を virt_text_win_col で固定列に置く。
-- 空行はネストが途切れないよう、上下の非空行のインデントから深さを補完する。

local M = {}

local ns = vim.api.nvim_create_namespace("indent_bg_guides")

-- 深さごとの色（隣り合う段が見分けやすい順に並べる）。背景に薄く混ぜて使う。
local rainbow = {
  "#89b4fa", -- blue
  "#cba6f7", -- mauve
  "#f38ba8", -- red
  "#fab387", -- peach
  "#f9e2af", -- yellow
  "#a6e3a1", -- green
  "#94e2d5", -- teal
}
local NUM = #rainbow
local hl_names = {}

-- ガイドを描かない filetype（buftype ~= "" は別途弾くので、通常バッファの例外だけ列挙）
local SKIP_FT = {
  ["neo-tree"] = true,
  aerial = true,
  Trouble = true,
  dashboard = true,
  alpha = true,
  lazy = true,
  mason = true,
  help = true,
  csv = true,
}

local function hex(n)
  return string.format("#%06x", n)
end

-- fg を bg に alpha の割合で混ぜる（0..1、大きいほど色が濃い）
local function blend(fg, bg, alpha)
  local fr, fgc, fb = tonumber(fg:sub(2, 3), 16), tonumber(fg:sub(4, 5), 16), tonumber(fg:sub(6, 7), 16)
  local br, bgc, bb = tonumber(bg:sub(2, 3), 16), tonumber(bg:sub(4, 5), 16), tonumber(bg:sub(6, 7), 16)
  local r = math.floor(fr * alpha + br * (1 - alpha) + 0.5)
  local g = math.floor(fgc * alpha + bgc * (1 - alpha) + 0.5)
  local b = math.floor(fb * alpha + bb * (1 - alpha) + 0.5)
  return string.format("#%02x%02x%02x", r, g, b)
end

-- 背景ハイライト群を（再）生成。透過で Normal 背景が無いときは暗いベースを仮定する。
local function setup_highlights()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local base = normal.bg and hex(normal.bg) or "#1e1e2e"
  for i = 1, NUM do
    local name = "IndentGuideBg" .. i
    hl_names[i] = name
    vim.api.nvim_set_hl(0, name, { bg = blend(rainbow[i], base, 0.18) })
  end
end

-- 行の先頭空白を桁数で返す（タブは tabstop 展開）。空行・空白のみの行は -1。
local function indent_of(line, ts)
  local w = 0
  for i = 1, #line do
    local c = line:byte(i)
    if c == 32 then -- space
      w = w + 1
    elseif c == 9 then -- tab
      w = w + (ts - (w % ts))
    else
      return w
    end
  end
  return -1
end

local function eligible(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  if vim.bo[buf].buftype ~= "" then
    return false
  end
  if SKIP_FT[vim.bo[buf].filetype] then
    return false
  end
  return true
end

local function render_win(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if not eligible(buf) then
    return
  end

  local sw = vim.bo[buf].shiftwidth
  local ts = vim.bo[buf].tabstop
  if ts == 0 then ts = 8 end
  if sw == 0 then sw = ts end

  local top = vim.fn.line("w0", win)
  local bot = vim.fn.line("w$", win)
  if top <= 0 or bot <= 0 then
    return
  end

  -- 空行の深さ補完のため、上下に少し余分を取って取得する
  local s = math.max(1, top - 2)
  local e = bot + 2
  local lines = vim.api.nvim_buf_get_lines(buf, s - 1, e, false)

  local ind = {}
  for i, l in ipairs(lines) do
    ind[i] = indent_of(l, ts)
  end

  -- 配列インデックス i の「実効インデント」。空行は最も近い上下の非空行の深い方に合わせる。
  local function eff(i)
    if ind[i] and ind[i] >= 0 then
      return ind[i]
    end
    local up, down
    for j = i - 1, 1, -1 do
      if ind[j] and ind[j] >= 0 then up = ind[j]; break end
    end
    for j = i + 1, #ind do
      if ind[j] and ind[j] >= 0 then down = ind[j]; break end
    end
    if up and down then return math.max(up, down) end
    return up or down or 0
  end

  for lnum = top, bot do
    local w = eff(lnum - s + 1)
    if w > 0 then
      local depth = math.floor(w / sw)
      for d = 0, depth - 1 do
        local grp = hl_names[(d % NUM) + 1]
        pcall(vim.api.nvim_buf_set_extmark, buf, ns, lnum - 1, 0, {
          virt_text = { { string.rep(" ", sw), grp } },
          virt_text_win_col = d * sw,
          hl_mode = "combine",
          priority = 1, -- 診断・検索ハイライトより下に
        })
      end
    end
  end
end

-- 現在のタブページの全ウィンドウを再描画（バッファ単位でクリアは一度だけ）
function M.refresh()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local cleared = {}
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    if eligible(buf) and not cleared[buf] then
      cleared[buf] = true
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    end
  end
  for _, win in ipairs(wins) do
    render_win(win)
  end
end

-- 連続発火するイベントを 1 tick にまとめる
local pending = false
local function schedule_refresh()
  if pending then
    return
  end
  pending = true
  vim.schedule(function()
    pending = false
    if M.enabled then
      M.refresh()
    end
  end)
end

function M.enable()
  M.enabled = true
  setup_highlights()
  schedule_refresh()
end

function M.disable()
  M.enabled = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    end
  end
end

function M.toggle()
  if M.enabled then
    M.disable()
  else
    M.enable()
  end
  vim.notify("ネスト背景ガイド: " .. (M.enabled and "オン" or "オフ"), vim.log.levels.INFO)
end

function M.setup()
  -- デフォルトは OFF（起動時は塗らない）。<leader>ug で必要なときだけ有効化する。
  -- autocmd は登録しておくが、コールバックは M.enabled を見て無効時は描画しない。
  M.enabled = false
  setup_highlights()

  local grp = vim.api.nvim_create_augroup("IndentBgGuides", { clear = true })
  vim.api.nvim_create_autocmd({
    "WinScrolled", "WinResized", "TextChanged", "TextChangedI",
    "InsertLeave", "BufWinEnter", "WinEnter", "FileType",
  }, {
    group = grp,
    callback = schedule_refresh,
  })
  -- カラースキーム変更で背景色が変わるので色を作り直してから再描画
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = grp,
    callback = function()
      vim.schedule(function()
        setup_highlights()
        if M.enabled then
          M.refresh()
        end
      end)
    end,
  })

  vim.api.nvim_create_user_command("IndentGuidesToggle", M.toggle, {})
  vim.keymap.set("n", "<leader>ug", M.toggle, { desc = "UI: Indent guides toggle (ネスト背景)" })

  schedule_refresh()
end

return M
