#!/usr/bin/env sh

set -eu

todo_file=${1:-todo.md}

if [ ! -f "$todo_file" ]; then
  printf 'todo file not found: %s\n' "$todo_file" >&2
  exit 1
fi

awk '
  function pct(part, whole) {
    return whole == 0 ? 0 : part * 100 / whole
  }

  function bar(part, whole, width,    filled, i, out) {
    filled = whole == 0 ? 0 : int((part * width / whole) + 0.5)
    out = ""

    for (i = 1; i <= width; i++) {
      out = out (i <= filled ? "#" : "-")
    }

    return out
  }

  function print_stat(label, count, whole) {
    printf "%-11s %4d %6.1f%%  [%s]\n", label ":", count, pct(count, whole), bar(count, whole, 28)
  }

  function section_total(i) {
    return section_todo[i] + section_done[i] + section_removed[i]
  }

  function trim_heading(line) {
    sub(/^#+[[:space:]]+/, "", line)
    return line
  }

  function fit(text, width) {
    return length(text) <= width ? text : substr(text, 1, width - 3) "..."
  }

  /^##[[:space:]]+/ {
    section = trim_heading($0)
    if (!(section in seen)) {
      seen[section] = 1
      sections[++section_count] = section
    }
    next
  }

  /^- \[ \]/ {
    todo++
    section_todo[section]++
  }

  /^- \[[xX]\]/ {
    done++
    section_done[section]++
  }

  /^- \[-\]/ {
    removed++
    section_removed[section]++
  }

  END {
    total = todo + done + removed
    active = todo + done

    if (total == 0) {
      print "No todo entries found."
      exit
    }

    print "=============================================="
    printf "Todo summary: %s\n", FILENAME
    print "=============================================="
    printf "Progress    %6.1f%%  [%s]\n", pct(done, active), bar(done, active, 28)
    printf "Remaining   %6.1f%%  [%s]\n", pct(todo, active), bar(todo, active, 28)
    print "----------------------------------------------"
    print_stat("To do", todo, total)
    print_stat("Done", done, total)
    print_stat("Removed", removed, total)
    print "----------------------------------------------"
    printf "Active:      %4d\n", active
    printf "Total:       %4d\n", total

    if (section_count > 0) {
      print ""
      print "Section progress"
      print "----------------------------------------------"

      for (i = 1; i <= section_count; i++) {
        name = sections[i]
        subtotal = section_total(name)

        if (subtotal == 0) {
          continue
        }

        section_active = section_todo[name] + section_done[name]
        printf "%-28s %6.1f%%  [%s] %3d/%-3d\n", fit(name, 28), pct(section_done[name], section_active), bar(section_done[name], section_active, 12), section_done[name], section_active
      }
    }
  }
' "$todo_file"
