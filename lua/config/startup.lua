local M = {}

-- すべての分割画面を自動的に開く（ツリーと問題パネル）
function M.setup_layout()
  vim.defer_fn(function()
    -- 左側にファイルツリーを開く
    if vim.fn.exists(":NvimTreeOpen") == 2 then
      vim.cmd("NvimTreeOpen")
      vim.cmd("wincmd l") -- 右に移動（エディタエリアへ）
    end
    
    -- 下部に問題パネルを開く（VSCodeのProblemsパネル風）
    vim.defer_fn(function()
      local ok, trouble = pcall(require, "trouble")
      if ok then
        trouble.open({
          mode = "diagnostics",
          win = {
            type = "split",
            position = "bottom",
            size = 10,
          },
        })
      end
    end, 500)
  end, 100)
end

return M
