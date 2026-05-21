---
name: implement
description: GitHub ISSUEの番号を受け取り、内容を読んで実装する。/implement <issue番号> の形式で呼ぶ。「このISSUEを実装して」「#123を実装して」「issue番号を指定して実装させたい」などの文脈でも使用する。
disable-model-invocation: true
---

## 使い方

```
/implement <issue番号>
```

---

## 手順

### 1. ISSUEを取得する

ユーザーが入力したISSUE番号を使い、リポジトリを自動検出してISSUE内容を取得する。

```bash
REPO=$(git remote get-url origin | sed 's/.*github.com[:/]//' | sed 's/\.git$//')
gh issue view <番号> --repo "$REPO" --json number,title,body,labels,assignees,comments
```

### 2. コンテキストを把握する

- AGENTS.md（または LLM.md）を読んでプロジェクト規約を確認する
- ISSUEのタイトル・本文・ラベル・コメントを読んで実装内容を把握する
- 関連しそうなファイル（モデル・コントローラ・ビュー・ルーティング等）を調査する
- 既存の類似実装があればそれを参考にする

### 3. 実装方針を提示する

実装に入る前に、以下を簡潔にチャットで提示してユーザーに確認する：

- 変更するファイルの一覧
- 実装の概要（1〜3行）
- 不明点・前提確認が必要な点（あれば）

ユーザーが「OK」「進めて」などの確認を返したら次のフェーズに進む。
不明点があれば一問ずつ質問する。

### 4. BDD シナリオを定義する

**コードに手を付ける前に振る舞いシナリオを定義する。**

ISSUE の Acceptance Criteria と実装方針をもとに、以下の観点でシナリオを洗い出す：

- 正常系（ハッピーパス）
- 異常系・エッジケース
- 権限・認証が絡む場合はロール別の挙動

各シナリオを Given/When/Then 形式で記述し、チャットに出力してユーザーに確認する：

```gherkin
Feature: [機能名]

  Scenario: [正常系の説明]
    Given [初期状態]
    When  [ユーザーの操作]
    Then  [期待される結果]

  Scenario: [異常系の説明]
    Given ...
    When  ...
    Then  ...
```

**シナリオ記述ルール:**
- 1 シナリオ = 1 振る舞い（複数の振る舞いを混在させない）
- 実装の詳細（メソッド名・クラス名）を書かない
- ユーザー視点の言葉を使う

ユーザーの承認を得てから、シナリオを RSpec feature spec / system spec として `spec/features/` または `spec/system/` に配置する。

### 5. 実装する（Red → Green → Refactor）

BDD シナリオを自動化したスペックを先に書き（Red）、それを通す実装をする（Green）。

プロジェクト規約・既存パターンに従って実装する。

- マイグレーションが必要な場合は生成する
- Slim・Stimulus・RuboCop など、プロジェクトの規約に従う
- rspec, rubocop, slim-lint が通ることを確認する

### 6. 完了報告

実装完了後、以下を報告する：

- 変更したファイルの一覧と変更内容の要約
- rspec, rubocop, slim-lint の実行結果
- 動作確認の手順（必要に応じて）
- 残タスク・スキップした事項（あれば）

---

## 注意事項

- ISSUEに書かれていない仕様上の曖昧さは、BDDシナリオ定義前にユーザーに一問ずつ確認する
- 大規模な変更になる場合は、実装前に方針を提示して承認を得る
- `gh` コマンドはリポジトリの自動検出後に実行する
- AGENTS.md がある場合は必ず読んでから実装を始める
