return {
  -- REST クライアント（VSCode の REST Client 相当）。.http / .rest ファイルで API を叩いて結果を表示。
  {
    "mistweaverco/kulala.nvim",
    -- kulala は独自 grammar の tree-sitter パーサを `tree-sitter` CLI でビルドして使う。
    -- CLI が無い環境で読み込むと ENOENT で落ちるため、lsp.lua の has() と同方針でガードする。
    -- 有効化するには CLI を入れる: `brew install tree-sitter`（Mac）/ `npm i -g tree-sitter-cli`。
    cond = function()
      return require("config.platform").has("tree-sitter")
    end,
    ft = { "http", "rest" },
    keys = {
      { "<leader>Rs", function() require("kulala").run() end, desc = "Rest: Send request (リクエストを送信)" },
      { "<leader>Ra", function() require("kulala").run_all() end, desc = "Rest: Send all (全リクエストを送信)" },
      { "<leader>Rp", function() require("kulala").jump_prev() end, desc = "Rest: Previous request (前のリクエストへ)" },
      { "<leader>Rn", function() require("kulala").jump_next() end, desc = "Rest: Next request (次のリクエストへ)" },
      { "<leader>Rc", function() require("kulala").copy() end, desc = "Rest: Copy as curl (curl としてコピー)" },
      { "<leader>Ri", function() require("kulala").inspect() end, desc = "Rest: Inspect (リクエスト内容を確認)" },
    },
    opts = {
      global_keymaps = false, -- キーは上の keys で明示登録する
    },
    config = function(_, opts)
      -- kulala は grammar を別リポジトリから取ってくる（git init → remote add → fetch）。
      -- 途中でこけると .git だけ残って origin 未設定のディレクトリができ、以降は
      -- 「.git があるので fetch する」経路に入り続けて
      -- "Failed to fetch tree-sitter grammar: fatal: 'origin' does not appear to be a git repository"
      -- を毎回出す（実際にこの状態になっていた）。読み込み時に検出して直す。
      local dir = vim.fs.joinpath(vim.fn.stdpath("data"), "kulala.nvim", "tree-sitter-kulala-http")
      if vim.fn.isdirectory(dir .. "/.git") == 1 then
        local f = io.open(dir .. "/.git/config", "r")
        local conf = f and f:read("*a") or ""
        if f then
          f:close()
        end
        if not conf:find('[remote "origin"]', 1, true) then
          vim.fn.system({
            "git", "-C", dir, "remote", "add", "origin",
            "https://github.com/mistweaverco/tree-sitter-kulala-http",
          })
          vim.notify("kulala: grammar 取得先(origin)が未設定だったので復旧しました", vim.log.levels.INFO)
        end
      end
      require("kulala").setup(opts)
    end,
  },
}
