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
- **環境に応じたプレビュー先を使う**（外の Chrome を安易に開かない）：
  - **Cursor**：組み込みブラウザ（Glass）で開発・確認する。外部 Chrome ウィンドウは開かない
  - **cmux + Claude Code**：cmux の browser ペインで表示・検証する（Playwright で別の Chrome ウィンドウを新たに開かない）
  - **それ以外**：`scripts/split-preview.sh` で Chrome／デフォルトブラウザを開き、自己検証は Playwright をヘッドレスで行う
- **自己検証してから報告する**：変更のたびにスクリーンショットを撮り、表示崩れ・エラーがないことを確認してから URL を提示する
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
pnpm create next-app@latest <プロトタイプ名> --typescript --tailwind --eslint --app --src-dir --turbopack --use-pnpm --yes
cd <プロトタイプ名>
pnpm dlx shadcn@latest init -d
pnpm dlx shadcn@latest add <必要なコンポーネント>
```

- **`ERR_PNPM_IGNORED_BUILDS` でインストールが中断された場合**（pnpm 11+ は sharp 等のビルドスクリプトをデフォルトでブロックする）：生成された `pnpm-workspace.yaml` にはすでに `allowBuilds`/`ignoredBuiltDependencies` のプレースホルダが入っているので、**追記ではなくその既存ブロックを書き換えて**ビルドを許可し、`pnpm install` をやり直す（追記すると重複キーでエラーになる）
  ```yaml
  allowBuilds:
    sharp: true
    unrs-resolver: true
  ```
- 同名ディレクトリが既に存在する場合は上書きせず、続きから編集するか別名にするかを確認する
- shadcn コンポーネントは最初に使う分だけ追加し、反復中に必要になったら都度 `pnpm dlx shadcn@latest add` する

## フェーズ 3：実装とライブプレビュー

1. dev server をバックグラウンドで起動する（`pnpm dev`）。**起動ログで実際の URL を確認する**（3000 番が使用中だと別ポートになる）
2. **画面分割プレビュー（最初に一度だけ）**：**dev server 起動直後、実装より先に必ず実行する**。後回しにして忘れないこと。以降の変更は Fast Refresh で自動反映される
   - **Cursor の場合**（`$CURSOR_AGENT` が立っている／Cursor 上で動いている）：
     - 外部 Chrome は開かない
     - `cursor-app-control` MCP の `open_resource` に `uri: <URL>` を渡し、**Cursor 組み込みブラウザ（Glass）** で開く
     - `scripts/split-preview.sh` を叩いても Cursor では外部ブラウザを開かず案内だけ出す。プレビュー表示自体は必ず `open_resource` で行う
     - `cursor-ide-browser` MCP が使える場合は、そちらで navigate してもよい（ユーザーに見せる画面も組み込みブラウザ側に揃える）
   - **cmux + Claude Code の場合**：`scripts/split-preview.sh <URL>` を実行する。cmux が右に分割され、browser ペインに Web アプリが表示される。**このとき出力される `surface: surface:N` を必ず控えておく**（以降の自己検証はこの surface に対して行う）。再実行するとペインが増えるので初回のみ
   - **それ以外**：`scripts/split-preview.sh <URL>` で Chrome（なければデフォルトブラウザ）を開く（ウィンドウ位置は動かさない）
3. モックデータを用意し、画面を実装する
4. 自己検証する（**ユーザーに見せている画面と同じものを検証する。外部の可視 Chrome ウィンドウを新たに開かない**）：
   - **Cursor**：
     - 第一選択：`cursor-ide-browser` MCP が使えるなら、それで navigate / snapshot / screenshot / console を行う（組み込みブラウザ上で検証）
     - 使えない場合：ユーザー向け表示は Glass（`open_resource`）のまま維持し、検証だけ Playwright MCP を**ヘッドレス**で行う（可視の Chrome を起動しない。MCP 設定で `--headless` が有効か確認する）
     - navigate してからスクリーンショットを撮る（**navigate と撮影は必ず別ステップで順に実行する**。真っ白なら navigate し直して撮り直す）
     - 375px に resize してモバイル幅でも破綻しないか確認する（`document.documentElement.scrollWidth === window.innerWidth` を evaluate。body が flex の場合、flex アイテムの `min-width:auto` でテーブル等の min-content が伝播しやすい → `min-w-0` で対処）
     - 確認後は保存した画像・`.playwright-mcp/` を削除し、作業リポジトリを汚さない
   - **cmux 環境**：手順2で控えた surface に対して `cmux browser --surface <surface> <subcommand>` で操作する
     - `navigate <URL> --snapshot-after` でページ遷移、`screenshot --out <path>` でスクリーンショット
     - `console list` / `errors list` でコンソールエラー・JS エラーを確認
     - `eval "document.documentElement.scrollWidth === window.innerWidth"` で横スクロール検出
     - **注意**：cmux の browser ペインは WKWebView ベースで `viewport` サブコマンドが使えない（`not_supported` エラーになる）。375px モバイル幅の確認だけは Playwright をヘッドレスで別途起動して行う（表示中のペインとは無関係の裏側チェックなので可視ウィンドウは出ない）
     - スクリーンショット確認後は保存した画像を削除し、作業リポジトリを汚さない
   - **それ以外**：Playwright MCP をヘッドレスで使う（可視の Chrome ウィンドウを起動しないよう、利用中のツールの MCP 設定で `--headless` が有効か確認する）
     - ページに navigate してからスクリーンショットを撮る（**navigate と撮影は必ず別ステップで順に実行する**。真っ白な画像が撮れたら navigate し直して撮り直す）
     - 375px に resize してモバイル幅でも破綻しないか確認する（同上の横スクロール検出）
     - スクリーンショットの保存先が作業リポジトリを汚さないよう、確認後は画像・`.playwright-mcp/` を削除する
   - 共通で確認すること：表示崩れ・レイアウト破綻がないか（テキストの見切れ・はみ出しに注意）
5. 問題がなければ dev server の URL とスクリーンショットの確認結果を報告する

## フェーズ 4：チャットで反復

フィードバックを受けて修正するループ。「言えばすぐ隣の画面に反映される」体験がこのスキルの核なので：

- 修正は即座に反映し、毎回スクリーンショットで自己検証してから報告する
- 曖昧なフィードバック（「もっといい感じに」など）は解釈を 2〜3 案提示して選んでもらう
- 大きな方向転換は作り直しのほうが速いか判断して提案する

## 完了時

- プロトタイプの構成（画面・使用コンポーネント）を簡潔にまとめる
- 本実装に進む場合は `/issue`（ISSUE 化）や `/bdd`（テストファースト実装）を案内する
