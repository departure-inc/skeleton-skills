---
name: pr
description: 現在のブランチの変更からPRタイトル・本文を生成してGitHubに投稿する。/pr コマンドが呼び出されたとき、または「PRを作りたい」「プルリクを出して」「PR作成して」「プルリクエストを作成して」などの文脈で積極的に使用する。
disable-model-invocation: true
---

## 手順

### 1. 変更内容を確認する

```bash
git diff main...HEAD --stat
git log main...HEAD --oneline
git diff main...HEAD
```

マージベースが `main` でない場合は `git merge-base HEAD origin/HEAD` で特定する。

### 2. PRタイトル・本文を生成する

変更内容を読んで、以下のフォーマットで本文を生成する。

リポジトリに `.github/PULL_REQUEST_TEMPLATE.md` があればそれを読んでフォーマットとして使用する。

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

**タイトル:** コミットメッセージや変更内容から簡潔に生成する（例: `feat: 検索フォームにオートサブミット機能を追加`）

生成した内容をチャットに出力してユーザーに確認を求める。
修正依頼があれば修正してから次へ進む。

### 3. gh pr create で GitHub に投稿する

ユーザーの承認を得たら以下を実行する。

```bash
gh pr create \
  --title "<生成したタイトル>" \
  --body "<生成した本文>" \
  --base main
```

ベースブランチが `main` でない場合はユーザーに確認する。

投稿後、PR の URL を出力する。

---

## 注意事項

- PR 本文は**日本語**で記載する
- 本文生成後、必ずユーザーの確認を得てから `gh pr create` を実行する
- タイトルは変更の種別（`feat` / `fix` / `refactor` 等）をプレフィックスに含める
- 既に PR が存在する場合は `gh pr view` で確認し、`gh pr edit` で更新するか聞く
