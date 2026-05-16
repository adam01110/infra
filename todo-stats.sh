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

  function bar(done_count, removed_count, todo_count, width,    total_count, done_cells, removed_cells, todo_cells, i, out) {
    total_count = done_count + removed_count + todo_count

    if (total_count == 0) {
      return sprintf("%*s", width, "")
    }

    done_cells = int((done_count * width / total_count) + 0.5)
    removed_cells = int((removed_count * width / total_count) + 0.5)

    if (removed_count > 0 && removed_cells == 0) {
      removed_cells = 1
    }

    if (done_cells + removed_cells > width) {
      done_cells = width - removed_cells
    }

    todo_cells = width - done_cells - removed_cells
    out = ""

    for (i = 1; i <= done_cells; i++) {
      out = out "█"
    }

    for (i = 1; i <= removed_cells; i++) {
      out = out "░"
    }

    for (i = 1; i <= todo_cells; i++) {
      out = out "."
    }

    return out
  }

  function simple_bar(part, whole, width, fill,    filled, i, out) {
    filled = whole == 0 ? 0 : int((part * width / whole) + 0.5)
    out = ""

    for (i = 1; i <= width; i++) {
      out = out (i <= filled ? fill : " ")
    }

    return out
  }

  function print_stat(label, count, whole, fill) {
    printf "%-11s %4d %6.1f%%  [%s]\n", label ":", count, pct(count, whole), simple_bar(count, whole, 28, fill)
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

  function in_new_files() {
    return subsection == "New files"
  }

  /^###[[:space:]]+/ {
    subsection = trim_heading($0)
    next
  }

  /^##[[:space:]]+/ {
    section = trim_heading($0)
    subsection = ""
    if (!(section in seen)) {
      seen[section] = 1
      sections[++section_count] = section
    }
    next
  }

  /^- \[ \]/ {
    if (in_new_files()) {
      new_todo++
      next
    }

    todo++
    section_todo[section]++
  }

  /^- \[[xX]\]/ {
    if (in_new_files()) {
      new_done++
      next
    }

    done++
    section_done[section]++
  }

  /^- \[-\]/ {
    if (in_new_files()) {
      new_removed++
      next
    }

    removed++
    section_removed[section]++
  }

  END {
    total = todo + done + removed
    active = todo + done
    new_total = new_todo + new_done + new_removed
    new_active = new_todo + new_done

    if (total + new_total == 0) {
      print "No todo entries found."
      exit
    }

    print "=============================================="
    printf "Todo summary: %s\n", FILENAME
    print "=============================================="
    printf "Progress    %6.1f%%  [%s]\n", pct(done, active), bar(done, removed, todo, 28)
    printf "Remaining   %6.1f%%  [%s]\n", pct(todo, active), simple_bar(todo, active, 28, ".")
    print "Legend: █ done, ░ removed, . to do"
    print "----------------------------------------------"
    print_stat("To do", todo, total, ".")
    print_stat("Done", done, total, "█")
    print_stat("Removed", removed, total, "░")
    print "----------------------------------------------"
    printf "Active:      %4d\n", active
    printf "Total:       %4d\n", total

    if (new_total > 0) {
      print ""
      printf "New files:  %4d (excluded from progress)\n", new_total
    }

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
        printf "%-28s %6.1f%%  [%s] %3d/%-3d\n", fit(name, 28), pct(section_done[name], section_active), bar(section_done[name], section_removed[name], section_todo[name], 12), section_done[name], section_active
      }
    }
  }
' "$todo_file"
