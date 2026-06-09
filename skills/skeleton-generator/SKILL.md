---
name: skeleton-generator
description: skeleton-generator gem を Rails プロジェクトにインストールする。/skeleton-generator コマンドが呼び出されたときのみ実行する。Gemfile への追記と bundle exec rails g skeleton_generator:install を行う。
disable-model-invocation: true
---

## 概要

[departure-inc/skeleton-generator](https://github.com/departure-inc/skeleton-generator) を Rails プロジェクトにインストールする。

---

## 手順

### 1. Rails プロジェクトであることを確認する

```bash
ls Gemfile
```

`Gemfile` が存在しない場合はエラーメッセージを表示して終了する：

> Rails プロジェクトの Gemfile が見つかりません。Rails プロジェクトのルートディレクトリで実行してください。

---

### 2. インストール済みかどうか確認する

```bash
grep -q "skeleton_generator" Gemfile
```

既に記述がある場合はスキップしてユーザーに通知する：

> skeleton_generator はすでに Gemfile に追記されています。ジェネレーターの実行のみ行います。

---

### 3. Gemfile に追記する（未インストールの場合）

`Gemfile` の末尾に以下を追記する：

```ruby
gem 'skeleton_generator', github: 'departure-inc/skeleton-generator'
```

追記後、変更内容をユーザーに提示する。

---

### 4. bundle install を実行する

```bash
bundle install
```

失敗した場合はエラー内容を表示して終了する。

---

### 5. インストールジェネレーターを実行する

```bash
bundle exec rails g skeleton_generator:install
```

実行結果をそのまま表示する。

---

### 6. 完了報告

以下の内容を報告する：

- Gemfile への追記内容（追記した場合）
- `bundle install` の結果
- `rails g skeleton_generator:install` の実行結果
- 次のステップがあれば案内する（ジェネレーターの出力に従う）
