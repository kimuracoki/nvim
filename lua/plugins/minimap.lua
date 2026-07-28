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
        -- 診断は点字ドット列ではなく「行全体の背景を着色」して VSCode 風に見せる
        -- （下の update_minimap ラッパーで実装）。ドット列は意味が薄いので無効化。
        use_lsp = false,
        -- ts_utils シムを入れてあるので treesitter でのシンタックス色付けを有効化する。
        use_treesitter = true,
        width_multiplier = 4,
        z_index = 1,
        window_border = "none",
      })

      -- ── 診断を「行全体の赤/黄背景」で表示する（VSCode 風）─────────────────
      -- codewindow 標準の LSP 表示は左端の点字ドット列だけで意味が薄い。
      -- そこでミニマップ描画後に、診断のある行に対応するミニマップ行の
      -- コード領域へ背景ハイライトを重ねる。ミニマップの各行は元ソースの
      -- 4 行を 1 行に圧縮しているので lnum→row は floor(lnum/4)。
      -- 列レイアウト: 先頭6byte が診断ドット列(placeholder)、その後ろ
      -- 3*minimap_width byte がコード領域（braille 1 文字=3byte）。
      local config = require("codewindow.config")
      local text = require("codewindow.text")
      local diag_ns = vim.api.nvim_create_namespace("codewindow.diag_line")

      -- hex色(整数)→RGB
      local function to_rgb(c)
        return math.floor(c / 65536) % 256, math.floor(c / 256) % 256, c % 256
      end
      -- fg を bg に alpha でブレンドして淡い背景色を作る
      local function blend(fg, bg, alpha)
        if not fg or not bg then return nil end
        local fr, fg_, fb = to_rgb(fg)
        local br, bg_, bb = to_rgb(bg)
        local mix = function(a, b) return math.floor(a * alpha + b * (1 - alpha) + 0.5) end
        return string.format("#%02x%02x%02x", mix(fr, br), mix(fg_, bg_), mix(fb, bb))
      end
      local function hl_attr(name, attr)
        local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
        if ok and h then return h[attr] end
      end

      -- テーマの Diagnostic 色を Normal 背景にブレンドして行背景色を定義。
      -- 絶対色なので ColorScheme 変更時に再計算する。
      local function setup_diag_hl()
        local normal_bg = hl_attr("Normal", "bg") or 0x000000
        local err_fg = hl_attr("DiagnosticError", "fg") or hl_attr("DiagnosticSignError", "fg") or 0xff0000
        local warn_fg = hl_attr("DiagnosticWarn", "fg") or hl_attr("DiagnosticSignWarn", "fg") or 0xffcc00
        vim.api.nvim_set_hl(0, "CodewindowErrorLine", { bg = blend(err_fg, normal_bg, 0.40) })
        vim.api.nvim_set_hl(0, "CodewindowWarnLine", { bg = blend(warn_fg, normal_bg, 0.30) })
      end
      setup_diag_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = setup_diag_hl,
        desc = "Recompute minimap diagnostic line colors",
      })

      local orig_update = text.update_minimap
      text.update_minimap = function(current_buffer, win)
        orig_update(current_buffer, win)
        pcall(function()
          if not (current_buffer and vim.api.nvim_buf_is_valid(current_buffer)) then return end
          if not (win and win.buffer and vim.api.nvim_buf_is_valid(win.buffer)) then return end
          local mbuf = win.buffer
          vim.api.nvim_buf_clear_namespace(mbuf, diag_ns, 0, -1)

          local col_start = 6
          local col_end = 6 + 3 * config.get().minimap_width

          -- ミニマップ行(0始まり) → 最も重い severity
          local row_sev = {}
          local diags = vim.diagnostic.get(current_buffer, {
            severity = { min = vim.diagnostic.severity.WARN },
          })
          for _, d in ipairs(diags) do
            local row = math.floor(d.lnum / 4)
            if row_sev[row] == nil or d.severity < row_sev[row] then
              row_sev[row] = d.severity
            end
          end

          local line_count = vim.api.nvim_buf_line_count(mbuf)
          for row, sev in pairs(row_sev) do
            if row < line_count then
              local group = (sev == vim.diagnostic.severity.ERROR)
                  and "CodewindowErrorLine" or "CodewindowWarnLine"
              vim.api.nvim_buf_add_highlight(mbuf, diag_ns, group, row, col_start, col_end)
            end
          end
        end)
      end

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
