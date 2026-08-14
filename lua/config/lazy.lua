local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" }, -- lua/plugins/*.lua を全部読む
  },
  install = {
    colorscheme = { "catppuccin" }, -- デフォルトカラースキーム
  },
  checker = {
    enabled = false, -- 自動アップデートチェックはとりあえずOFF
  },
  -- 設定ファイルの変更監視。lazy 配下 1.4 万ファイルを抱える Windows では
  -- ファイル監視の張り直しが起動のたびに効いてくるうえ、変更したら nvim を
  -- 開き直す運用なので恩恵が無い。
  change_detection = { enabled = false },
  performance = {
    rtp = {
      -- Neovim 同梱の使っていない標準プラグインを読まない。
      -- netrw は neo-tree、zip/tar 閲覧・matchit は使っていないので丸ごと落とす。
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
