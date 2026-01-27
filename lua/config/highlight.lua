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
  
  -- Trouble.nvimの透過
  vim.api.nvim_set_hl(0, "TroubleNormal",   { bg = "none" })
  vim.api.nvim_set_hl(0, "TroubleNormalNC", { bg = "none" })
  
  -- NormalFloatの透過（フローティングウィンドウ）
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  -- FloatBorderは透過のままでもボーダーを目立たせる（見やすくするため）
  vim.api.nvim_set_hl(0, "FloatBorder", { 
    bg = "none", 
    fg = "#808080",  -- グレーのボーダーで囲む
    bold = true,
  })
  -- lspsagaのボーダーも設定
  vim.api.nvim_set_hl(0, "SagaBorder", { 
    bg = "none", 
    fg = "#808080",  -- グレーのボーダーで囲む
    bold = true,
  })
  vim.api.nvim_set_hl(0, "SagaNormal", { 
    bg = "none",
  })
  
  -- その他の透過設定
  vim.api.nvim_set_hl(0, "StatusLine",   { bg = "none" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
  vim.api.nvim_set_hl(0, "TabLine",      { bg = "none" })
  vim.api.nvim_set_hl(0, "TabLineFill",  { bg = "none" })
  vim.api.nvim_set_hl(0, "TabLineSel",    { bg = "none" })
  vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none", fg = "none" })
end

return M
