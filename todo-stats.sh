#!/usr/bin/env sh

set -eu

todo_file=${1:-todo.md}

if [ ! -f "$todo_file" ]; then
  printf 'todo file not found: %s\n' "$todo_file" >&2
  exit 1
fi

awk '
  /^- \[ \]/ { todo++ }
  /^- \[[xX]\]/ { done++ }
  /^- \[-\]/ { removed++ }
  END {
    total = todo + done + removed

    if (total == 0) {
      print "No todo entries found."
      exit
    }

    printf "Todo summary for %s\n", FILENAME
    printf "Still to do: %d (%.1f%%)\n", todo, todo * 100 / total
    printf "Done:        %d (%.1f%%)\n", done, done * 100 / total
    printf "Removed:     %d (%.1f%%)\n", removed, removed * 100 / total
    printf "Total:       %d\n", total
  }
' "$todo_file"
