#!/bin/sh
set -e

REPO_OWNER="departure-inc"
REPO_NAME="skeleton-skills"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${BRANCH}"

echo "==> skeleton-skills installer"
echo "    source: ${RAW_URL}"
echo ""

# skills-lock.json をカレントディレクトリに配置
curl -fsSL "${RAW_URL}/skills-lock.json" -o skills-lock.json
echo "  [downloaded] skills-lock.json"
echo ""

# skills-lock.json を元にローカルインストール
npx skills experimental_install

echo ""
echo "==> Done!"
