#!/usr/bin/env bash
# この設定を変更したあとに必ず通す確認。CI 相当のものはこれ 1 本にまとめてある。
#   1. 構文チェック（全 Lua ファイル）
#   2. 実際に起動してロードエラー・非推奨 API 警告が出ないこと
#   3. キーマップの棚卸し（定義 / which-key / cheatsheet の 3 点セット漏れが 0 件）
# 使い方: ./scripts/check.sh
set -uo pipefail
cd "$(dirname "$0")/.."
status=0

echo "== 1/3 構文チェック =="
nvim -l scripts/syntax.lua || status=1

echo "== 2/3 起動ロードチェック =="
# 実ファイルを開いた状態で起動する（空バッファだと遅延ロードのプラグインが読まれず素通りする）
load_log=$(nvim --headless lua/config/keymaps.lua \
  -c "lua vim.defer_fn(function() vim.cmd('qa!') end, 2000)" 2>&1 |
  grep -iE "error|warn|deprecat|invalid|no longer" || true)
if [ -n "$load_log" ]; then
  echo "$load_log"
  status=1
else
  echo "ロードエラー・非推奨警告なし"
fi

echo "== 3/3 キーマップ棚卸し =="
audit=$(nvim --headless lua/config/keymaps.lua \
  -c 'lua vim.defer_fn(function() print(require("config.cheatsheet").audit_report()); vim.cmd("qa!") end, 2500)' 2>&1 |
  tr -d '\r')
echo "$audit"
case "$audit" in
  *uncovered=0*) ;;
  *) status=1 ;;
esac

if [ "$status" -eq 0 ]; then
  echo "OK: すべて通過"
else
  echo "NG: 上の項目を直してから完了とすること"
fi
exit "$status"
