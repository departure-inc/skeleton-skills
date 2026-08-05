---
name: infra-build
description: インフラを構築する。/infra-build <issue番号> の形式で呼ぶほか、infra-design から同一セッションで続く場合は ISSUE を経由せず直接使用する。「インフラを構築して」「環境を作って」「IaC を書いて」などの文脈でも使用する。PaaS 構成（Fly.io / Vercel + CI/CD）とクラウド IaC 構成（Terraform / CDK / Pulumi）の両方に対応する。
---

# /infra-build <issue番号>

infra-design で合意した構成を読み、方針承認の 1 回だけ確認を挟んで、構築・検証・報告まで自律的に進める。

## 手順

1. **入力の取得**
   - ISSUE 駆動（基本）: `gh issue view <番号> --json number,title,body,labels,comments`
   - 同一セッション直結: infra-design で合意済みの構成をそのまま入力にする

2. **正本を読む**
   company-knowledge スキルの手順でルートを解決し、`infra/README.md` と、選定された IaC の個別 md（`terraform.md` / `cdk.md` / `pulumi.md`）を読む。ディレクトリ構成・ファイル構成は正本の規約に従う。CDK を使う場合は aws-cdk スキルも併用する。

3. **コンテキスト把握**
   AGENTS.md / CLAUDE.md を読む → 既存のインフラコード・CI/CD 設定・環境変数管理を調査する。

4. **方針サマリの提示（唯一の確認ポイント）**
   以下をまとめて提示し、承認を得る：
   - 経路（PaaS 構成 / クラウド IaC 構成）と構築対象の一覧
   - 環境構成（正本のスタック構成を基本）
   - 作成・変更するファイル一覧
   - クラウドへの反映（apply / 初回デプロイ）をどこまで行うか

5. **構築**
   - **PaaS 経路**: `fly.toml` / Vercel 設定、DB・ストレージのプロビジョニング、GitHub Actions のデプロイワークフロー、環境変数・シークレットの登録手順
   - **IaC 経路**: 正本の規約に従ったディレクトリ・モジュール構成で各環境のスタックを記述する
   - **Makefile（両経路共通）**: 初回構築は各ツールのコマンドを直接実行してよいが、日常運用のコマンドは Makefile にまとめる。ステージング更新・本番更新などのリリース操作は `make release` のようなターゲットに集約し、環境の指定方法とターゲット一覧を報告に含める。既存の Makefile があればターゲットを追記する

6. **検証と報告**
   - 実行できる検証をすべて行う: `terraform validate` / `terraform plan`、`fly config validate`、CI 設定の lint 等
   - クラウドへの反映は dev / stg までを承認済みの範囲で行い、本番への反映は deploy スキルの承認ゲートに従う
   - 作成ファイル一覧・検証結果・残タスク（人間が行う作業: シークレット発行・DNS・ドメイン等）を報告する

## 注意

- 承認後に想定外の事象（要件矛盾・コストの大幅増）が起きた場合のみ中断して報告する
- シークレット値をファイルやチャットに書かない。登録コマンドと手順のみ提示する
