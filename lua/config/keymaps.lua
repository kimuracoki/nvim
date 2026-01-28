local map = vim.keymap.set

-- 保存
map("n", "<C-s>", ":w<CR>", { desc = "Save" })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save" })

-- バッファ移動（Buffer操作）
map("n", "<S-h>", ":BufferLineCyclePrev<CR>", { desc = "Buffer: Previous" })
map("n", "<S-l>", ":BufferLineCycleNext<CR>", { desc = "Buffer: Next" })
map("n", "<leader>bc", ":bdelete<CR>", { desc = "Buffer: Close" })

-- ウィンドウ移動
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- jkでノーマルモードに戻る
map("i", "jk", "<Esc>", { noremap = true })

-- 全選択（All）
map("n", "<leader>a", "ggVG", { desc = "All: Select all" })
map("n", "<C-a>", "ggVG", { desc = "All: Select all" })

-- コピー・ペースト
map("v", "<C-c>", '"+y', { desc = "Copy" })
map({ "n", "i" }, "<C-v>", '"+p', { desc = "Paste" })

-- アンドゥ・リドゥ
map("n", "<C-z>", "u", { desc = "Undo" })
map("n", "<C-S-z>", "<C-r>", { desc = "Redo" })

-- ターミナル（Terminal）
-- Claude Codeのターミナルでは除外（キー競合を避けるため）
local function is_claude_terminal()
  local bufname = vim.api.nvim_buf_get_name(0)
  return bufname:match("claude") or bufname:match("ClaudeCode")
end

map("t", "<Esc>", function()
  if is_claude_terminal() then
    -- Claude Codeではそのまま<Esc>を送信
    return "<Esc>"
  else
    return [[<C-\><C-n>]]
  end
end, { expr = true, desc = "Terminal: Exit to normal mode (except Claude)" })

map("t", "jk", function()
  if is_claude_terminal() then
    -- Claude Codeではそのままjkを送信
    return "jk"
  else
    return [[<C-\><C-n>]]
  end
end, { expr = true, desc = "Terminal: Exit to normal mode (except Claude)" })

map("n", "<leader>tt", function()
  require("toggleterm").toggle(1)
end, { desc = "Terminal: Toggle" })

-- ウィンドウ（Window）
map("n", "<leader>ww", function()
  require("config.startup").setup_layout()
end, { desc = "Window: Setup layout" })

-- 終了（Quit）
map("n", "<leader>q", ":qa<CR>", { desc = "Quit: All" })

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
end, { desc = "Code: Action" })

-- 診断（eXamine/Diagnostics）
map("n", "<leader>xd", function()
  vim.diagnostic.open_float()
end, { desc = "Diagnostics: Show at cursor" })

map("n", "[d", function()
  vim.diagnostic.goto_prev()
end, { desc = "Previous diagnostic" })

map("n", "]d", function()
  vim.diagnostic.goto_next()
end, { desc = "Next diagnostic" })

-- カラースキーム切り替え（UI Theme）
map("n", "<leader>ut", function()
  local colorschemes = {
    "catppuccin",
    "tokyonight",
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
  local current = vim.g.current_colorscheme or vim.g.colors_name or "catppuccin"
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
end, { desc = "UI: Theme switch" })

-- 透過度切り替え（UI Transparency）
map("n", "<leader>uo", function()
  require("config.highlight").toggle_transparency()
end, { desc = "UI: Toggle transparency" })

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

map("n", "<leader>rr", function()
  vim.cmd("RunCode")
  focus_floating_window()
end, { desc = "Run: Code" })
map("n", "<leader>rf", function()
  vim.cmd("RunFile")
  focus_floating_window()
end, { desc = "Run: File" })
map("n", "<leader>rp", function()
  vim.cmd("RunProject")
  focus_floating_window()
end, { desc = "Run: Project" })
map("n", "<leader>rc", ":RunClose<CR>", { desc = "Run: Close" })

-- Help/Health関連（診断・ログ）
map("n", "<leader>hm", ":messages<CR>", { desc = "Help: Messages log" })
map("n", "<leader>hc", ":checkhealth<CR>", { desc = "Help: Checkhealth" })

-- Lazy（プラグイン管理）
map("n", "<leader>ll", ":Lazy<CR>", { desc = "Lazy: Status" })
map("n", "<leader>ls", ":Lazy sync<CR>", { desc = "Lazy: Sync" })
