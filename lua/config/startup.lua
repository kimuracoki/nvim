local M = {}

-- すべての分割画面を自動的に開く
function M.setup_layout()
  -- プラグインが読み込まれるまで待つ
  vim.defer_fn(function()
    -- 1. 左側にファイルツリーを開く
    if vim.fn.exists(":NvimTreeOpen") == 2 then
      vim.cmd("NvimTreeOpen")
      vim.cmd("wincmd l") -- 右に移動（エディタエリアへ）
    end
    
    -- 2. 右側にlazygitを開く
    vim.cmd("rightbelow vsplit")
    vim.cmd("vertical resize 80")
    local lazygit_buf = vim.api.nvim_create_buf(false, true)
    local lazygit_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(lazygit_win, lazygit_buf)
    
    vim.fn.termopen("lazygit", {
      on_exit = function()
        -- lazygit終了時の処理
      end,
    })
    
    vim.schedule(function()
      vim.api.nvim_buf_set_option(lazygit_buf, "number", false)
      vim.api.nvim_buf_set_option(lazygit_buf, "relativenumber", false)
      vim.api.nvim_buf_set_option(lazygit_buf, "cursorline", false)
      vim.api.nvim_buf_set_option(lazygit_buf, "cursorcolumn", false)
      vim.cmd("startinsert")
    end)
    
    -- 3. 下にターミナルを1つ開く
    vim.cmd("wincmd h") -- 左に移動（エディタエリアへ）
    vim.cmd("belowright split")
    vim.cmd("resize 15")
    vim.cmd("terminal")
    
    -- 4. エディタエリアにフォーカスを戻す
    vim.cmd("wincmd k") -- 上に移動（エディタエリア）
  end, 100) -- 100ms待機してプラグインの読み込みを待つ
end

return M
