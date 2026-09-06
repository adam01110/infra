---
name: excalidash
description: >-
  Use when drawing or editing architecture, flow, pipeline, sequence, class,
  state, ER, or node-edge diagrams on an ExcaliDash board.
license: MIT
compatibility: Requires the excalidash MCP server.
metadata:
  author: davifernan, adapted by Adam0
  version: "1.0.0"
  short-description: Draw clear editable ExcaliDash diagrams
---

# excalidash diagramming

grug want diagram clear, editable, no box pile.

## choose club

structured diagram? start `draw_mermaid`. converter place things better than
model guessing pixels. editable forms:

- `flowchart`
- `sequenceDiagram`
- `classDiagram`
- `stateDiagram`
- `erDiagram`

small node-edge graph? `draw_graph`. legend, note, free sketch? `draw_scene`.
every scene element need id, else later edit hurt.

## draw

use `LR` for pipeline/request flow. use `TB` for tree, hierarchy, decision flow.
shape extreme? flip direction and redraw.

labels stay small:

- node: few words
- edge: 2-3 words
- diamond: 2-3 words

long words make giant diamond. long edge text sit on neighbor. detail belong in
node or not at all.

`draw_mermaid` and `draw_graph` mode:

- `replace`: replace prior server drawing; keep hand drawing
- `append`: add beside old work
- `wipe`: clear whole board

structural change? edit source, redraw with `replace`.

## avoid demon

- duplicate edge? combine label.
- more than 2 edges same pair? crowd.
- shortcut across chain? layout grow wide. keep only if useful.
- many self-loops? overlap.
- subgraph big? converter may reject. split diagram.
- color has no meaning? remove color.

use 3-4 colors max. one meaning each: layer, team, stage. red mean failure.
safe stroke/fill names: `blue green orange purple red yellow pink gray amber
cyan lime`. `teal` fill only. `black` and `white` stroke only. orange, yellow,
and amber share same stroke, so fill must carry meaning.

## look with eyes

always call `export_png` and inspect image before done. json lie politely.
caption overlap and lopsided graph only show here. bad? simplify, flip direction,
or shorten labels, then export again.
