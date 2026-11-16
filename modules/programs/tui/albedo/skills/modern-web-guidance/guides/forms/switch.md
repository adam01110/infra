# Build Accessible Switch Controls

Build a binary on/off toggle with `<input type="checkbox" switch>` and an associated `<label>`. It keeps native form submission, keyboard navigation and screen reader semantics. See also the `checkbox` and `forms` guides.

## Markup

Add the boolean `switch` attribute to a standard checkbox:

```html
<label>
  Enable notifications
  <input id="notifications" type="checkbox" switch>
</label>
```

- The label can wrap the input or be associated with `for`/`id`. All styling targets the input, so it does not depend on the label structure.
- When checked, the input submits its standard checkbox value. In JavaScript, listen for `change` (or `input`) and read `.checked`, not `.value`.

## Styling

Set the highlight color with `accent-color` (see the `brand-consistent-forms` guide). Give the focus indicator a contrast ratio of at least 3:1 against adjacent colors (WCAG 1.4.11 Non-text Contrast):

```css
input[type="checkbox"][switch] {
  accent-color: var(--accent-color, #1769e0);
  margin: 0;
  cursor: pointer;
}

input[type="checkbox"][switch]:focus-visible {
  outline: 3px solid var(--focus-color, #d35400);
  outline-offset: 4px;
}
```

## Fallback strategies

### Browser support for switch

Browser support for `<input type="checkbox" switch>`: Limited availability.
Supported by: Safari 17.4 (Mar 2024).
Unsupported in: Chrome, Edge and Firefox.

If your Baseline target lacks support, load `input-switch-polyfill` only when `'switch' in HTMLInputElement.prototype` is `false`, never unconditionally. The polyfill enhances checkboxes that have the `switch` attribute: it sets `role="switch"`, applies switch styling (`appearance: none`), syncs the computed `accent-color`, and adds pointer drag support.

Load the package the way your project loads modules. This example assumes module specifiers resolve:

```javascript
if (!('switch' in HTMLInputElement.prototype)) {
  import('input-switch-polyfill');
}
```

### Browser support for accent-color

Browser support for `accent-color`: Limited availability.
Supported by: Chrome 93 (Aug 2021), Edge 93 (Sep 2021), Firefox 92 (Sep 2021) and Safari 26.2 (Dec 2025).

`accent-color` is progressive enhancement: browsers without support ignore it and use their default UI colors.
