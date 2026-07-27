-- 診断（Diagnostics）の見た目・挙動の一元設定。補完エンジン（旧 completion.lua）から
-- 移設。blink.cmp は InsertEnter 後に読まれるため、ファイルを開いた直後からサイン列・
-- 波線が出るよう、ここ（trouble は lazy=false）の import 時＝起動時に設定しておく。
vim.diagnostic.config({
  virtual_text = false,
  -- カーソル行の診断だけ、その場に展開表示する（0.11+）。<leader>ud でトグル可能。
  virtual_lines = { current_line = true },
  -- サイン列のアイコン（severity_sort で重要度順に表示される）
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
