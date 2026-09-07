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
      -- レイアウトが確定したところで一度だけ全画面を描き直す。
      -- ここまでの間にツリーと問題パネルの分だけ本文が右下へずれるため、
      -- 端末によっては前のフレームが消えずに二重像として残る（Warp で確認）。
      vim.schedule(function()
        vim.cmd("redraw!")
      end)
    end, 300)
  end, 200)
end

return M
