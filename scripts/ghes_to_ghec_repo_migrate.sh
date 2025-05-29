#!/bin/bash

# ========== USAGE HELP ==========
show_usage() {
  echo ""
  echo "🔄 GitHub Repo Migration: GHES ➜ GHEC"
  echo "--------------------------------------"
  echo "Usage:"
  echo "  $0 <GHES_URL> <GHES_PAT> <GHEC_PAT> <SOURCE_REPO> <TARGET_REPO>"
  echo ""
  echo "Example:"
  echo "  $0 \\"
  echo "    https://ghe.example.com \\"
  echo "    ghp_xxx_from_ghes \\"
  echo "    ghp_xxx_from_ghec \\"
  echo "    source-org/source-repo \\"
  echo "    target-org/target-repo"
  echo ""
  exit 1
}

# ========== INPUT PARAMETERS ==========
GHES_URL="$1"
GHES_PAT="$2"
GHEC_PAT="$3"
SOURCE_REPO="$4"
TARGET_REPO="$5"

# Show usage if no params
if [[ $# -lt 5 ]]; then
  show_usage
fi

# ========== VALIDATION ==========
if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI (gh) is not installed."
  exit 1
fi

if ! gh extension list | grep -q 'gh-gei'; then
  echo "📦 Installing GitHub Enterprise Importer extension..."
  gh extension install github/gh-gei
fi

# ========== PARSE ORGS AND REPOS ==========
SOURCE_ORG=$(echo "$SOURCE_REPO" | cut -d/ -f1)
SOURCE_REPO_NAME=$(echo "$SOURCE_REPO" | cut -d/ -f2)
TARGET_ORG=$(echo "$TARGET_REPO" | cut -d/ -f1)
TARGET_REPO_NAME=$(echo "$TARGET_REPO" | cut -d/ -f2)

# ========== PERFORM MIGRATION ==========
echo "🚀 Starting migration from GHES ➜ GHEC..."
echo "🔗 Source: $GHES_URL/$SOURCE_REPO"
echo "🎯 Target: github.com/$TARGET_REPO"

gh gei migrate-repo \
  --ghes-api-url "$GHES_URL/api/v3" \
  --github-source-pat "$GHES_PAT" \
  --github-source-org "$SOURCE_ORG" \
  --github-target-org "$TARGET_ORG" \
  --target-repo "$TARGET_REPO_NAME" \
  --source-repo "$SOURCE_REPO_NAME" \
  --github-target-pat "$GHEC_PAT" \
  --verbose

# ========== STATUS ==========
echo ""
echo "📦 Migration initiated. Use the following to check status:"
echo "gh gei list-migrations --github-target-org $TARGET_ORG --github-target-pat <GHEC_PAT>"
