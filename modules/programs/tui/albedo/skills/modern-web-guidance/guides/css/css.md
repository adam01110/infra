# CSS: Modern Architecture

A reference for writing maintainable, standards-compliant CSS.

## 1. Foundations

Avoid duplicating knowledge. Prefer variables over repetition, and where possible prefer built-in conventions:

- `currentColor` instead of defining a variable and setting `color` to it.
- The `inherit` keyword instead of defining a variable on the parent and using it for the same property on parent and child.
- `em` units instead of `font-size: var(--size)`.
- `cqw`/`cqh` units (or their logical forms `cqi`/`cqb`) instead of repeating box-model values.

Code duplication is not knowledge duplication: the goal is robustness and maintainability, not saving characters.

Prefer logical properties and values over physical ones (such as `margin-inline-start` instead of `margin-left`) so styles adapt to other writing modes and orientations. Even if the author does not plan to localize, external translation tools often show translated text in place. Do not apply logical properties blindly, though: ask whether the value should flip in RTL, and if not, use the physical property.

Consider other viewing modes (dark mode, high contrast mode), viewport sizes and input modes (touch, keyboard, pointer).

## 2. Inheritance and the cascade

Do not introduce BEM naming conventions to manage specificity. Use cascade layers and `:where()` to make cascade behavior predictable and follow author intent.

Use cascade layers (`@layer`) for explicit priority zones (such as `reset`, `base`, `theme`, `components`, `utilities`), and declare their order up front (`@layer reset, base, theme, components, utilities;`). Within each layer, use `:where()` so selectors compete only on meaningful signals, not on incidental filters (`:not()` edge cases, remote ancestors and so on), and for one-off defaults that should be easy to override.

Use keywords such as `inherit`, `initial`, `unset` or `revert` instead of explicit values; they are easier to maintain and express intent. For example:

- For a child whose transition should match the parent's `transition-*` properties, write `transition: inherit` instead of repeating them.
- To reset a property to its initial value, write `initial` instead of the explicit value, which states the intent more clearly.

## 3. Selectors and scoping

Modern native selectors reduce the need for preprocessors and for state tracking in JavaScript.

### Prefer CSS selectors over JS for complex element targeting

- Use `:has()` to style parents based on child state instead of managing classes in JavaScript (such as `label:has(:checked)` instead of a manual `label.has-checked` class). The `child-state-based-styling` and `content-based-styling` guides cover this in detail.
- Do not nest `:has()` or put pseudo-elements inside it; browsers do not support either.
- Use `:nth-child(<An+B> of <selector>)` to select the n-th element matching a selector. `details:nth-child(1 of [open])` styles the first open `<details>`, whereas `details[open]:first-child` styles the first child only if it happens to be open.

### Use `:is()` (or `:where()`) instead of duplicating rules for fallbacks

To provide a fallback for a pseudo-class that may be unsupported, use `:is()` or `:where()` and rely on their forgiving parsing, rather than duplicating the rule:

```css
/* Avoid: the same rule twice */
[popover]:popover-open {
  /* styles for native popovers */
}
[popover].\:popover-open {
  /* same styles again, for polyfilled popovers */
}

/* Prefer: one rule */
[popover]:where(:popover-open, .\:popover-open) {
  /* styles */
}
```

This does not work for pseudo-elements, which `:is()` and `:where()` do not accept.

### Avoid overmatching

Write selectors that express intent.

#### Use `:not()` instead of overrides to exclude irrelevant states or targets

When states or elements are fundamentally irrelevant to a rule, exclude them with `:not()`.

For example, for bottom borders between list items, avoid this:

```css
.fancy-list li {
  border-bottom: 1px solid silver;
}

.fancy-list li:last-child {
  border-bottom: none;
}
```

The override can wipe out a wanted `border-bottom` set by another rule, and it is a workaround for the real intent: borders only on the non-last items. Say that directly:

```css
.fancy-list li:not(:last-child) {
  border-bottom: 1px solid silver;
}
```

Similarly, avoid this:

```css
button:hover {
  background: var(--color-blue);
}

button:disabled {
  background: var(--color-neutral);
}
```

Reordering these two rules gives disabled buttons a hover background. Write this instead:

