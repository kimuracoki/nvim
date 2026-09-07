return {
  -- winbar に関数・クラスの階層パンくずを表示（VSCode のブレッドクラム相当）。NVIM 0.11+ 前提。
  --
  -- 【コンテナ内 Neovim（SPC Dn）との関係】
  -- dropbar の既定判定は「winbar が空のウィンドウ」にだけ付く（dropbar/configs.lua の bar.enable）。
  -- コンテナ内 Neovim の全画面タブでは config/docker_term.lua が winbar に在席インジケータを
  -- 入れる＝空ではないので、こちらは何もしなくても付かない。
  -- 以前は enable を上書きして除外していたが、起動のたびに走る判定に自前の関数を挟むのは
  -- リスクだけ増えて得が無いのでやめた。
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}
