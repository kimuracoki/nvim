return {
  -- mini.nvim（モノレポ）から必要なモジュールだけ使う。将来 mini.* を足しやすい。
  -- surround: 囲み操作（gsa 追加 / gsd 削除 / gsr 置換）。s 単独は flash に譲るため gs 接頭辞。
  -- ai: 関数・引数・タグを賢く選ぶテキストオブジェクト（af/if・aa/ia など）
  -- move: 行/選択の移動（<M-h/j/k/l>。VSCode の Alt+↑↓ 相当）
  -- splitjoin: 引数リスト等の一行⇄複数行トグル（gS。VSCode の Toggle... 相当）
  {
    "nvim-mini/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.surround").setup({
        mappings = {
          add = "gsa",
          delete = "gsd",
          replace = "gsr",
          find = "gsf",
          find_left = "gsF",
          highlight = "gsh",
          update_n_lines = "gsn",
        },
      })
      require("mini.ai").setup({})
      require("mini.move").setup({}) -- <M-h/j/k/l> で行/選択を移動
      require("mini.splitjoin").setup({}) -- gS でトグル
    end,
  },
}
