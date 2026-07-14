---
name: pr
description: 現在のブランチの変更からPRタイトル・本文を生成してGitHubに投稿する。フロント差分がある場合は playwright-cli で画面スクショを撮影し、PR 本文の Screenshots に埋め込む。/pr コマンドが呼び出されたとき、または「PRを作りたい」「プルリクを出して」「PR作成して」「プルリクエストを作成して」などの文脈で積極的に使用する。
disable-model-invocation: true
---

現在のブランチの変更から PR を作成する。フロント差分がある場合は、任意で画面スクショを PR 本文に埋め込む。

## 手順

### 1. 変更内容を確認する

```bash
git diff main...HEAD --stat
git log main...HEAD --oneline
git diff main...HEAD
```

マージベースが `main` でない場合は `git merge-base HEAD origin/HEAD` で特定する。

### 2. スクリーンショット要否を判断する

差分パスが次のいずれかに当たる場合、フロント差分ありとみなす。

- `app/` `pages/` `components/` `src/components/` `src/app/` `app/views/`
- `*.tsx` `*.jsx` `*.vue` `*.svelte` `*.css` `*.scss` `*.module.css` `*.html.slim` `*.html.erb`

該当したら「スクリーンショットを PR に付けますか？（推奨: Yes）」と確認する。
該当しなくても、ユーザーが希望すればスクショフローに入ってよい。

### 3. PRタイトル・本文を生成する

変更内容を読んで本文を生成する。リポジトリに `.github/PULL_REQUEST_TEMPLATE.md` があればそれを読んでフォーマットとして使用する。

**フォーマット（テンプレートがない場合のデフォルト）:**

```markdown
# WHY

[なぜこの変更が必要か・解決する課題]

- #issue番号

# WHAT

- [変更点 1]
- [変更点 2]
- [変更点 3]
```

スクショを付ける場合は、本文末尾に空の枠 `## Screenshots` を追加する（中身は後で埋める）。

複数枚のときは、後から次のような見出しで埋める前提にしておく。

```markdown
## Screenshots

### search-form

![search-form](URL)

### settings

![settings](URL)
```

**タイトル:** コミットメッセージや変更内容から簡潔に生成する（例: `feat: 検索フォームにオートサブミット機能を追加`）

生成した内容をチャットに出力してユーザーに確認を求める。
修正依頼があれば修正してから次へ進む。

### 4. gh pr create で GitHub に投稿する

ユーザーの承認を得たら実行する。

```bash
gh pr create \
  --title "<生成したタイトル>" \
  --body "<生成した本文>" \
  --base main
```

ベースブランチが `main` でない場合はユーザーに確認する。
作成後の PR URL（`https://github.com/<owner>/<repo>/pull/<N>`）を控える。

スクショ不要ならここで URL を出力して終了する。

### 5. 撮影 URL を確定する（スクショありの場合）

差分から候補 URL を提示し、ユーザーに確定してもらう（ハイブリッド）。

- ベースはローカルの開発サーバー（例: `http://localhost:3000`）を既定候補にする
- 変更されたルート／ページからパス候補を出す
- ユーザーが URL・枚数・ラベル（例: `search-form`）を確定してから撮影する
- 開発サーバーが起動していない場合は起動を促す



### 6. playwright-cli で撮影する

```bash
playwright-cli open "<確定URL>"
playwright-cli screenshot --filename="/tmp/pr-screenshot-<label>.png"
```

必要なら `snapshot` で要素を確認し、特定要素だけ撮る。
複数 URL なら繰り返す。

### 7. GitHub に画像をアップロードし、asset URL を取得する

`gh` API では画像アップロードできないため、コメント欄の添付 UI を **URL 取得専用** に使う。
**コメントは投稿しない。**

#### 前提: GitHub ログイン state

初回は `--headed` でログインが必要（通常の Chrome ログインでは代用不可）。
手順・パス・トラブルシュートは [references/github-login.md](references/github-login.md) を読む。

state / profile が無い／期限切れなら、同ドキュメントの初回セットアップを案内してから続ける。

#### アップロードと URL 抽出

```bash
playwright-cli open "https://github.com/<owner>/<repo>/pull/<N>"
playwright-cli snapshot
# 「Paste, drop, or click to add files」相当の要素を click
playwright-cli click <ref>
playwright-cli upload "/tmp/pr-screenshot-<label>.png"
```

テキストエリア（`#new_comment_field`）に自動挿入された内容から `user-attachments` URL を抜く。
挿入形式は markdown とは限らず、次のような HTML になることもある。

```html
<img width="1280" height="720" alt="..." src="https://github.com/user-attachments/assets/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" />
```

URL を控えたら、コメント欄を空にする（誤投稿防止）。投稿ボタンは押さない。

```bash
playwright-cli fill <textarea-ref> ""
```

複数枚なら upload → URL 抽出 → クリア を繰り返す。

### 8. PR 本文の Screenshots を埋める

取得した URL で本文を更新する。

```bash
gh pr edit <N> --body "$(cat <<'EOF'
# WHY
...

# WHAT
...

## Screenshots

### <label>

![<label>](https://github.com/user-attachments/assets/...)

EOF
)"
```

または現在の本文を取得して、**行頭の** `## Screenshots` セクションだけ置換してもよい。
本文中のインライン言及（例: `` `## Screenshots` ``）に誤ヒットしないよう注意する。

```bash
gh pr view <N> --json body -q .body
```



### 9. 完了

PR URL を出力する。撮影・upload に失敗した場合は、スクショ無しのまま URL を返し、失敗内容を短く伝える（PR 作成自体は成功扱い）。

---



## 注意事項

- PR 本文は**日本語**で記載する
- 本文生成後、必ずユーザーの確認を得てから `gh pr create` を実行する
- タイトルは変更の種別（`feat` / `fix` / `refactor` 等）をプレフィックスに含める
- 既に PR が存在する場合は `gh pr view` で確認し、`gh pr edit` で更新するか聞く
- 画像 upload はコメント欄 UI 経由だが、**ブラウザからコメントを投稿しない**（本文更新は `gh pr edit`）
- GitHub ログインの詳細は [references/github-login.md](references/github-login.md)
- Playwright 操作は最小限（open → upload → URL 抽出 → クリア）に留め、本文の構造的更新は `gh` に任せる

