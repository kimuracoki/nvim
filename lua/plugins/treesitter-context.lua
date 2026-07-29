return {
  -- 現在の関数/クラスなど「親スコープ」を画面上部にピン留め表示（VSCode の Sticky Scroll 相当）。
  -- 長い関数を編集中に「今どのメソッド/条件の中か」が常に見えるようにする。treesitter の構文木を使う。
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPre", "BufNewFile" }, -- ファイルを開くときに読む
    config = function()
      require("treesitter-context").setup({
        max_lines = 3,            -- 上部に貼り付ける最大行数（深いネストでも 3 行まで）
        multiline_threshold = 1,  -- 複数行にまたがるスコープは 1 行に圧縮して表示
        trim_scope = "outer",     -- 上限超過時は外側（遠い親）から削る
        mode = "cursor",          -- カーソル位置基準でコンテキストを決める
        separator = nil,          -- 本文との境界線は引かない（背景差だけで十分）
      })
      -- コンテキスト行をクリック相当でジャンプ（上部の親スコープ行へカーソルを飛ばす）。
      -- [c は gitsigns がバッファローカルで「前のハンクへ」に使っており（差分移動の vim 慣習）、
      -- バッファローカルが優先されるため git 管理下のファイルではこちらが完全に死んでいた。
      -- 衝突しない [C に移す。
      vim.keymap.set("n", "[C", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { desc = "Context: 親スコープへジャンプ" })
    end,
    keys = {
      { "<leader>uc", "<cmd>TSContextToggle<cr>", desc = "UI: Context toggle (親スコープのピン留め)" },
    },
  },
}
