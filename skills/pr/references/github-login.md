# GitHub ログイン（playwright-cli）

PR 本文への画像埋め込みでは、コメント欄の添付 UI を **URL 取得専用** に使う。
そのため Playwright 側で GitHub にログインしたセッションが必要。

## なぜ `--headed` が必要か

- `playwright-cli open` のデフォルトは **headless**（画面なし）
- 画面が出ないので、ユーザーがログインできない
- **通常の Chrome / Safari でログインしても Playwright セッションには乗らない**

## パス

| 用途 | パス |
|------|------|
| storage state | `~/.config/playwright/github-state.json` |
| persistent profile | `~/.config/playwright/github-profile` |

どちらもユーザー単位の認証情報。リポジトリには置かない。

## 初回セットアップ

```bash
mkdir -p "$HOME/.config/playwright"

playwright-cli open --headed --persistent --profile "$HOME/.config/playwright/github-profile" \
  "https://github.com/login"
```

1. 開いた **Playwright 用 Chrome ウィンドウ** で GitHub にログインする
2. プライベートリポジトリの PR ページが見えることまで確認する
3. state を保存する

```bash
playwright-cli state-save "$HOME/.config/playwright/github-state.json"
```

最小コマンド例（profile なし）:

```bash
playwright-cli open --headed "https://github.com/login"
# ログイン後
playwright-cli state-save "$HOME/.config/playwright/github-state.json"
```

## 2回目以降

```bash
# state を読み込む
playwright-cli state-load "$HOME/.config/playwright/github-state.json"
playwright-cli open "https://github.com/<owner>/<repo>/pull/<N>"

# または persistent profile を再利用（headed は不要なことが多い）
playwright-cli open --persistent --profile "$HOME/.config/playwright/github-profile" \
  "https://github.com/<owner>/<repo>/pull/<N>"
```

## 期限切れ・未ログイン時

次のサインがあれば初回セットアップをやり直す。

- PR が 404（プライベートリポジトリで未ログイン時によく出る）
- ページに Sign in がある
- `github-state.json` が無い

## よくある誤解

| 誤解 | 実態 |
|------|------|
| いつも使っている Chrome でログインすればよい | Playwright は別 profile。`--headed` のウィンドウでログインする |
| `gh auth login` 済みなら不要 | `gh` の認証とブラウザセッションは別物 |
| headless のままログインできる | 画面が無いので手動ログイン不可 |
