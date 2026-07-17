# Skeleton Skills

Cursor / Claude エージェント向けの汎用スキル集です。

## Productivity

### このリポジトリ (`departure-inc/skeleton-skills`)

| スキル | 説明 |
|--------|------|
| `company-knowledge` | 社内ナレッジ・プロジェクト資料正本を解決し、地図→領域→個別の順で読む |
| `kabe` | リードエンジニアとしてアプリケーション設計の壁打ちを行う |
| `issue` | 壁打ちしながら GitHub ISSUE の設計ドキュメントを作成する |
| `prototype` | チャットでデザインをやり取りしながら Next.js + shadcn/ui + Tailwind CSS でプロトタイプをライブ構築する（動くプレビューを隣に常時表示） |
| `bdd` | コード実装前に Given/When/Then 形式の振る舞いシナリオを定義する |
| `implement` | GitHub ISSUE の番号を受け取り、BDD シナリオ定義 → TDD で実装する |
| `pr` | 現在のブランチの変更から PR タイトル・本文を生成して投稿する（フロント差分時は playwright-cli でスクショ埋め込み可） |
| `skeleton-generator` | skeleton-generator gem を Rails プロジェクトにインストールする |

### モデル / effort の使い分け

SKILL.md 自体には model / effort を指定するフロントマターがない（それを持てるのは `.claude/agents/*.md` のサブエージェント定義のみ）。そのため使い分けは以下の方針で行う。

| 種別 | 対象スキル | 方針 |
|------|-----------|------|
| 対話系（一問ずつユーザーと往復する） | `kabe`, `issue` | サブエージェント化しない（Agent は呼び出し→自律実行→報告の一発勝負で、ターンごとの対話に不向き）。見落としコストが高い相談では、セッションのモデルを Opus に切り替えるようユーザーに提案する |
| 自律系（承認ポイントが少なく大部分を自走できる） | `implement` | 重い判断（調査・シナリオ設計）だけ Agent ツール + `model: opus` に委譲できる。実装本体はセッションのデフォルトモデルのまま進める |
| 検索・参照系 | `company-knowledge` | 機械的な読み込みが中心なのでモデル変更は不要。effort もデフォルトで十分 |
| 手続き系 | `bdd`, `pr`, `skeleton-generator`, `prototype` | 反復速度を優先し、セッションのデフォルトモデル・デフォルトeffortのまま。深さが必要なら指示文の書き込み量で調整する（`code-review` スキルの `low/medium/high/xhigh/max` と同じ考え方） |

### ワークフロー

```
設計:
  kabe（設計壁打ち）
    └─ issue（GitHub Issue 作成）

プロトタイピング:
  prototype（動くプレビューを見ながらライブ構築）
    └─ issue（本実装に進む場合は ISSUE 化）

実装（Issue の規模でルートを選択）:
  軽量ルート（単一 Issue をそのまま実装）:
    issue ─▶ implement（BDD シナリオ定義 → TDD 実装）

  重量ルート（大きな機能を計画的に実装）:
    issue ─▶ writing-plans（実装計画書作成）
               └─ executing-plans（計画実行。各タスクで bdd を併用）

横断（社内知・フェーズを問わず）:
  └─ company-knowledge（社内規約・設計標準・メソドロジが必要なとき）

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

#### カレントプロジェクトにインストール

```sh
curl -fsSL https://raw.githubusercontent.com/departure-inc/skeleton-skills/main/install.sh | sh
```

#### グローバル（$HOME）にインストール — 全プロジェクト共通

```sh
curl -fsSL https://raw.githubusercontent.com/departure-inc/skeleton-skills/main/install.sh | sh -s -- --global
```

`skills-lock.json` と各スキルの実体（`.agents/skills/`）がインストールされ、Claude Code が参照する `.claude/skills/` に不足分のシンボリックリンクが自動作成されます（既存リンクには触れません）。


## company-knowledge（社内ナレッジ）

正本は各プロダクトに置かず、マシン上の社内ナレッジ・プロジェクト資料正本を1つ参照する。

ルート解決順:

1. `COMPANY_KNOWLEDGE_ROOT`
2. `~/.config/company/knowledge-root`（1行の絶対パス）
3. `$HOME/.config/company/skeleton`

常時ルール用の極薄文面は `skills/company-knowledge/references/always-on-snippet.md`。
Cursor User Rules と Claude Code の `~/.claude/CLAUDE.md` など、ツール側のグローバル指示に同じsnippetを置く（Skill 本体は Cursor / Claude 共通）。

## Usage

`skills/<name>/SKILL.md` を追加・編集してください。フロントマターに `name` と `description` を記載します。

```markdown
---
name: my-skill
description: スキルのトリガー条件と概要
---

スキルの指示内容
```
