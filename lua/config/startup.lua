local M = {}

-- すべての分割画面を自動的に開く（ツリーと問題パネル）
function M.setup_layout()
  vim.defer_fn(function()
    -- 左側にファイルツリーを開く
    if vim.fn.exists(":NvimTreeOpen") == 2 then
      vim.cmd("NvimTreeOpen")
      vim.cmd("wincmd l") -- 右に移動（エディタエリアへ）
    end
    
    -- 右側に問題パネルを開く（VSCodeのProblemsパネル風）
    vim.defer_fn(function()
      if vim.fn.exists(":TroubleToggle") == 2 then
        require("trouble").open("workspace_diagnostics")
      end
    end, 200)
  end, 100)
end

return M
