-- 診断（Diagnostics）の見た目・挙動の一元設定。補完エンジン（旧 completion.lua）から
-- 移設。blink.cmp は InsertEnter 後に読まれるため、ファイルを開いた直後からサイン列・
-- 波線が出るよう、ここ（trouble は lazy=false）の import 時＝起動時に設定しておく。
vim.diagnostic.config({
  virtual_text = false,
  -- カーソル行の診断表示は tiny-inline-diagnostic（下の spec）に委譲する。ネイティブの
  -- virtual_text / virtual_lines は両方 off にして二重表示を防ぐ。<leader>ud で tiny-inline を
  -- トグルする（表示のオン/オフ）。長文メッセージも tiny-inline 側の multilines で全文出る。
  virtual_lines = false,
  -- サイン列のアイコン（severity_sort で重要度順に表示される）。この sign を
  -- snacks.statuscolumn が拾って行番号のすぐ左に統合表示する（VSCode 風 gutter）。
  -- 行番号自体の色染め（numhl）は VSCode もやらないので付けない。sign アイコンで示す。
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- VSCode風の波線（undercurl）。診断色をハイライトの sp に流用する。
local function apply_undercurl()
  local groups = {
    { hl = "DiagnosticUnderlineError", src = "DiagnosticError", fb = "#f38ba8" },
    { hl = "DiagnosticUnderlineWarn",  src = "DiagnosticWarn",  fb = "#f9e2af" },
    { hl = "DiagnosticUnderlineInfo",  src = "DiagnosticInfo",  fb = "#89b4fa" },
    { hl = "DiagnosticUnderlineHint",  src = "DiagnosticHint",  fb = "#a6e3a1" },
  }
  for _, g in ipairs(groups) do
    local src = vim.api.nvim_get_hl(0, { name = g.src, link = false })
    vim.api.nvim_set_hl(0, g.hl, {
      undercurl = true,
      sp = src.fg and string.format("#%06x", src.fg) or g.fb,
    })
  end
end
vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = apply_undercurl })
vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_undercurl })

return {
  ---------------------------------------------------------------------------
  -- tiny-inline-diagnostic（カーソル行の診断を、行の右側に整形ボックスでインライン表示）。
  -- ネイティブの virtual_lines（診断を行の「下」に複数行展開）の代わりに、行をずらさず
  -- 右側に矢印付きで出す表示に置き換える。長文は multilines で折り返して全文表示。
  ---------------------------------------------------------------------------
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000, -- 診断の描画を握るので他の診断系より先に初期化する
    config = function()
      require("tiny-inline-diagnostic").setup({
        preset = "modern",
        options = {
          show_source = false,                    -- ソース名（LSP 名）は出さず簡潔に
          use_icons_from_diagnostic = true,
          -- カーソル行の診断「だけ」出す。multilines を有効にするとカーソル行に診断が無い
          -- ときに他行のエラーを表示してしまう（out-of-cursor 表示）ため、それを止める。
          -- 長文は既定の overflow=wrap で折り返すので multilines なしでも全文見える。
          show_diags_only_under_cursor = true,
          show_all_diags_on_cursorline = true,    -- 同じ行に複数診断があればまとめて出す
        },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- Trouble.nvim（VSCodeのProblemsパネル風）
  ---------------------------------------------------------------------------
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    opts = {
      auto_close = false,
      auto_open = false,
      auto_preview = true,
      auto_refresh = true,
      focus = false,
      open_no_results = true,
      win = {
        type = "split",
        relative = "win", -- 現在のウィンドウに対して相対的に開く
        position = "bottom",
        size = 10,
      },
      modes = {
        diagnostics = {
          -- Problems には Warning / Error のみ表示（Hint/Info を除外）
          filter = {
            any = {
              { severity = vim.diagnostic.severity.ERROR },
              { severity = vim.diagnostic.severity.WARN },
            },
          },
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics: Buffer" },
      { "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics: Workspace" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Diagnostics: Quickfix list" },
    },
  },
}
