#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${BASE_DIR:-../gclone}"
INDEX_FILE="${INDEX_FILE:-$HOME/.gclone_index}"

usage() { echo "Usage: gclone <add|list|rm|mv> [branch|path] [newpath]"; exit 1; }

cmd="${1:-}"
case "$cmd" in
  add)
    branch="${2:-}" ; [ -z "$branch" ] && usage
    dest="${3:-$BASE_DIR/$branch}"
    repo="$(git remote get-url origin)"
    mkdir -p "$(dirname "$dest")"

    cp -a ./ $dest

    mkdir -p "$(dirname "$INDEX_FILE")"
    grep -qxF "$dest" "$INDEX_FILE" 2>/dev/null || echo "$dest" >> "$INDEX_FILE"

    cd $dest
    if git show-ref --verify --quiet "refs/heads/$branch"; then
      git sw "$branch"
    else
      git sw -c "$branch"
    fi

    echo "change dir to $dest"
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
  mv)
    src="${2:-}" ; dest="${3:-}"
    { [ -z "$src" ] || [ -z "$dest" ]; } && usage
    [ -d "$src/.git" ] || { echo "Not a git clone: $src"; exit 1; }
    [ -e "$dest" ] && { echo "Destination already exists: $dest"; exit 1; }
    mkdir -p "$(dirname "$dest")"
    mv "$src" "$dest"
    if [ -f "$INDEX_FILE" ]; then
      grep -vxF "$src" "$INDEX_FILE" > "$INDEX_FILE.tmp" || true
      echo "$dest" >> "$INDEX_FILE.tmp"
      mv "$INDEX_FILE.tmp" "$INDEX_FILE"
    fi
    echo "moved $src to $dest"
    ;;
  *) usage ;;
esac
