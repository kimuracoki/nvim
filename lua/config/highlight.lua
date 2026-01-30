local M = {}

-- 透過のオン/オフ（true: 透過, false: 不透過）
M.enabled = M.enabled ~= nil and M.enabled or true

-- 透過設定を適用
function M.setup()
  if not M.enabled then
    return
  end

  -- 背景だけ透過（元のシンプルな挙動）
  vim.api.nvim_set_hl(0, "Normal",     { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalNC",   { bg = "none" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
  vim.api.nvim_set_hl(0, "LineNr",     { bg = "none" })

  -- neo-treeの透過
  vim.api.nvim_set_hl(0, "NeoTreeNormal",        { bg = "none" })
  vim.api.nvim_set_hl(0, "NeoTreeNormalNC",      { bg = "none" })
  vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer",   { bg = "none" })
  vim.api.nvim_set_hl(0, "NeoTreeWinSeparator",  { bg = "none", fg = "none" })
  vim.api.nvim_set_hl(0, "NeoTreeTabActive",     { bg = "none" })
  vim.api.nvim_set_hl(0, "NeoTreeTabInactive",   { bg = "none" })
  vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorActive",   { bg = "none" })
  vim.api.nvim_set_hl(0, "NeoTreeTabSeparatorInactive", { bg = "none" })

  -- Trouble.nvimの透過（問題タブ）
  vim.api.nvim_set_hl(0, "TroubleNormal",   { bg = "none" })
  vim.api.nvim_set_hl(0, "TroubleNormalNC", { bg = "none" })

  -- NormalFloatの透過（フローティングウィンドウ）
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  -- FloatBorderは透過でもボーダーを見やすく
  vim.api.nvim_set_hl(0, "FloatBorder", {
    bg = "none",
    fg = "#808080",
    bold = true,
  })

  -- ステータスラインなど
  vim.api.nvim_set_hl(0, "StatusLine",   { bg = "none" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
  vim.api.nvim_set_hl(0, "TabLine",      { bg = "none" })
  vim.api.nvim_set_hl(0, "TabLineFill",  { bg = "none" })
  vim.api.nvim_set_hl(0, "TabLineSel",   { bg = "none" })
  vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none", fg = "none" })
end

-- 透過オン/オフをトグル
function M.toggle_transparency()
  M.enabled = not M.enabled

  if M.enabled then
    -- 透過を有効化
    M.setup()
  else
    -- 透過を無効化：カラースキームを再適用してデフォルトに戻す
    local current_colorscheme = vim.g.current_colorscheme or vim.g.colors_name
    if current_colorscheme then
      vim.cmd("colorscheme " .. current_colorscheme)
    end
  end

  vim.notify("透過: " .. (M.enabled and "有効" or "無効"), vim.log.levels.INFO)
end

return M
