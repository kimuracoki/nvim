-- 全 Lua ファイルの構文チェック（`nvim -l scripts/syntax.lua`）。
-- プラグインも設定も読み込まないので数十 ms で終わる。編集直後の取りこぼしを拾う用。
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")

local files = {}
for _, pattern in ipairs({ "/init.lua", "/lua/**/*.lua", "/snippets/**/*.lua", "/ftplugin/**/*.lua" }) do
  vim.list_extend(files, vim.fn.glob(root .. pattern, false, true))
end

local failed = 0
for _, file in ipairs(files) do
  local _, err = loadfile(file)
  if err then
    failed = failed + 1
    io.stderr:write(err .. "\n")
  end
end

if failed > 0 then
  io.stderr:write(("syntax NG: %d / %d files\n"):format(failed, #files))
  os.exit(1)
end
print(("syntax OK: %d files"):format(#files))
