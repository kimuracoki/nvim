return {
  -- ToggleTerm（ターミナル管理とlazygit統合）
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    -- ターミナルを開くまで不要。open_mapping の <c-\> も keys に載せて初回押下でロードさせる
    cmd = { "ToggleTerm", "ToggleTermToggleAll", "TermExec" },
    keys = { [[<c-\>]], "<leader>gg" },
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float", -- フローティングウィンドウとして表示
        close_on_exit = false, -- プロセス継続のため
        shell = vim.o.shell,
        float_opts = {
          border = "rounded",
          width = function() return math.floor(vim.o.columns * 0.9) end,
          height = function() return math.floor(vim.o.lines * 0.9) end,
          winblend = 0,
        },
      })

      -- 全ターミナルで Esc をノーマルモードにせずそのままターミナルに送る（ic/ii 含む）→ keymaps.lua の Esc マップと BufEnter で対応
      -- Lazygit用のカスタムターミナル（フローティングウィンドウ）
      local Terminal = require("toggleterm.terminal").Terminal

      -- lazygit の重さは「git の中身」ではなく「git を起動する回数 x Windows のプロセス生成コスト」。
      -- この設定リポジトリ（404KB）でも `git status` 50ms に対し `git --version` が 45ms、
      -- つまり実作業はほぼ 0ms で全部がプロセス起動代だった。lazygit は 1 リフレッシュで
      -- git を 15〜20 回叩くので 700ms 前後かかる。
      --
      -- ラッパ経由の二重起動を避けるぶんだけ（1 回あたり 13.6ms）このターミナル限定で稼ぐ。
      -- PATH をプロセス限定にしているのは platform.git_bin_dir() のコメント参照。
      local lazygit_env = nil
      local git_bin = require("config.platform").git_bin_dir()
      if git_bin then
        lazygit_env = { PATH = git_bin .. ";" .. (vim.env.PATH or "") }
      end

      local lazygit = Terminal:new({
        cmd = "lazygit",
        dir = "git_dir",
        direction = "float",
        env = lazygit_env,
        float_opts = {
          border = "rounded",
          width = function() return math.floor(vim.o.columns * 0.9) end,
          height = function() return math.floor(vim.o.lines * 0.9) end,
        },
        hidden = true,
        on_open = function(term)
          vim.cmd("startinsert!")
          -- lazygit内でESCが効くように、ターミナルモードのマッピングを無効化
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
          -- プロセスが終了したら自動的にウィンドウとバッファを閉じる。
          --
          -- 【重要】バッファ削除だけでは不十分。表示先に回せる通常バッファが 1 つも無いとき
          -- （引数なし起動でダッシュボードだけ = listed バッファ 0 の状態）、Neovim はフロートを
          -- 閉じずに新しい空バッファを割り当てるため、lazygit を q で閉じたあとに「空のフロート」が
          -- 残ってしまう（検証済み）。先に term:close() でウィンドウを畳んでから削除する。
          -- toggleterm 側が先に片付けている場合があるので、必ず有効性を見てから消す（E5108 を防ぐ）
          vim.api.nvim_create_autocmd("TermClose", {
            buffer = term.bufnr,
            callback = function()
              vim.schedule(function()
                if term:is_open() then
                  pcall(function()
                    term:close()
                  end)
                end
                if vim.api.nvim_buf_is_valid(term.bufnr) then
                  pcall(vim.api.nvim_buf_delete, term.bufnr, { force = true })
                end
              end)
            end,
            once = true,
          })
        end,
      })

      -- Lazygitをトグルする（以前はグローバル変数 _lazygit_toggle に入れていたが、
      -- グローバル空間を汚すだけで参照箇所が無かったのでローカルにした）
      --
      -- 未初期化ディレクトリでは lazygit の素の「git init」ではなく gitflow 構成
      -- （main + develop）で初期化するか先に聞く。初期化を lazygit より前に済ませておくのが重要で、
      -- toggleterm は初回 open 時に dir = "git_dir" を実パスへ解決してキャッシュするため、
      -- 先にリポジトリが無いと lazygit がワークツリー外で起動してしまう。
      local function lazygit_toggle()
        if not require("config.platform").has("lazygit") then
          vim.notify("lazygit が見つかりません（インストールして PATH を通してください）", vim.log.levels.WARN)
          return
        end
        require("config.gitflow").ensure(nil, function()
          lazygit:toggle()
        end)
      end

      -- キーマップ設定
      vim.keymap.set("n", "<leader>gg", lazygit_toggle, { desc = "Git: Lazygit" })
    end,
  },
}
