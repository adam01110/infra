# Individual Transform Properties

The `transform` property applies several transformations in a given order, but changing one of them means re-specifying the whole chain, which makes it awkward to animate or transition a single transformation.

The individual transform properties `translate`, `rotate` and `scale` apply transformations independently of `transform`, so a single transformation is easy to override, for instance on `:hover`.

## Key implementation details

Individual transform properties always apply in a fixed order, regardless of their order in your CSS:

1. `translate`
2. `rotate`
3. `scale`
4. `transform` (applied last)

If you need a different order, such as scaling before rotating, use `transform` functions.

Transform functions do not override the individual properties. `scale: 2; transform: scale(3);` scales by 2x and then by 3x, for 6x in total.

### Preventing unexpected changes in stacking contexts and containing blocks

`transform` and the individual transform properties affect layout and rendering, and can cause unexpected behavior with `z-index` or anchor positioning. If an element may get a transform as part of a state change such as `:hover`, a transition or an animation, give the base element an identity transformation. Its stacking context and containing block then stay the same when the transform is applied, instead of appearing only in the changed state.

```css
.element {
  /* Identity values for the properties that change on :hover */
  translate: 0px;
  rotate: 0deg;
  scale: 1;
}
.element:hover {
  translate: 10px 10px;
  rotate: 20deg;
  scale: 0.8;
}
```

### Independent animations and transitions

The main benefit is that overlapping animations or transitions can target different transform properties without overwriting each other.

```css
.card {
  /* Animates translate */
  animation: float 3s infinite ease-in-out;

  /* Transitions scale only */
  transition: scale 0.3s ease;

  /* Base scale, so hovering does not suddenly create a stacking context */
  scale: 1;
}

.card:hover {
  /* Only scale changes; the float animation continues uninterrupted */
  scale: 1.05;
}

@keyframes float {
  0%, 100% { translate: 0 0; }
  50% { translate: 0 -10px; }
}
```

### Fallback strategies

Baseline status for Individual transform properties: Widely available. It's been Baseline since 2022-08-05.
Supported by: Chrome 104 (Aug 2022), Edge 104 (Aug 2022), Firefox 72 (Jan 2020), Safari 14.1 (Apr 2021), and Safari iOS 14.5 (Apr 2021).

For browsers without individual transform properties, use `transform`. Changing one part in another state then means re-declaring the whole transform stack.

```css
.element {
  transform: translate(100px, 0) rotate(45deg);
  /* Identity for the scale property */
  scale: 1;
}

@supports not (translate: 0px) {
  .element:hover {
    /* Repeat translate and rotate even though only scale changes */
    transform: translate(100px, 0) rotate(45deg) scale(1.1);
  }
}

@supports (translate: 0px) {
  .element:hover {
    /* Declare only the change */
    scale: 1.1;
  }
}
```
