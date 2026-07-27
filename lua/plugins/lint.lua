return {
  -- LSP 外のリンタ実行（VSCode の言語拡張が持つ lint 相当）。conform=整形 と対になる lint 側。
  -- linters_by_ft は「その linter バイナリがある環境だけ」登録する（lsp.lua の has() と同方針）。
  -- eslint は LSP で別途カバーしているのでここでは JS/TS を扱わない。
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      local lint = require("lint")

      local function has(bin)
        return vim.fn.executable(bin) == 1
      end

      local by_ft = {}
      local function add(ft, bin, linter)
        if has(bin) then
          by_ft[ft] = { linter or bin }
        end
      end

      add("python", "ruff")
      add("go", "golangci-lint", "golangcilint")
      add("markdown", "markdownlint")
      add("sh", "shellcheck")
      add("bash", "shellcheck")
      add("dockerfile", "hadolint")
      add("yaml", "yamllint")
      add("json", "jsonlint")
      if has("hlint") then
        by_ft["haskell"] = { "hlint" }
      end
      if has("selene") then
        by_ft["lua"] = { "selene" }
      elseif has("luacheck") then
        by_ft["lua"] = { "luacheck" }
      end

      lint.linters_by_ft = by_ft

      local group = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = group,
        callback = function()
          -- そのバッファの ft に linter が登録されているときだけ走らせる
          if lint.linters_by_ft[vim.bo.filetype] then
            lint.try_lint()
          end
        end,
      })

      vim.keymap.set("n", "<leader>cl", function()
        lint.try_lint()
      end, { desc = "Code: Lint now (今すぐ lint 実行)" })
    end,
  },
}
