-- オプション（mapleader など含む）
require("config.options")

-- キーマップ
require("config.keymaps")

-- プラグイン（lazy.nvim）
require("config.lazy")

-- 透過設定（カラースキーム変更時にも再適用）
local highlight = require("config.highlight")
highlight.setup()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.defer_fn(function()
      highlight.setup()
    end, 10)
  end,
})

-- 起動時にすべての分割画面を自動的に開く
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- 透過設定を再適用
    vim.defer_fn(function()
      highlight.setup()
    end, 100)
    -- レイアウト設定
    vim.defer_fn(function()
      require("config.startup").setup_layout()
    end, 200)
  end,
})

-- 自動保存（フォーカスが外れたときに自動保存）
vim.api.nvim_create_autocmd("FocusLost", {
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! write")
    end
  end,
})

-- 空バッファの自動削除（何かファイルが開いたら、使われていない空バッファを削除）
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    -- 少し遅延させて、プラグインの初期化を待つ
    vim.defer_fn(function()
      local current_buf = vim.api.nvim_get_current_buf()
      local current_name = vim.api.nvim_buf_get_name(current_buf)
      local current_buftype = vim.api.nvim_buf_get_option(current_buf, "buftype")

      -- 現在のバッファが実ファイルまたは特殊バッファの場合のみ実行
      if current_name ~= "" or current_buftype ~= "" then
        local buffers = vim.api.nvim_list_bufs()
        for _, buf in ipairs(buffers) do
          if buf ~= current_buf and vim.api.nvim_buf_is_valid(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
            local modified = vim.api.nvim_buf_get_option(buf, "modified")

            -- 通常のバッファで、名前なし、変更なしの場合
            if name == "" and buftype == "" and not modified then
              -- このバッファを表示しているウィンドウがあるか確認
              local has_window = false
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == buf then
                  has_window = true
                  break
                end
              end

              -- ウィンドウに表示されていない場合のみ削除
              if not has_window then
                pcall(vim.api.nvim_buf_delete, buf, { force = false })
              end
            end
          end
        end
      end
    end, 100)
  end,
})
