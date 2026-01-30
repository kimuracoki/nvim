local M = {}

function M.setup_layout()
  vim.defer_fn(function()
    -- 左側にツリーを開く
    if vim.fn.exists(":Neotree") == 2 then
      vim.cmd("Neotree show")
      vim.cmd("wincmd l") -- エディタに移動
    end
    
    -- 問題パネルを開く（Troubleの設定で下部に表示される）
    vim.defer_fn(function()
      vim.cmd("Trouble diagnostics")
    end, 300)
  end, 200)
end

return M
