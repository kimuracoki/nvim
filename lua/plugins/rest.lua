return {
  -- REST クライアント（VSCode の REST Client 相当）。.http / .rest ファイルで API を叩いて結果を表示。
  {
    "mistweaverco/kulala.nvim",
    -- kulala は独自 grammar の tree-sitter パーサを `tree-sitter` CLI でビルドして使う。
    -- CLI が無い環境で読み込むと ENOENT で落ちるため、lsp.lua の has() と同方針でガードする。
    -- 有効化するには CLI を入れる: `brew install tree-sitter`（Mac）/ `npm i -g tree-sitter-cli`。
    cond = function()
      return vim.fn.executable("tree-sitter") == 1
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
  },
}
