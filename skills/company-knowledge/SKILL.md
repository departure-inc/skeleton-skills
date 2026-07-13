---
name: company-knowledge
description: >-
  Resolves and reads the company knowledge corpus (design standards, methodology,
  tech standards, architecture patterns) with progressive disclosure. Use when
  organizational conventions, 社内規約, 設計標準, メソドロジ, 見積, 営業プロセス,
  技術標準, Rails/Next 社内方針, architecture samples, or company OS knowledge
  are needed — not for product-specific code in the current repo alone.
---

# company-knowledge

社内ナレッジの正本はマシンに1つ。各プロダクトリポジトリには置かない。
中身は埋め込まず、解決したルート配下の Markdown を必要な分だけ読む。

## Resolve root

優先順:

1. 環境変数 `COMPANY_KNOWLEDGE_ROOT`（存在するディレクトリ）
2. `~/.config/company/knowledge-root`（1行の絶対パス。`XDG_CONFIG_HOME` があればそちら）
3. `$HOME/.config/company/skeleton`

可能なら先にスクリプトを実行する:

```bash
sh scripts/resolve-root.sh
```

（この Skill ディレクトリからの相対パス。インストール先では Skill 配下の同名スクリプト。）

解決できない場合は、ユーザーに env か設定ファイルの設定を依頼して止まる。推測パスで進めない。

## Read order

1. `$ROOT/_general/README.md`（地図）
2. 該当領域の `README.md` / `_index.md`
3. 必要な個別 Markdown のみ

領域の当たりは [references/map-cheatsheet.md](references/map-cheatsheet.md) を参照。

## Rules

- 正本に無い内容を社内規約として断定しない
- 読んだファイルのパスを根拠にしてから提案する
- 全文をコンテキストに詰め込まない（地図 → 領域 → 個別）
- プロダクト固有の話は現在のリポジトリを優先し、社内横断知だけこの正本を使う

## Always-on snippet

各ツールの「常時ルール」には本文を増やさず、[references/always-on-snippet.md](references/always-on-snippet.md) をコピーする。
