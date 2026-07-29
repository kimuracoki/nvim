-- ~/.config/nvim/lua/plugins/haskell.lua
-- Haskell の言語別インデント。
-- Neovim には組み込みの indent/haskell.vim が無く、tree-sitter-haskell にも indents.scm が
-- 無いため、何も入れないと autoindent（前行のインデントをそのままコピー）しか働かず、
-- `main = do` や `where` の次行が段下げされない（VSCode の言語別インデント相当が欠ける）。

return {
  -- do / where / case of / let の後で自動的に段下げする indentexpr を提供する
  {
    "itchyny/vim-haskell-indent",
    ft = { "haskell", "lhaskell" },
  },
}
