-- ~/.config/nvim/lua/plugins/nene.lua
-- 自作言語 Nene（*.nn）のハイライトと言語サーバ（診断・ホバー・定義ジャンプ・補完）。
-- GitHub の kimuracoki/nene から入れる。
--
-- 【言語サーバの起動】nene.setup() が次の順で探す:
--   プロジェクトの node_modules/.bin/nene（npm の nene-lang）→ このプラグインの src/lsp.ts → PATH の nene。
-- src/lsp.ts を直接動かすときは node 23.6 以上（型の剥がし込み）が要るので、node が無ければ読まない。

return {
  -- Nene の言語サポート（VSCode の言語拡張相当）
  {
    "kimuracoki/nene",
    cond = function()
      return require("config.platform").has("node")
    end,
    ft = "nene",
    init = function()
      -- 【init で filetype を登録する理由】nvim 用のファイルはリポジトリ直下ではなく editors/nvim に
      -- あるので、lazy.nvim は ftdetect を見つけられない。ここで .nn を nene と判定しておかないと
      -- ft = "nene" の遅延ロードが一度も発火しない。
      vim.filetype.add({ extension = { nn = "nene" } })
    end,
    config = function(plugin)
      -- syntax/nene.vim と lua/nene.lua を読めるようにする。lazy は FileType をロード後に
      -- 再発火するので、最初に開いたバッファにもハイライトが付く
      vim.opt.rtp:append(vim.fs.joinpath(plugin.dir, "editors", "nvim"))
      -- 【completion = false を明示する理由】nene.setup() は package.loaded で cmp / blink.cmp の
      -- 有無を見て、無ければ nvim 標準の補完（autotrigger）を立てる。blink.cmp は InsertEnter で
      -- 遅延ロードなので .nn を開いた時点ではまだ読まれておらず、既定のままだと標準補完と
      -- blink の両方のポップアップが出る。LSP の候補は blink の lsp ソースが拾う。
      require("nene").setup({ completion = false })
    end,
  },
}
