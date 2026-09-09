# CLAUDE.md — この Neovim 設定を触るときの前提

Neovim 0.11+ / lazy.nvim ベースの個人 IDE 設定。Mac と Windows（＋WSL・Docker コンテナ内）で
**同じリポジトリをそのまま使う**。目標は「VSCode より強力で、どの環境でも同じように動く」こと。

## まずこれを読む

編集・レビューの前に必ず `.claude/skills/nvim-config/SKILL.md` を読むこと（`/nvim-config` でも開ける）。
構成・プラグイン spec の書き方・キーマップ 3 点セット・LSP・環境堅牢性の規約はすべてそこにある。

## 絶対に外さない 5 つ

1. **環境を決め打ちしない。** OS 判定・外部コマンドの有無は必ず `lua/config/platform.lua`
   （`is_windows` / `is_mac` / `has()` / `first()`）を通す。`open` や `python3` のような
   「自分の Mac にはあるコマンド」を直書きしない。
2. **autocmd は必ず augroup（`clear = true`）に入れる。** グローバルな autocmd は対象を絞る。
3. **キーマップを足したら 3 点セット**（定義 / which-key / cheatsheet）。棚卸しは 0 件必須。
4. **「なぜこの回避策が要るか」のコメントを消さない。** 実測値つきの説明は資産。要約もしない。
5. **変更したら `./scripts/check.sh` を通す。** 通らないものは完了ではない。

## 動作確認

```bash
./scripts/check.sh          # 構文 + 起動ロード + キーマップ棚卸し（必須）
nvim -l scripts/syntax.lua  # 構文だけ（25ms。編集直後の Claude Code フックが自動実行する）
nvim --headless -c "checkhealth" -c "w /tmp/h.txt" -c "qa!"   # ERROR は 0 を保つ
```

機能を足したら**実機（実際に nvim を起動して）でも確認する**。ヘッドレスが通っただけでは
セッション復元・遅延ロード・UI の不具合は見つからない。

## やらないこと

- 自分が入れたバグを避けるために機能を削る・格下げする（原因を直す）。
- 「Mac では動くので良し」とする（Windows / コンテナで壊れていないか考える）。
- lazy-lock.json をコミットから外す（各マシンで同じ版を入れるための固定ファイル）。
