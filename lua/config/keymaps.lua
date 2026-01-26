local map = vim.keymap.set

-- 保存（Ctrl+SとCmd+Sの両方に対応）
map("n", "<C-s>", ":w<CR>")
map("i", "<C-s>", "<Esc>:w<CR>a")
-- macOSのCmd+Sで保存
map("n", "<D-s>", ":w<CR>")
map("i", "<D-s>", "<Esc>:w<CR>a")

-- バッファ移動
map("n", "<leader>bn", ":bnext<CR>")
map("n", "<leader>bp", ":bprevious<CR>")
-- bufferline.nvimのタブ操作
map("n", "<S-h>", ":BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", ":BufferLineCycleNext<CR>", { desc = "Next buffer" })
map("n", "<leader>bc", ":bdelete<CR>", { desc = "Close buffer" })

-- ウィンドウ移動（VSCode ぽく）
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

map("i", "jk", "<Esc>", { noremap = true })

-- 全選択機能（Leader+A）
local function select_all()
  local mode = vim.fn.mode()
  if mode == "i" then
    vim.cmd("stopinsert")
  end
  vim.cmd("normal! ggVG")
end

-- クリップボードにコピー（Leader+C）
local function copy_to_clipboard()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    -- ビジュアルモード: 選択範囲をコピー
    vim.cmd('normal! "+y')
  else
    -- ノーマル/挿入モード: 現在の行をコピー
    vim.cmd('normal! "+yy')
  end
end

-- Leader+A: 全選択
map({ "n", "v" }, "<leader>a", select_all, { desc = "Select all" })
-- macOSのCmd+Aで全選択
map({ "n", "v", "i" }, "<D-a>", select_all, { desc = "Select all (Cmd+A)" })

-- Leader+C: クリップボードにコピー
map({ "n", "v" }, "<leader>c", copy_to_clipboard, { desc = "Copy to clipboard" })
-- macOSのCmd+Cでコピー
map({ "n", "v" }, "<D-c>", '"+y', { desc = "Copy to clipboard (Cmd+C)" })
map("i", "<D-c>", "<Esc>\"+y", { desc = "Copy to clipboard (Cmd+C)" })

-- macOSのCmd+Vでペースト
map({ "n", "i" }, "<D-v>", '"+p', { desc = "Paste from clipboard (Cmd+V)" })
map("v", "<D-v>", '"+p', { desc = "Paste from clipboard (Cmd+V)" })

-- macOSのCmd+Xでカット
map({ "n", "v" }, "<D-x>", '"+x', { desc = "Cut to clipboard (Cmd+X)" })
map("i", "<D-x>", "<Esc>\"+x", { desc = "Cut to clipboard (Cmd+X)" })

-- macOSのCmd+Zでアンドゥ
map({ "n", "i" }, "<D-z>", "u", { desc = "Undo (Cmd+Z)" })

-- macOSのCmd+Shift+Zでリドゥ
map({ "n", "i" }, "<D-S-z>", "<C-r>", { desc = "Redo (Cmd+Shift+Z)" })

-- ターミナルモード用キーマップ
map("t", "<Esc>", [[<C-\><C-n>]])
map("t", "jk", [[<C-\><C-n>]])

-- ToggleTermを使用したターミナル管理
-- <C-\> でターミナルをトグル（toggleterm.nvimのデフォルト）
-- 追加のターミナルを開く
map("n", "<leader>tt", function()
  require("toggleterm").toggle(1)
end, { desc = "Toggle terminal" })

-- 右側にターミナルを開く
map("n", "<leader>tv", function()
  require("toggleterm").toggle(2, nil, nil, "vertical", nil, 40)
end, { desc = "Open terminal (vertical)" })

-- Lazygitのキーマップはtoggleterm.nvimの設定で定義済み

-- すべての分割画面を開く（手動）
vim.keymap.set("n", "<leader>ww", function()
  require("config.startup").setup_layout()
end, { desc = "Setup all windows layout" })

-- 終了（すべてのウィンドウを一度に閉じる）
map("n", "<leader>q", ":qa<CR>", { desc = "Quit all" })

-- カラースキーム切り替え
map("n", "<leader>cs", function()
  local colorschemes = {
    "tokyonight",
    "catppuccin",
    "kanagawa",
    "onedark",
    "gruvbox-material",
    "gruvbox",
    "habamax",
  }
  
  -- lazyプラグイン名のマッピング
  local plugin_map = {
    catppuccin = "catppuccin",
    kanagawa = "kanagawa",
    onedark = "onedark",
    ["gruvbox-material"] = "gruvbox-material",
    gruvbox = "gruvbox",
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

-- LSP関連のキーマップ
-- ホバーでツールチップ表示（VSCode風）
map("n", "K", function()
  require("lspsaga.hover"):render_hover_doc()
end, { desc = "Show hover documentation" })

-- 診断をクイックフィックスで開く（VSCodeのProblemsパネル風）
map("n", "<leader>xx", function()
  require("trouble").toggle("document_diagnostics")
end, { desc = "Toggle document diagnostics" })
map("n", "<leader>xw", function()
  require("trouble").toggle("workspace_diagnostics")
end, { desc = "Toggle workspace diagnostics" })
map("n", "<leader>xq", function()
  require("trouble").toggle("quickfix")
end, { desc = "Toggle quickfix list" })

-- カーソル位置の診断を表示
map("n", "<leader>xd", function()
  require("lspsaga.diagnostic"):show_line_diagnostics()
end, { desc = "Show line diagnostics" })

-- 次の/前の診断にジャンプ
map("n", "[d", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Go to previous diagnostic" })
map("n", "]d", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Go to next diagnostic" })

-- コードアクション（クイックフィックス）
map({ "n", "v" }, "<leader>ca", function()
  require("lspsaga.codeaction"):code_action()
end, { desc = "Code action" })

-- 定義・参照を表示
map("n", "gd", function()
  require("lspsaga.definition"):peek_definition()
end, { desc = "Peek definition" })
map("n", "gD", function()
  vim.lsp.buf.definition()
end, { desc = "Go to definition" })
map("n", "gr", function()
  require("lspsaga.references"):peek_references()
end, { desc = "Peek references" })

