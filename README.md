# Skeleton Skills

Cursor / Claude エージェント向けの汎用スキル集です。

## Productivity

### このリポジトリ (`departure-inc/skeleton-skills`)

| スキル | 説明 |
|--------|------|
| `kabe` | リードエンジニアとしてアプリケーション設計の壁打ちを行う |
| `issue` | 壁打ちしながら GitHub ISSUE の設計ドキュメントを作成する |
| `bdd` | コード実装前に Given/When/Then 形式の振る舞いシナリオを定義する |
| `implement` | GitHub ISSUE の番号を受け取り、BDD シナリオ定義 → TDD で実装する |
| `pr` | 現在のブランチの変更から PR タイトル・本文を生成して投稿する |

### ワークフロー

```
設計:
  kabe（設計壁打ち）
    └─ issue（GitHub Issue 作成）

実装（Issue の規模でルートを選択）:
  軽量ルート（単一 Issue をそのまま実装）:
    issue ─▶ implement（BDD シナリオ定義 → TDD 実装）

  重量ルート（大きな機能を計画的に実装）:
    issue ─▶ writing-plans（実装計画書作成）
               └─ executing-plans（計画実行。各タスクで bdd を併用）

横断ガード（フェーズを問わず自動発火）:
  ├─ systematic-debugging（バグ・テスト失敗時）
  └─ verification-before-completion（完了宣言前の検証）

仕上げ:
  requesting-code-review（レビュー依頼）
    └─ pr（PR 投稿）

フロントエンド実装時（並走）:
  ├─ next-best-practices
  └─ web-design-guidelines
```

### 外部スキル (`skills-lock.json` 参照)

| スキル | ソース | 説明 |
|--------|--------|------|
| `find-skills` | vercel-labs/skills | セッション内でスキルを検索・追加 |
| `frontend-design` | anthropics/skills | 高品質フロントエンド UI 生成 |
| `vercel-react-best-practices` | vercel-labs/agent-skills | React/Next.js パフォーマンス最適化 |
| `grill-me` | mattpocock/skills | コードをソクラテス式問答でレビュー |
| `writing-plans` | obra/superpowers | 実装計画書を作成 |
| `executing-plans` | obra/superpowers | 計画書を読んでタスクを逐次実行 |
| `systematic-debugging` | obra/superpowers | 根本原因調査から始めるデバッグ |
| `verification-before-completion` | obra/superpowers | 完了宣言前の検証ゲート |
| `requesting-code-review` | obra/superpowers | サブエージェントによるコードレビュー依頼 |
| `next-best-practices` | vercel-labs/next-skills | Next.js ファイル規約・RSC・データパターン |
| `web-design-guidelines` | vercel-labs/agent-skills | UI のデザイン・アクセシビリティ監査 |

## Installation

```sh
curl -fsSL https://raw.githubusercontent.com/departure-inc/skeleton-skills/main/install.sh | sh
```

`skills-lock.json` と各スキルがローカルにインストールされます。


## Usage

`skills/<name>/SKILL.md` を追加・編集してください。フロントマターに `name` と `description` を記載します。

```markdown
---
name: my-skill
description: スキルのトリガー条件と概要
---

スキルの指示内容
```
