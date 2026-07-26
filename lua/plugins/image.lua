return {
  -- 画像表示（Kitty graphics protocol対応ターミナルで画像をインライン表示）
  {
    "folke/snacks.nvim",
    ft = { "markdown", "markdown.pandoc" }, -- .md を開いたときに確実にロード
    opts = {
      image = {
        force = true, -- Warp等で自動検出が失敗する場合に強制有効化
        -- Markdownファイル内の ![](path) 画像も表示
        -- インライン: kitty/ghostty のみ。Warp は supported のみ（フロート表示で文字化け回避）。
        doc = {
          enabled = true,
          inline = true,
          float = true,
          max_width = 80,
          max_height = 40,
        },
      },
      -- 画像フロートの表示位置（bufferlineとの重なりを避けるため上にマージン）
      styles = {
        snacks_image = {
          relative = "editor",
          row = 2,
          col = -1,
        },
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)

      -- Warp: 画像表示は supported のみ（placeholders は未対応のためフロート表示で文字化け回避）
      local term = require("snacks.image.terminal")
      local orig_env = term.env
      term.env = function()
        local e = orig_env()
        if not e then return e end
        local term_program = os.getenv("TERM_PROGRAM") or ""
        local is_warp = term_program:find("Warp") ~= nil
        if is_warp then
          -- supported = true で画像は表示、placeholders = false でインラインではなくフロートに
          e = vim.tbl_extend("force", {}, e, { supported = true, placeholders = false })
        elseif opts.image and opts.image.force and e.supported then
          e = vim.tbl_extend("force", {}, e, { placeholders = true })
        end
        return e
      end

      -- ft ロード時は FileType が既に発火済みなので、現在の markdown バッファに手動で attach
      vim.schedule(function()
        local buf = vim.api.nvim_get_current_buf()
        local ft = vim.bo[buf].filetype
        if ft == "markdown" or ft:find("^markdown") then
          pcall(function()
            require("snacks.image.doc").attach(buf)
          end)
        end
      end)

      local terminal = require("snacks.image.terminal")
      local reloading = false

      -- 画像バッファを離れるとき: ターミナル上の全画像をクリア
      vim.api.nvim_create_autocmd("BufLeave", {
        callback = function()
          if vim.bo.filetype == "image" then
            pcall(function()
              terminal.request({ a = "d", d = "a" })
            end)
          end
        end,
      })

      -- 画像バッファに入るとき: :edit で再レンダリングをトリガー
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          if reloading then return end
          if vim.bo.filetype == "image" then
            reloading = true
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(vim.api.nvim_get_current_buf()) then
                pcall(function() vim.cmd("edit") end)
              end
              reloading = false
            end)
          end
        end,
      })
    end,
  },
}
