return {
  -- GitGraph相当（コミットグラフ）
  {
    "isakbm/gitgraph.nvim",
    -- <leader>gl で開くまで不要。ハイライト設定を持つ _G.setup_gitgraph_highlights は
    -- highlight.lua / keymaps.lua 側が存在チェック付きで呼ぶので、未ロードでも壊れない。
    keys = { "<leader>gl" },
    dependencies = { "sindrets/diffview.nvim" },
    config = function()
      -- GitGraphハイライト設定関数（透過切り替え時にも再適用できるように）
      local function setup_gitgraph_highlights()
        -- Catppuccin Mocha カラーパレット
        vim.api.nvim_set_hl(0, "GitGraphHash", { fg = "#89b4fa" })           -- Blue
        vim.api.nvim_set_hl(0, "GitGraphTimestamp", { fg = "#bac2de" })      -- Subtext0
        vim.api.nvim_set_hl(0, "GitGraphAuthor", { fg = "#f5c2e7" })         -- Pink
        vim.api.nvim_set_hl(0, "GitGraphBranchMsg", { fg = "#ffffff" })      -- 白
        -- ブランチ名（デフォルトの背景バッジ）
        vim.api.nvim_set_hl(0, "GitGraphBranchName", { fg = "#1e1e2e", bg = "#a6e3a1", bold = true })
        -- main / develop 用の特別色（バッジのみ上書き）
        vim.api.nvim_set_hl(0, "GitGraphBranchNameMain", { fg = "#1e1e2e", bg = "#f38ba8", bold = true })    -- Red-ish
        vim.api.nvim_set_hl(0, "GitGraphBranchNameDevelop", { fg = "#1e1e2e", bg = "#89b4fa", bold = true }) -- Blue-ish
        -- タグ（Mauve背景バッジ）
        vim.api.nvim_set_hl(0, "GitGraphBranchTag", { fg = "#1e1e2e", bg = "#cba6f7", bold = true })
        -- ブランチカラー（Catppuccin Mocha）
        local branch_colors = { "#89b4fa", "#a6e3a1", "#f9e2af", "#f38ba8", "#cba6f7", "#89dceb", "#94e2d5", "#fab387" }
        for i, color in ipairs(branch_colors) do
          vim.api.nvim_set_hl(0, "GitGraphBranch" .. i, { fg = color })
        end
      end

      -- グローバルに関数を保存（透過切り替え時に呼び出せるように）
      _G.setup_gitgraph_highlights = setup_gitgraph_highlights

      -- 初回ハイライト設定
      setup_gitgraph_highlights()

      require("gitgraph").setup({
        symbols = {
        merge_commit = "○",
        commit = "●",
        merge_commit_end = "○",
        commit_end = "●",
        -- Advanced symbols
        GVER = "│",
        GHOR = "─",
        GCLD = "╮",
        GCRD = "╭",
        GCLU = "╯",
        GCRU = "╰",
        GLRU = "┴",
        GLRD = "┬",
        GLUD = "┤",
        GRUD = "├",
        GFORKU = "┼",
        GFORKD = "┼",
        GRUDCD = "├",
        GRUDCU = "┡",
        GLUDCD = "┪",
        GLUDCU = "┩",
        GLRDCL = "┬",
        GLRDCR = "┬",
        GLRUCL = "┴",
        GLRUCR = "┴",
      },
      format = {
        timestamp = "%Y-%m-%d %H:%M",
        fields = { "hash", "timestamp", "author", "branch_name", "tag" },
      },
      hooks = {
        -- コミット選択時に diffview で差分表示
        on_select_commit = function(commit)
          vim.notify("DiffviewOpen " .. commit.hash .. "^!")
          vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
        end,
        -- 範囲選択時に diffview で差分表示
        on_select_range_commit = function(from, to)
          vim.notify("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
          vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
        end,
      },
      })

      -- GitGraph バッファ上で main / develop のバッジだけ色を変える
      local function highlight_special_branches(bufnr)
        bufnr = bufnr or vim.api.nvim_get_current_buf()
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end

        local name = vim.api.nvim_buf_get_name(bufnr)
        if not name:match("GitGraph") then
          return
        end

        local ns = vim.api.nvim_create_namespace("gitgraph_special_branches")

        local line_count = vim.api.nvim_buf_line_count(bufnr)
        for lnum = 0, line_count - 1 do
          local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]
          if line then
            -- origin/main / origin/develop を優先的にフルでハイライト
            local search_start = 1
            while true do
              local s, e = line:find("origin/main", search_start, true)
              if not s then break end
              vim.api.nvim_buf_add_highlight(
                bufnr,
                ns,
                "GitGraphBranchNameMain",
                lnum,
                s - 1,
                e
              )
              search_start = e + 1
            end

            search_start = 1
            while true do
              local s, e = line:find("origin/develop", search_start, true)
              if not s then break end
              vim.api.nvim_buf_add_highlight(
                bufnr,
                ns,
                "GitGraphBranchNameDevelop",
                lnum,
                s - 1,
                e
              )
              search_start = e + 1
            end

            -- 単独の main / develop（単語境界）もすべてハイライト
            local patterns = {
              { "main", "GitGraphBranchNameMain" },
              { "develop", "GitGraphBranchNameDevelop" },
            }

            for _, item in ipairs(patterns) do
              local word, hl = item[1], item[2]
              local frontier_pattern = "%f[%w_]" .. word .. "%f[^%w_]"

              local init = 1
              while true do
                local s, e = line:find(frontier_pattern, init)
                if not s then break end
                vim.api.nvim_buf_add_highlight(
                  bufnr,
                  ns,
                  hl,
                  lnum,
                  s - 1,
                  e
                )
                init = e + 1
              end
            end
          end
        end
      end

      -- rキーでリロードする関数
      local function reload_gitgraph_buffer()
        local current_buf = vim.api.nvim_get_current_buf()
        local buf_name = vim.api.nvim_buf_get_name(current_buf)

        -- gitgraphバッファかどうか確認
        if not buf_name:match("GitGraph") then
          return
        end

        -- ハイライトを再適用
        setup_gitgraph_highlights()

        -- 新しい空のバッファを作成してから古いバッファを削除
        vim.cmd("enew")
        local temp_buf = vim.api.nvim_get_current_buf()  -- enewで作成された一時バッファ
        pcall(vim.api.nvim_buf_delete, current_buf, { force = true })

        -- 再描画
        local ok, err = pcall(function()
          require("gitgraph").draw({}, { all = true, max_count = 5000 })
        end)

        if not ok then
          vim.notify("GitGraph reload failed: " .. tostring(err), vim.log.levels.ERROR)
          return
        end

        vim.schedule(function()
          vim.bo.buflisted = false  -- バッファリストに表示しない
          vim.bo.bufhidden = "wipe"  -- ウィンドウから隠されたら自動削除
          -- main / develop のバッジだけ色を上書き
          highlight_special_branches()
          -- rキーマッピングを再設定
          vim.keymap.set("n", "r", reload_gitgraph_buffer, { buffer = true, desc = "Reload git graph" })

          -- enewで作成された一時バッファを削除
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(temp_buf) then
              pcall(vim.api.nvim_buf_delete, temp_buf, { force = true })
            end
          end, 50)
        end)
      end

      local function open_gitgraph()
        -- ハイライトを常に再適用（透過切り替えやカラースキーム変更後も正しく表示）
        setup_gitgraph_highlights()

        -- 既存のgitgraphバッファを探して削除（常に新規作成）
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            if name:match("GitGraph") then
              -- 既存のGitGraphバッファを削除
              pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
          end
        end

        -- 常に新規作成
        require("gitgraph").draw({}, { all = true, max_count = 5000 })
        vim.schedule(function()
          vim.bo.buflisted = false  -- バッファリストに表示しない
          vim.bo.bufhidden = "wipe"  -- ウィンドウから隠されたら自動削除
          -- main / develop のバッジだけ色を上書き
          highlight_special_branches()
          -- rキーでリロード
          vim.keymap.set("n", "r", reload_gitgraph_buffer, { buffer = true, desc = "Reload git graph" })
        end)
      end

      vim.keymap.set("n", "<leader>gl", open_gitgraph, { desc = "Git: Log graph" })
    end,
  },
}
