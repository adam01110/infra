---
name: excalidash
description: >-
  Use when drawing or editing architecture, flow, pipeline, sequence, class,
  state, ER, or node-edge diagrams on an ExcaliDash board.
license: MIT
compatibility: Requires the excalidash MCP server.
metadata:
  author: davifernan, adapted by Adam0
  version: "1.2.0"
  short-description: Draw clean, readable, editable ExcaliDash diagrams
---

# ExcaliDash diagramming

The goal is a diagram that looks finished at a glance: a title, evenly sized
rounded nodes, a few role colors used consistently, calm gray arrows, and no
overlaps. Read [`references/design.md`](references/design.md) before the first
board write; it has the palette and the layout checklist.

## Choose the tool

- `draw_graph`: the default for boxes-and-arrows diagrams such as
  architectures, pipelines, request flows, and dependency graphs. Its layout
  engine gives the cleanest result: uniform rounded nodes, gray edges, and a
  `title` line.
- `draw_mermaid`: use for `sequenceDiagram`, `classDiagram`, `stateDiagram`,
  `erDiagram`, and flowcharts that need decision diamonds or labeled branches.
  Style flowchart nodes with `classDef` and `class`. Subgraphs fail to convert
  (the board stays unchanged), and special node shapes such as `[( )]` or
  `[[ ]]` render as plain rectangles, so express groups and kinds with color.
- `draw_scene`: use for legends, notes, titles beside a Mermaid diagram, and
  free sketches with absolute coordinates. Give every element a descriptive id
  so later `update_element` and `delete_elements` calls can target it.

Call `read_me` once per session before using `draw_scene`.

## Draw

1. Pick a direction: `LR` for pipelines and request flows, `TB` for trees,
   hierarchies, and decision flows. If the result is very wide or very tall,
   flip it.
2. Assign each node a role and give each role one color (see the design
   reference). Two to four roles is typical; one color for everything is
   flat, and a color per node is noise.
3. Keep node labels to a few words in sentence case and of similar length, so
   boxes come out the same size. Put details in the node label only when they
   matter, otherwise leave them out.
4. Label edges only when the label adds information (protocol, condition,
   event name), with 1-3 words.
5. Add a title (`title` in `draw_graph`, or a `draw_scene` text element above
   a Mermaid diagram).
6. Add a small legend with `draw_scene` in `append` mode when there are three
   or more roles and their meaning is not obvious from the labels. Read node
   positions with `read_board` and place the legend below the lowest node.

Modes for every draw tool: `replace` (default) redraws what this server drew
and keeps hand-drawn work, `append` adds beside it, and `wipe` clears the
whole board including hand-drawn work, so use `wipe` only when the user wants
a clean board. For structural changes, edit the source and redraw with
`replace` instead of nudging elements by hand.

## Layout pitfalls

- Merge duplicate edges between the same pair into one labeled edge.
- Shortcut edges across a chain stretch the layout; keep only meaningful ones.
- Self-loops overlap each other; use at most one per node.
- Very large diagrams get cramped or rejected; split them into separate
  diagrams placed side by side.

## Check the export

Call `export_png` and look at the image before finishing, because overlaps
and lopsided layouts only show there. Check it against the checklist in the
design reference, fix the source, and redraw with `replace` until it passes.