```css
button:hover:not(:disabled) {
  background: var(--color-blue);
}

button:disabled {
  background: var(--color-neutral);
}
```

This works in either order because the first rule no longer overmatches.

If you must use an override (for example, with an experimental container query whose `not` case is also the fallback), the `revert-layer` keyword can sometimes remove the value without coupling the override to specific values. This only works if the value to fall back to is also in a layer.

#### Prefer `@scope` over `:not()` for excluding (possibly deeply nested) subtrees

`:not()` with descendant selectors can exclude subtrees, but it breaks down for nested structures: `.card :not(.content *)` does not behave as expected for nested cards. `@scope` takes hierarchical proximity into account and handles them correctly:

```css
@scope (.card) to (.content) {
  /* elements inside .card but not inside .content */
}
```

#### Overrides are fine for specialization

This is fine:

```css
button {
  background: var(--color-neutral);
}

button.primary {
  background: var(--color-blue);
}
```

Both rules express legitimate intent: buttons are neutral in general, and primary buttons are blue.

#### No global resets

Do not use global resets (styles on `*`): web components and lower-priority cascade layers cannot override them without `!important`. Apply reset styles to specific element types or conditions instead.

### Nesting and scoping

Use native CSS nesting to group related styles where it improves maintainability and readability.

Prefer `@scope` over nesting when proximity should matter more than specificity. This is common for selectors that can nest in any order where the closest match (walking from the element to its ancestors) should win, such as theming classes.

For example, this does not work as expected:

```css
.dark .invert { color-scheme: light }
.light .invert { color-scheme: dark }
```

If `.invert` is nested inside both `.dark` and `.light`, it always resolves to dark, because both rules have the same specificity and the later one wins. `@scope` fixes this:

```css
@scope (.dark) {
  .invert { color-scheme: light }
}

@scope (.light) {
  .invert { color-scheme: dark }
}
```

## 4. Interactivity

See the `accessibility` guide for focus rings, touch targets and custom gestures.

## 5. Design tokens and theming

Define core design variables (colors, fonts, sizes and so on) as CSS custom properties on `:root`, for visual consistency and to scale UI design across teams. Do not write nontrivial styling values inline: `background: transparent` or `padding: 0` is fine, but `background: #f06` or `padding: .3em` is not. The exception is code where staying small and simple matters far more than long-term maintenance, such as test cases.

Tokens are usually organized in tiers, each building on the previous one:

1. Literal design tokens (such as `--color-blue-10`, `--color-gray-90`, `--font-sans-serif`, `--size-xl`).
2. Semantic design tokens (such as `--color-accent`, `--color-neutral`, `--font-body`, `--font-heading`).
3. General UI design tokens (such as `--ui-border`, `--surface-bg-subtle`).
4. Component-specific design tokens (such as `--button-bg-primary-hover`, `--button-border-color-secondary`).

Smaller projects need fewer tiers; a quick demo or toy app is fine with one, so do not overengineer. Check for existing naming and tier conventions before inventing your own.

### Theming

- Dark mode: see the `dark-mode` and `component-specific-light-dark-theme` guides.
- Forced Colors Mode, and generating tints and shades: see the `color` guide.
- Theming browser-generated UI (selection, scrollbars, form controls): see the `browser-ui-theming` guide.

## 6. Responsive design

See the `responsive-design` guide for components that adapt to the space they are given, layouts that survive mobile browser UI appearing and disappearing, reserving space for media before it loads, and text that scales with the viewport.

## 7. Typography

See the `typography` guide for the readability, accessibility and aesthetics of text in web UIs.

## 8. Visual effects

See the `visual-effects` guide for look-and-feel enhancements: depth, texture and elevation, blending layers, pleasing gradients and flexible pattern backgrounds.

## 9. Shapes

- Use `corner-shape: squircle` for smoother curves, as a progressive enhancement over regular rounded corners.
- Use elliptical `border-radius` (such as `10px / 20px`) for proportional curves without extra elements.

## 10. Transitions and animations

See the `motion` guide. For rendering performance (`content-visibility`, containment), see the `performance` guide.

## 11. Generated content

See the `accessible-generated-content` guide for adding decorative or supplementary content with CSS without breaking screen readers or copy-paste.
