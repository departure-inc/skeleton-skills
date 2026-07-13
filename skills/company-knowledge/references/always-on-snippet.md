# Always-on snippet（極薄・ツール共通）

Cursor User Rules / Claude Code の `~/.claude/CLAUDE.md` / その他エージェントのグローバル指示に、以下をそのまま置く。

---

## 社内ナレッジ（company knowledge）

組織の設計・規約・メソドロジ・技術標準の正本は、このマシンに1つだけ存在する。各プロダクトリポジトリにはコピーしない。

### ルートの解決順

1. 環境変数 `COMPANY_KNOWLEDGE_ROOT`
2. なければ `~/.config/company/knowledge-root`（1行の絶対パス）
3. なければ `$HOME/.config/company/skeleton`

### 使い方

- 社内知が必要な作業では `company-knowledge` スキルに従うこと
- スキルが無い／使えない場合でも、解決したルートの `_general/README.md` を先に読み、必要なファイルだけ追読すること
- 正本に無い内容を推測で埋めないこと

---
