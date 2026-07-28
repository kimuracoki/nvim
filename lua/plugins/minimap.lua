return {

  -- ミニマップ（VSCodeの右側コードマップ）
  {
    "gorbit99/codewindow.nvim",
    config = function()
      -- ミニマップのシンタックス色は codewindow/highlight.lua の extract_highlighting
      -- （＝treesitter 経由）でしか付かない。use_lsp は診断マーカー列を足すだけで色付けはしない。
      -- 一方 highlight.lua は require 時に nvim-treesitter.ts_utils を require するが、
      -- nvim-treesitter main ブランチには ts_utils が無いためそのままでは落ちる。
      -- codewindow が使うのは ts_utils.get_vim_range 一つだけなので、旧実装相当の
      -- シムを package.preload に登録して色付けを復活させる（他の内部 API は
      -- Neovim コアの vim.treesitter.highlighter にそのまま残っている）。
      if not package.loaded["nvim-treesitter.ts_utils"] then
        package.preload["nvim-treesitter.ts_utils"] = function()
          local M = {}
          -- 旧 nvim-treesitter の get_vim_range 相当。treesitter の 0 始まり・
          -- end 排他的レンジを、Vim の 1 始まりレンジへ変換する。
          function M.get_vim_range(range, buf)
            local srow, scol, erow, ecol = unpack(range)
            srow = srow + 1
            scol = scol + 1
            erow = erow + 1
            if ecol == 0 then
              -- 末尾が行頭を指す場合は前の行の最終桁に丸める。
              erow = erow - 1
              if not buf or buf == 0 then
                ecol = vim.fn.col({ erow, "$" }) - 1
              else
                ecol = #(vim.api.nvim_buf_get_lines(buf, erow - 1, erow, false)[1] or "")
              end
              ecol = math.max(ecol, 1)
            end
            return srow, scol, erow, ecol
          end
          return M
        end
      end

      -- highlight.lua は require 時（＝require("codewindow") 内）に config.use_treesitter を
      -- 見て ts_utils を require するので、codewindow より前に true にしておく必要がある
      -- （setup() 内の指定では読み込みに間に合わない）。
      require("codewindow.config").setup({ use_treesitter = true })

      local codewindow = require("codewindow")
      codewindow.setup({
        active_in_terminals = false,
        auto_enable = true,
        exclude_filetypes = { "NvimTree", "Trouble", "aerial" },
        max_minimap_height = nil,
        max_lines = nil,
        minimap_width = 20,
        use_lsp = true,
        -- ts_utils シムを入れてあるので treesitter でのシンタックス色付けを有効化する。
        use_treesitter = true,
        width_multiplier = 4,
        z_index = 1,
        window_border = "none",
      })

      -- ミニマップのトグルと同時にsidescrolloffも切り替え
      local minimap_open = true  -- auto_enable = true なので初期状態はtrue
      vim.keymap.set("n", "<leader>um", function()
        codewindow.toggle_minimap()
        minimap_open = not minimap_open
        if minimap_open then
          vim.opt.sidescrolloff = 25  -- ミニマップON時は余白を確保
        else
          vim.opt.sidescrolloff = 8   -- ミニマップOFF時は通常の余白
        end
      end, { desc = "UI: Minimap toggle" })
    end,
  },
}
