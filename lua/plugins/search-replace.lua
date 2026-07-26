return {
  -- プロジェクト全体の検索置換をライブプレビュー付きで（VSCode の検索置換パネル相当）。
  -- telescope の grep は「検索」中心なので、置換はこちらで補う。
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = {},
    keys = {
      {
        "<leader>sr",
        function()
          require("grug-far").open()
        end,
        desc = "Search: Replace in project",
      },
      {
        "<leader>sr",
        mode = "v",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        desc = "Search: Replace selection",
      },
    },
  },
}
