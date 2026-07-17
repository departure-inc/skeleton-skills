#!/bin/sh
set -e

REPO_OWNER="departure-inc"
REPO_NAME="skeleton-skills"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

usage() {
  cat <<EOF
Usage: install.sh [options]

Options:
  -g, --global   \$HOME にインストールする（全プロジェクト共通）
  -h, --help     このヘルプを表示する

デフォルトはカレントディレクトリ（プロジェクト）にインストールする。
curl 経由で実行する場合: curl -fsSL .../install.sh | sh -s -- --global
EOF
}

MODE="local"
for arg in "$@"; do
  case "$arg" in
    -g|--global) MODE="global" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

if [ "$MODE" = "global" ]; then
  TARGET_DIR="$HOME"
else
  TARGET_DIR="$(pwd)"
fi

echo "==> skeleton-skills installer (${MODE})"
echo "    source: ${RAW_URL}"
echo "    target: ${TARGET_DIR}"
echo ""

cd "$TARGET_DIR"

# skills-lock.json をターゲットディレクトリに配置
curl -fsSL "${RAW_URL}/skills-lock.json" -o skills-lock.json
echo "  [downloaded] skills-lock.json"
echo ""

# skills-lock.json を元にインストール（実体は .agents/skills に置かれる）
# </dev/null: curl|sh 経由で実行されると npx が stdin(パイプ)を読み切ってしまい
# その後のシェルスクリプトが実行されなくなるのを防ぐ
npx skills experimental_install </dev/null

# 各エージェントは実体(.agents/skills)を直接参照しないため、不足分のシンボリックリンクを補完する
# （インストーラは実体の更新のみ行い、新規スキルのリンクを作らないことがある）
AGENTS_SKILLS_DIR="${TARGET_DIR}/.agents/skills"

link_skills() {
  agent_skills_dir="$1"
  if [ -d "$AGENTS_SKILLS_DIR" ]; then
    mkdir -p "$agent_skills_dir"
    for skill_path in "$AGENTS_SKILLS_DIR"/*/; do
      [ -d "$skill_path" ] || continue
      name=$(basename "$skill_path")
      link="${agent_skills_dir}/${name}"
      if [ ! -e "$link" ]; then
        # 既存リンクには触れない。リンク切れの残骸は -f で張り替える
        ln -sfn "../../.agents/skills/${name}" "$link"
        echo "  [linked] ${agent_skills_dir#$TARGET_DIR/}/${name} -> ../../.agents/skills/${name}"
      fi
    done
  fi
}

# Claude Code は .claude/skills を参照する
link_skills "${TARGET_DIR}/.claude/skills"

# Codex CLI は .codex/skills（グローバル時は $CODEX_HOME/skills、既定 ~/.codex/skills）を参照する
if [ "$MODE" = "global" ]; then
  CODEX_SKILLS_DIR="${CODEX_HOME:-${TARGET_DIR}/.codex}/skills"
else
  CODEX_SKILLS_DIR="${TARGET_DIR}/.codex/skills"
fi
link_skills "$CODEX_SKILLS_DIR"

echo ""
echo "==> Done!"
