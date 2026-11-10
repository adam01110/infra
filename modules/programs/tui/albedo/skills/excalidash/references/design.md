# Diagram design

## Palette

Use these role pairs consistently within a board. In `draw_graph` pass the
name as both `color=` and `fill=`. In Mermaid use the hex pair in `classDef`,
for example `classDef service fill:#d0bfff,stroke:#6741d9`. Avoid class names
that equal node ids.

| Role                         | `draw_graph` | Mermaid fill | Mermaid stroke |
| ---------------------------- | ------------ | ------------ | -------------- |
| Client, input, entry point   | `blue`       | `#a5d8ff`    | `#1971c2`      |
| Service, process, logic      | `purple`     | `#d0bfff`    | `#6741d9`      |
| Data, storage, queue         | `teal`       | `#c3fae8`    | `#0c8599`      |
| Decision, note               | `yellow`     | `#fff3bf`    | `#f08c00`      |
| Output, success              | `green`      | `#b2f2bb`    | `#2f9e44`      |
| External, optional, inactive | `gray`       | `#dee2e6`    | `#868e96`      |
| Error, failure path          | `red`        | `#ffc9c9`    | `#e03131`      |

Red means failure only, so readers can spot problems instantly. Keep arrows
neutral (`draw_graph` already draws them gray) so color stays on nodes.

## Layout principles

- Hierarchy comes from position and flow direction: the entry point on the
  left or top, the main path in a straight line, side branches off it.
- Uniform node sizes look deliberate; similar label lengths produce them.
- Leave whitespace. If the diagram feels cramped, cut or merge nodes rather
  than shrinking them.
- Use at most three text sizes: title, labels, details.
- Skip gradients, shadows, and decorative shapes.

## Export checklist

- Title present and readable.
- No overlapping nodes, and no edge label sitting on a node or another label.
- Aspect ratio is reasonable, roughly between 3:1 and 1:3.
- Few edge crossings; reorder or flip direction if they pile up.
- Every color maps to one role, and the same role always has the same color.
- Labels are short and in consistent casing.
