local map = vim.keymap.set

-- 保存
map("n", "<C-s>", ":w<CR>", { desc = "Save" })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save" })

-- バッファ移動
map("n", "<S-h>", ":BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", ":BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<leader>bc", ":bdelete<CR>", { desc = "Close buffer" })
map("n", "<leader>bb", ":Telescope buffers<CR>", { desc = "List buffers" })

-- ウィンドウ移動
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- jkでノーマルモードに戻る
map("i", "jk", "<Esc>", { noremap = true })

-- 全選択
map("n", "<leader>a", "ggVG", { desc = "Select all" })
map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- コピー・ペースト
map("v", "<C-c>", '"+y', { desc = "Copy" })
map({ "n", "i" }, "<C-v>", '"+p', { desc = "Paste" })

-- アンドゥ・リドゥ
map("n", "<C-z>", "u", { desc = "Undo" })
map("n", "<C-S-z>", "<C-r>", { desc = "Redo" })

-- ターミナル
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("t", "jk", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("n", "<leader>tt", function()
  require("toggleterm").toggle(1)
end, { desc = "Toggle terminal" })

-- レイアウト
map("n", "<leader>ww", function()
  require("config.startup").setup_layout()
end, { desc = "Setup layout" })

-- 終了
map("n", "<leader>q", ":qa<CR>", { desc = "Quit all" })

-- LSP関連
map("n", "K", function()
  -- lspsagaのhoverを使用（ボーダー付きフローティングウィンドウ）
  vim.lsp.buf.hover()
end, { desc = "Hover documentation" })

map("n", "gd", function()
  vim.lsp.buf.definition()
end, { desc = "Go to definition" })

map("n", "gr", function()
  vim.lsp.buf.references()
end, { desc = "Find references" })

map("n", "<leader>ca", function()
  vim.lsp.buf.code_action()
end, { desc = "Code action" })

-- 診断
map("n", "<leader>xd", function()
  vim.diagnostic.open_float()
end, { desc = "Show diagnostics" })

map("n", "[d", function()
  vim.diagnostic.goto_prev()
end, { desc = "Previous diagnostic" })

map("n", "]d", function()
  vim.diagnostic.goto_next()
end, { desc = "Next diagnostic" })

-- カラースキーム切り替え
map("n", "<leader>cs", function()
  local colorschemes = {
    "tokyonight",
    "catppuccin",
    "kanagawa",
    "onedark",
    "gruvbox-material",
    "gruvbox",
    "rose-pine",
    "nord",
    "dracula",
    "nightfox",
    "everforest",
    "material",
    "monokai",
    "habamax",
  }
  
  -- lazyプラグイン名のマッピング
  local plugin_map = {
    catppuccin = "catppuccin",
    kanagawa = "kanagawa",
    onedark = "onedark",
    ["gruvbox-material"] = "gruvbox-material",
    gruvbox = "gruvbox",
    ["rose-pine"] = "rose-pine",
    nord = "nord",
    dracula = "dracula",
    nightfox = "nightfox",
    everforest = "everforest",
    material = "material",
    monokai = "monokai",
  }
  
  -- 現在のカラースキーム名を取得（グローバル変数で追跡、なければvim.g.colors_nameを使用）
  local current = vim.g.current_colorscheme or vim.g.colors_name or "tokyonight"
  local current_idx = 1
  for i, cs in ipairs(colorschemes) do
    if cs == current then
      current_idx = i
      break
    end
  end
  local next_idx = (current_idx % #colorschemes) + 1
  local next_cs = colorschemes[next_idx]
  
  -- lazyプラグインをロード（必要に応じて）
  if plugin_map[next_cs] then
    pcall(function()
      require("lazy").load({ plugins = { plugin_map[next_cs] } })
    end)
    -- 少し待ってからカラースキームを適用
    vim.defer_fn(function()
      local success, err = pcall(vim.cmd.colorscheme, next_cs)
      if success then
        vim.g.current_colorscheme = next_cs
        -- 透過設定を再適用
        require("config.highlight").setup()
        vim.notify("Colorscheme: " .. next_cs, vim.log.levels.INFO)
      else
        vim.notify("Failed: " .. next_cs .. " - " .. tostring(err), vim.log.levels.ERROR)
      end
    end, 100)
  else
    -- ビルトインまたは既にロード済みのカラースキーム
    local success, err = pcall(vim.cmd.colorscheme, next_cs)
    if success then
      vim.g.current_colorscheme = next_cs
      -- 透過設定を再適用
      require("config.highlight").setup()
      vim.notify("Colorscheme: " .. next_cs, vim.log.levels.INFO)
    else
      vim.notify("Failed: " .. next_cs .. " - " .. tostring(err), vim.log.levels.ERROR)
    end
  end
end, { desc = "Switch colorscheme" })

-- コード実行（フローティングウィンドウにフォーカスを移動）
local function focus_floating_window()
  vim.defer_fn(function()
    local wins = vim.api.nvim_list_wins()
    for _, win in ipairs(wins) do
      local ok, config = pcall(vim.api.nvim_win_get_config, win)
      if ok and config and config.relative and config.relative ~= "" then
        pcall(vim.api.nvim_set_current_win, win)
        -- ターミナルモードに入る（入力を受け付けるため）
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == "terminal" then
          vim.cmd("startinsert")
        end
        break
      end
    end
  end, 150)
end

map("n", "<leader>r", function()
  vim.cmd("RunCode")
  focus_floating_window()
end, { desc = "Run code" })
map("n", "<leader>rf", function()
  vim.cmd("RunFile")
  focus_floating_window()
end, { desc = "Run file" })
map("n", "<leader>rp", function()
  vim.cmd("RunProject")
  focus_floating_window()
end, { desc = "Run project" })
map("n", "<leader>rc", ":RunClose<CR>", { desc = "Close runner" })

-- デバッグ用
map("n", "<leader>el", ":messages<CR>", { desc = "Show messages" })
map("n", "<leader>ec", ":checkhealth<CR>", { desc = "Check health" })
map("n", "<leader>es", ":Lazy<CR>", { desc = "Lazy status" })
