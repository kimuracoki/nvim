local platform = require("config.platform")

-- 実行コマンドの OS 差分。決め打ちにすると「その OS にだけ無いコマンド」で黙って失敗する。
--   python3 : Windows の公式インストーラは python.exe しか置かない
--   open    : mac 専用。Windows は start（cmd 経由）、Linux は xdg-open
local python = platform.first({ "python3", "python" }) or "python3"
local opener = platform.is_windows and "cmd /c start \"\"" or (platform.is_mac and "open" or "xdg-open")

return {
  ---------------------------------------------------------------------------
  -- コード実行（Code Runner）
  ---------------------------------------------------------------------------
  {
    "CRAG666/code_runner.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "RunCode", "RunFile", "RunProject", "RunClose" },
    config = function()
      require("code_runner").setup({
        -- 実行モード: "toggleterm" または "float"
        mode = "float",
        -- フローティングウィンドウの設定（mode = "float"の場合）
        float = {
          border = "rounded",
          height = 0.8,
          width = 0.8,
          x = 0.5,
          y = 0.3,
        },
        -- ターミナルの設定（mode = "toggleterm"の場合）
        term = {
          position = "bot",
          size = 10,
        },
        -- 言語別の実行コマンド
        filetype = {
          python = python .. " -u",
          java = "cd $dir && javac $fileName && java $fileNameWithoutExt",
          cpp = "cd $dir && g++ -std=c++17 $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt",
          c = "cd $dir && gcc $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt",
          rust = "cd $dir && rustc $fileName && $dir/$fileNameWithoutExt",
          go = "cd $dir && go run $fileName",
          javascript = "node",
          typescript = "tsx",
          html = opener,
          sh = "bash",
          lua = "lua",
          ruby = "ruby",
          php = "php",
          haskell = "runhaskell",
          lisp = "sbcl --noinform --load $fileName --quit",
          csharp = "cd $dir && dotnet run",
        },
        -- 実行前に保存
        save_before_run = true,
        -- 実行時に挿入モードで開始（入力を受け付けるため）
        startinsert = true,
      })
    end,
  },
}
