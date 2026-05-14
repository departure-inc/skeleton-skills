# Skeleton Skills

Cursor / Claude エージェント向けの汎用スキル集です。

## Productivity

### このリポジトリ (`departure-inc/skeleton-skills`)

| スキル | 説明 |
|--------|------|
| `kabe` | リードエンジニアとしてアプリケーション設計の壁打ちを行う |
| `issue` | 壁打ちしながら GitHub ISSUE の設計ドキュメントを作成する |
| `implement` | GitHub ISSUE の番号を受け取り、内容を読んで実装する |
| `pr` | 現在のブランチの変更から PR タイトル・本文を生成して投稿する |

外部スキルに関しては`skills-lock.json`を確認してください。

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
