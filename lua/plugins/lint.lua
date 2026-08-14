return {
  -- LSP 外のリンタ実行（VSCode の言語拡張が持つ lint 相当）。conform=整形 と対になる lint 側。
  -- linters_by_ft は「その linter バイナリがある環境だけ」登録する（lsp.lua の has() と同方針）。
  -- eslint は LSP で別途カバーしているのでここでは JS/TS を扱わない。
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- 外部ツールの有無判定は platform に集約している（lsp.lua と同方針）
      local has = require("config.platform").has

      -- linter の有無を調べる executable() 10 回ぶん（Windows で約 17ms）を起動パスから外す。
      -- この config は BufReadPost、つまり最初のファイルを開く同期処理の途中で走るため、
      -- ここで PATH を総なめすると、そのぶん画面が出るのが遅れる。判定が 1 tick 遅れても、
      -- 下の autocmd はそもそも「今まさに発火中の BufReadPost」を拾えないので取りこぼしは増えない。
      -- 検出が終わった時点で現在のバッファを 1 回だけ lint して辻褄を合わせる。
      vim.schedule(function()
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

        if lint.linters_by_ft[vim.bo.filetype] then
          lint.try_lint()
        end
      end)

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
