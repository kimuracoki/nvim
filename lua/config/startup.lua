local M = {}

function M.setup_layout()
  vim.defer_fn(function()
    -- 左側にファイルツリーを開く
    if vim.fn.exists(":NvimTreeOpen") == 2 then
      vim.cmd("NvimTreeOpen")
      vim.cmd("wincmd l")
    end

    -- 下部に問題パネルを開く
    vim.defer_fn(function()
      vim.cmd("Trouble diagnostics")
    end, 500)
  end, 100)
end

return M
