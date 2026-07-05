---
name: prototype
description: チャットでデザインをやり取りしながら、動くプレビューを常に見せてライブで Web アプリのプロトタイプを構築する。/prototype コマンドが呼び出されたとき、または「プロトタイプを作りたい」「モックを作りたい」「画面イメージを見たい」「デザインを試したい」などの文脈で使用する。Next.js + shadcn/ui + Tailwind CSS で構築し、dev server とスクリーンショットで確認しながら反復する。
---

チャットで対話しながら Web アプリのプロトタイプをライブ構築する。動くものを最速で見せ、実際の画面を隣に表示したままフィードバックを受けて反復することがゴール。

## 技術スタック（固定）

- **Next.js**（App Router / TypeScript / Turbopack）
- **shadcn/ui** で UI コンポーネントを構築
- **Tailwind CSS** で CSS を構築

## 基本方針

- **スピード優先**：ヒアリングは最小限（何を作るか・主要な画面）に絞り、すぐ作り始める。細部はチャットの反復で詰める。
- **常に動く状態を保つ**：dev server を起動したまま編集し、いつでもブラウザで確認できる状態を維持する。
- **自己検証してから報告する**：変更のたびに Playwright でスクリーンショットを撮り、表示崩れ・エラーがないことを確認してから URL を提示する。
- **プロトタイプ品質**：バックエンド・認証・テストは作らない。データはハードコードのモックで十分。見た目と操作感に全力を注ぐ。

## 関連スキルの活用

利用可能なら以下のスキルを読み込んで従う：

- `frontend-design` — 実装前に読み込み、テンプレ然としない意図あるビジュアルデザインにする
- `next-best-practices` — Next.js のファイル規約・RSC 境界に従う
- `vercel-react-best-practices` — React/Next.js のパフォーマンスパターンに従う
- `web-design-guidelines` — ユーザーに UI レビューを求められたときに使用

## フェーズ 1：ヒアリング（最小限）

「何のプロトタイプを作りますか？」から始める。確認するのは以下のみ：

- 何を作るか（1〜2文でよい）
- 主要な画面・ユースケース
- デザインの参考・トーン（あれば。なければ frontend-design に従い自分で決めて提案する）

3問以内に収め、決まっていないことは推奨案を添えて自分で決めて進める。

## フェーズ 2：scaffold

カレントディレクトリ配下にプロジェクト名のディレクトリを新規作成する：

パッケージマネージャは **pnpm** を使う（`npm`/`npx` は使わない）：

```bash
pnpm create next-app@latest <プロトタイプ名> --typescript --tailwind --eslint --app --turbopack --use-pnpm --yes
cd <プロトタイプ名>
pnpm dlx shadcn@latest init -d
pnpm dlx shadcn@latest add <必要なコンポーネント>
```

- **`ERR_PNPM_IGNORED_BUILDS` でインストールが中断された場合**（pnpm 11+ は sharp 等のビルドスクリプトをデフォルトでブロックする）：生成された `pnpm-workspace.yaml` を書き換えてビルドを許可し、`pnpm install` をやり直す
  ```yaml
  allowBuilds:
    sharp: true
    unrs-resolver: true
  ```
- 同名ディレクトリが既に存在する場合は上書きせず、続きから編集するか別名にするかを確認する
- shadcn コンポーネントは最初に使う分だけ追加し、反復中に必要になったら都度 `pnpm dlx shadcn@latest add` する

## フェーズ 3：実装とライブプレビュー

1. dev server をバックグラウンドで起動する（`pnpm dev`）。**起動ログで実際の URL を確認する**（3000 番が使用中だと別ポートになる）
2. モックデータを用意し、画面を実装する
3. Playwright で自己検証する：
   - ページに navigate してからスクリーンショットを撮る（**navigate と撮影は必ず別ステップで順に実行する**。真っ白な画像が撮れたら navigate し直して撮り直す）
   - 表示崩れ・レイアウト破綻がないか（テキストの見切れ・はみ出しに注意）
   - コンソールエラーが出ていないか
   - 375px に resize してモバイル幅でも破綻しないか。目視に加えて `document.documentElement.scrollWidth === window.innerWidth` を evaluate で確認する（横スクロール検出。body が flex の場合、flex アイテムの `min-width:auto` でテーブル等の min-content が伝播しやすい → `min-w-0` で対処）
   - スクリーンショットの保存先が作業リポジトリを汚さないよう、確認後は画像・`.playwright-mcp/` を削除する
4. 問題がなければ dev server の URL とスクリーンショットの確認結果を報告する
5. **画面分割プレビュー**：`scripts/split-preview.sh <URL>` を実行し、チャットの隣に動く画面を常時表示する
   - cmux + Claude Code の場合：cmux が右に分割され、browser ペインに Web アプリが表示される
   - それ以外：Chrome（なければデフォルトブラウザ）で URL を開くだけ（ウィンドウ位置は動かさない）
   - **初回に一度だけ実行する**。再実行するとペインが増える。以降の変更は Fast Refresh で自動反映される
   - cmux 環境では Playwright の代わりに `cmux browser snapshot` 等でも表示確認できる（`cmux docs browser` 参照）

## フェーズ 4：チャットで反復

フィードバックを受けて修正するループ。「言えばすぐ隣の画面に反映される」体験がこのスキルの核なので：

- 修正は即座に反映し、毎回スクリーンショットで自己検証してから報告する
- 曖昧なフィードバック（「もっといい感じに」など）は解釈を 2〜3 案提示して選んでもらう
- 大きな方向転換は作り直しのほうが速いか判断して提案する

## 完了時

- プロトタイプの構成（画面・使用コンポーネント）を簡潔にまとめる
- 本実装に進む場合は `/issue`（ISSUE 化）や `/bdd`（テストファースト実装）を案内する
