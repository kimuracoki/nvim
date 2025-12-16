
local M = {}

function M.setup()
  -- 透過（背景だけ消す）
  vim.api.nvim_set_hl(0, "Normal",     { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalNC",   { bg = "none" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
  vim.api.nvim_set_hl(0, "LineNr",     { bg = "none" })

end

return M
