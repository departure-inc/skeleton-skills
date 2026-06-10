---
name: implement
description: GitHub ISSUE の番号を受け取り、内容を読んで BDD で実装する。/implement <issue番号> の形式で呼ぶ。「このISSUEを実装して」「#123を実装して」などの文脈でも使用する。
disable-model-invocation: true
---

# /implement <issue番号>

ISSUE を読み、シナリオ承認の 1 回だけ確認を挟んで、実装・検証・報告まで自律的に進める。

## 手順

1. **ISSUE 取得**
   `gh issue view <番号> --json number,title,body,labels,comments`
   （リポジトリはカレントディレクトリから自動検出される）

2. **コンテキスト把握**
   AGENTS.md / CLAUDE.md を読む → 技術スタックとテスト・lint・型チェックのコマンドを検出する → 関連コードと既存の類似実装を調査する。

3. **方針とシナリオの提示（唯一の確認ポイント）**
   以下をまとめて提示し、承認を得る：
   - 実装概要（1〜3 行）と変更ファイル一覧
   - bdd スキルの記述ルールに従った Given/When/Then シナリオ
   - 仕様の曖昧さがあれば、推奨案を添えてここで一括確認する

4. **実装（Red → Green → Refactor）**
   シナリオをテストとして自動化し Red を確認 → 実装で Green に → Refactor。プロジェクト規約・既存パターンに従う。

5. **検証と報告**
   検出したテスト・lint・型チェックをすべて実行し、変更ファイル一覧・実行結果・残タスクを報告する。

## 注意

- 承認後に想定外の事象（仕様矛盾・大規模化）が起きた場合のみ中断して報告する
