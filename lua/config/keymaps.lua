local map = vim.keymap.set

-- 保存
map("n", "<C-s>", ":w<CR>", { desc = "Save" })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save" })

-- バッファ移動（Buffer操作）
map("n", "<S-h>", ":BufferLineCyclePrev<CR>", { desc = "Buffer: Previous" })
map("n", "<S-l>", ":BufferLineCycleNext<CR>", { desc = "Buffer: Next" })
map("n", "<leader>bc", function()
  -- 他にバッファがあれば前のバッファに移動してから削除
  local buf_count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_option(buf, "buflisted") then
      buf_count = buf_count + 1
    end
  end

  if buf_count > 1 then
    vim.cmd("bprevious")
  end
  vim.cmd("bdelete #")
end, { desc = "Buffer: Close" })

-- ウィンドウ移動
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- ウィンドウリサイズ（leader + whjkl）
map("n", "<leader>wh", "<C-w><", { desc = "Resize: Decrease width" })
map("n", "<leader>wl", "<C-w>>", { desc = "Resize: Increase width" })
map("n", "<leader>wk", "<C-w>+", { desc = "Resize: Increase height" })
map("n", "<leader>wj", "<C-w>-", { desc = "Resize: Decrease height" })

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

-- これらのターミナルでは jk マッピングを設定しない（j の遅延を防ぐ）
local function is_terminal_no_jk_mapping()
  local bufname = vim.api.nvim_buf_get_name(0)
  return bufname:match("claude") or bufname:match("ClaudeCode") or bufname:match("lazygit")
end

map("t", "<Esc>", function()
  if is_terminal_no_jk_mapping() then
    -- Claude/lazygit などではそのまま<Esc>を送信
    return "<Esc>"
  else
    return [[<C-\><C-n>]]
  end
end, { expr = true, desc = "Terminal: Exit to normal mode (except Claude/lazygit)" })

-- jk は通常ターミナルのみバッファローカルで設定（Claude/lazygit では j の遅延を防ぐため設定しない）
vim.api.nvim_create_autocmd("TermEnter", {
  callback = function()
    if not is_terminal_no_jk_mapping() then
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], { noremap = true, buffer = true, desc = "Terminal: jk to normal mode" })
    end
  end,
  desc = "Set jk mapping only in normal terminals (not Claude/lazygit)",
})

-- ターミナルモードでもウィンドウ移動をノーマルモードと同じキーで行えるようにする
-- （Claude Codeを含め、どのターミナルでも有効）
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { silent = true, desc = "Terminal: Move to left window" })
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { silent = true, desc = "Terminal: Move to bottom window" })
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { silent = true, desc = "Terminal: Move to top window" })
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { silent = true, desc = "Terminal: Move to right window" })

-- ターミナルモードでもウィンドウリサイズ（leader + whjkl）
map("t", "<leader>wh", [[<C-\><C-n><C-w><]], { silent = true, desc = "Terminal: Resize decrease width" })
map("t", "<leader>wl", [[<C-\><C-n><C-w>>]], { silent = true, desc = "Terminal: Resize increase width" })
map("t", "<leader>wk", [[<C-\><C-n><C-w>+]], { silent = true, desc = "Terminal: Resize increase height" })
map("t", "<leader>wj", [[<C-\><C-n><C-w>-]], { silent = true, desc = "Terminal: Resize decrease height" })

map("n", "<leader>tt", function()
  require("toggleterm").toggle(1)
end, { desc = "Terminal: Toggle" })

-- ターミナル個別切り替え
map("n", "<leader>t1", function()
  require("toggleterm").toggle(1)
end, { desc = "Terminal: Toggle 1" })

map("n", "<leader>t2", function()
  require("toggleterm").toggle(2)
end, { desc = "Terminal: Toggle 2" })

map("n", "<leader>t3", function()
  require("toggleterm").toggle(3)
end, { desc = "Terminal: Toggle 3" })

-- ターミナル選択と一括操作
map("n", "<leader>ts", ":TermSelect<CR>", { desc = "Terminal: Select" })
map("n", "<leader>ta", ":ToggleTermToggleAll<CR>", { desc = "Terminal: Toggle all" })

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
