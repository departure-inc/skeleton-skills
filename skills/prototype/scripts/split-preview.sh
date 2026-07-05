#!/bin/sh
# プロトタイプのライブプレビュー：Web アプリを右側に表示する
# - cmux 内で実行された場合：cmux を右に分割して browser ペインで URL を表示
# - それ以外：Chrome（なければデフォルトブラウザ）で URL を開く（ウィンドウ位置は動かさない）
# 使い方: split-preview.sh [URL]（デフォルト: http://localhost:3000）
# 注意: 再実行するたびに cmux のペインが増えるので、初回のみ実行すること
set -e

URL="${1:-http://localhost:3000}"

if [ -n "$CMUX_BUNDLE_ID" ] && command -v cmux >/dev/null 2>&1; then
  cmux new-pane --type browser --direction right --url "$URL" --focus false
  echo "==> cmux の右ペインに ${URL} を表示しました"
elif [ -d "/Applications/Google Chrome.app" ]; then
  open -a "Google Chrome" "$URL"
  echo "==> Chrome で ${URL} を開きました"
elif command -v open >/dev/null 2>&1; then
  open "$URL"
  echo "==> デフォルトブラウザで ${URL} を開きました"
elif command -v google-chrome >/dev/null 2>&1; then
  google-chrome "$URL" >/dev/null 2>&1 &
  echo "==> Chrome で ${URL} を開きました"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$URL"
  echo "==> ブラウザで ${URL} を開きました"
else
  echo "ブラウザで ${URL} を開いてください" >&2
fi
