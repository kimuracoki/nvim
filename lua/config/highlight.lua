-- 透過（背景を抜く）設定の一元管理。ColorScheme のたびに init.lua から呼び直される。

local M = {}

-- 透過のオン/オフ（true: 透過, false: 不透過）
M.enabled = true

-- 背景だけを透過にする。
--
-- 【なぜ get してから set し直すのか】
-- nvim_set_hl はハイライト定義を「置換」する。`{ bg = "none" }` だけを渡すと、そのグループの
-- fg も attribute も一緒に消える。実測（本設定・catppuccin）: Normal / LineNr / StatusLine /
-- TabLine / SignColumn / NormalFloat がいずれも空定義になり、
--   - 行番号やステータスラインがテーマの色を失って端末既定色で描かれる
--   - Normal の fg を読むプラグインが nil を掴む（snacks.gh は require 時に落ちる。
--     :checkhealth snacks が "attempt to index local 'fg'" で失敗していた）
-- という状態になっていた。既存の定義を読み出し、背景（bg / ctermbg）だけを外す。
local function clear_bg(group, extra)
  local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
  hl.bg, hl.ctermbg = nil, nil
  if extra then
    hl = vim.tbl_extend("force", hl, extra)
  end
  vim.api.nvim_set_hl(0, group, hl)
end

-- 背景を抜くグループ
local transparent_groups = {
  -- 本体
  "Normal", "NormalNC", "SignColumn", "LineNr",
  -- フロート（枠色 FloatBorder の fg はテーマのものを保つ）
  "NormalFloat", "FloatBorder",
  -- ステータスライン・タブライン
  "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel",
  -- neo-tree（ファイラ）
  "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer",
  "NeoTreeTabActive", "NeoTreeTabInactive",
  -- trouble（問題パネル）
  "TroubleNormal", "TroubleNormalNC",
}

-- 区切り線は背景だけでなく線自体も消す（fg も none）
local invisible_groups = { "WinSeparator", "NeoTreeWinSeparator" }

function M.setup()
  if not M.enabled then
    return
  end
  for _, group in ipairs(transparent_groups) do
    clear_bg(group)
  end
  for _, group in ipairs(invisible_groups) do
    clear_bg(group, { fg = "none" })
  end
end

-- 透過オン/オフをトグル
function M.toggle_transparency()
  M.enabled = not M.enabled

  if M.enabled then
    M.setup()
  else
    -- 透過を無効化：カラースキームを再適用してデフォルトに戻す
    local colorscheme = vim.g.current_colorscheme or vim.g.colors_name
    if colorscheme then
      vim.cmd("colorscheme " .. colorscheme)
    end
  end

  -- GitGraph のハイライトを再適用（カラースキーム再適用で失われるため）
  if _G.setup_gitgraph_highlights then
    _G.setup_gitgraph_highlights()
  end

  vim.notify("透過: " .. (M.enabled and "有効" or "無効"), vim.log.levels.INFO)
end

return M
