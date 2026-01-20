
local M = {}

function M.setup()
  -- 透過（背景だけ消す）
  vim.api.nvim_set_hl(0, "Normal",     { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalNC",   { bg = "none" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
  vim.api.nvim_set_hl(0, "LineNr",     { bg = "none" })
  
  -- nvim-treeの透過
  vim.api.nvim_set_hl(0, "NvimTreeNormal",       { bg = "none" })
  vim.api.nvim_set_hl(0, "NvimTreeNormalNC",     { bg = "none" })
  vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })
  vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { bg = "none", fg = "none" })
  
  -- その他の透過設定
  vim.api.nvim_set_hl(0, "StatusLine",   { bg = "none" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
  vim.api.nvim_set_hl(0, "TabLine",      { bg = "none" })
  vim.api.nvim_set_hl(0, "TabLineFill",  { bg = "none" })
  vim.api.nvim_set_hl(0, "TabLineSel",    { bg = "none" })
  vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none", fg = "none" })
end

return M
