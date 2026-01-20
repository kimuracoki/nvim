local M = {}

-- すべての分割画面を自動的に開く（ツリーのみ）
function M.setup_layout()
  vim.defer_fn(function()
    -- 左側にファイルツリーを開く
    if vim.fn.exists(":NvimTreeOpen") == 2 then
      vim.cmd("NvimTreeOpen")
      vim.cmd("wincmd l") -- 右に移動（エディタエリアへ）
    end
  end, 100)
end

return M
