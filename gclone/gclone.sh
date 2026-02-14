#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${BASE_DIR:-../gclone}"
INDEX_FILE="${INDEX_FILE:-$HOME/.gclone_index}"

usage() { echo "Usage: gclone <add|list|rm> [branch|path]"; exit 1; }

cmd="${1:-}"
case "$cmd" in
  add)
    branch="${2:-}" ; [ -z "$branch" ] && usage
    dest="${3:-$BASE_DIR/$branch}"
    repo="$(git remote get-url origin)"
    mkdir -p "$(dirname "$dest")"

    if git ls-remote --exit-code --heads "$repo" "$branch" >/dev/null 2>&1; then
      git clone --branch "$branch" --single-branch "$repo" "$dest"
    else
      git clone "$repo" "$dest"
      (cd "$dest" && git checkout -b "$branch")
    fi

    mkdir -p "$(dirname "$INDEX_FILE")"
    grep -qxF "$dest" "$INDEX_FILE" 2>/dev/null || echo "$dest" >> "$INDEX_FILE"
    ;;
  list)
    if [ -f "$INDEX_FILE" ] && [ -s "$INDEX_FILE" ]; then
      cat "$INDEX_FILE"
    else
      echo "No clone exists yet"
    fi
  ;;
  rm)
    target="${2:-}" ; [ -z "$target" ] && usage
    [ -d "$target/.git" ] || { echo "Not a git clone: $target"; exit 1; }
    read -r -p "Remove $target? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || exit 0
    rm -rf "$target"
    [ -f "$INDEX_FILE" ] && grep -vxF "$target" "$INDEX_FILE" > "$INDEX_FILE.tmp" && mv "$INDEX_FILE.tmp" "$INDEX_FILE"
    ;;
  *) usage ;;
esac
