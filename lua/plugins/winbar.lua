return {
  -- winbar に関数・クラスの階層パンくずを表示（VSCode のブレッドクラム相当）。NVIM 0.11+ 前提。
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local configs = require("dropbar.configs")
      -- setup 前の既定判定を捕まえておく（setup 後は自分の関数に置き換わるので再帰してしまう）
      local default_enable = configs.opts.bar.enable

      require("dropbar").setup({
        bar = {
          -- コンテナ内 Neovim（config/docker_nvim.lua の SPC Dn）のバッファにはパンくずを出さない。
          -- dropbar の既定は buftype=terminal でも「あえて有効化する」実装（configs.lua の bar.enable）で、
          -- 中で別の Neovim が動いているこのケースでは外側のパンくずが被り、
          -- 「窓の中に窓」に見えてしまう。全画面で開く意味が無くなるのでここで落とす。
          enable = function(buf, win, src)
            local bufnr = buf
            if bufnr == 0 or bufnr == nil then
              bufnr = vim.api.nvim_get_current_buf()
            end
            if vim.api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].nested_nvim then
              return false
            end
            return default_enable(buf, win, src)
          end,
        },
      })
    end,
  },
}
