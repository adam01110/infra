# diagram restraint

subset of design skill. every rule here hard. break rule? board ugly, redraw.

## hierarchy live in position, not box

- position, spacing, size, label weight carry hierarchy. border and box carry
  nothing.
- group = things sit close and line up. group still unclear? fix arrangement,
  never add frame.
- cramped? too many elements, not too little chrome. cut elements.

## color discipline

- default no color: `#1e1e1e` stroke, transparent fill.
- one accent color, only on single most important thing. red only for failure
  path.
- budget 3 stroke colors, red included. color must mean one thing viewer need
  to decode. color mean nothing? remove color, keep meaning.
- one color per node "to look nice"? grug forbid. look nice come from order,
  not color.

## reject

- rectangle around every node. node = short label where connector meet, not
  card.
- frame or container by default? no. frame only when user ask frame.
- gradient, shadow, decorative fill. all no.
- more than 3 text size.

## check

export and look. over budget? strip all color except most important path and
red, redraw. box pile? delete box, `draw_mermaid` redraw with `replace`.
