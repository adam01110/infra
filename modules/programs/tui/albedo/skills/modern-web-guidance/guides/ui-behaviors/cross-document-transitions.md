# Cross-Document Transitions

Cross-document view transitions animate navigations between pages of a multi-page application (MPA). The default is a cross-fade, which you can customize.

## 1. Opt in

Both the source and the destination page must opt in for the browser to run a transition on navigation. Put the rule in a global stylesheet shared by both pages. Wrapping it in `prefers-reduced-motion: no-preference` turns the transitions off for users who prefer reduced motion.

```css
@media (prefers-reduced-motion: no-preference) {
  @view-transition {
    /* Enables transitions for same-origin navigations. */
    navigation: auto;
  }
}
```

## 2. Customize the animation (optional)

Target the old and new states with pseudo-elements to build effects such as slides or reveals:

```css
/* Outgoing page moves out to the left. */
::view-transition-old(root) {
  animation: 0.4s ease-in both slide-out;
}

/* Incoming page moves in from the right. */
::view-transition-new(root) {
  animation: 0.4s ease-out both slide-in;
}

@keyframes slide-out {
  to { transform: translateX(-20%); opacity: 0; }
}

@keyframes slide-in {
  from { transform: translateX(100%); }
}
```

## 3. Directional transitions (optional)

Different navigations may call for different effects. Going from the home page to a contact page, new content might come in from the right; going back home, the same effect would make no sense.

If a page always uses the same transition type no matter how users reach it, set it with `types` in the `@view-transition` rule:

```css
@media (prefers-reduced-motion: no-preference) {
  @view-transition {
    navigation: auto;
    /* Transition types always used on this page. */
    types: previous;
  }
}
```

To choose the type conditionally, add it in a `pagereveal` listener:

```js
window.addEventListener("pagereveal", async (e) => {
  if (e.viewTransition && window.navigation?.activation) {
    // yourTransitionTypeLogic is a placeholder for your own logic.
    const transitionType = yourTransitionTypeLogic(navigation.activation.from, navigation.activation.entry);
    e.viewTransition.types.add(transitionType);
  }
});
```

Then apply per-type animations with the `:active-view-transition-type()` pseudo-class (define the `slide-*` keyframes yourself):

```css
:active-view-transition-type(next) {
  &::view-transition-old(root) {
    animation-name: slide-out-next;
  }

  &::view-transition-new(root) {
    animation-name: slide-in-next;
  }
}
:active-view-transition-type(previous) {
  &::view-transition-old(root) {
    animation-name: slide-out-previous;
  }

  &::view-transition-new(root) {
    animation-name: slide-in-previous;
  }
}
```

## Fallback strategies

Baseline status for View transitions: Newly available. It's been Baseline since 2025-10-14.
Supported by: Chrome 111 (Mar 2023), Edge 111 (Mar 2023), Firefox 144 (Oct 2025), and Safari 18 (Sep 2024).

Browser support for Cross-document view transitions: Limited availability.
Supported by: Chrome 126 (Jun 2024), Edge 126 (Jun 2024), and Safari 18.2 (Dec 2024).
Unsupported in: Firefox.

Browsers without view transitions, or without cross-document view transitions, perform a normal instant navigation. The transitions are a progressive enhancement and the site works the same without them.

To detect support in JavaScript:

```javascript
if ('onpagereveal' in window) {
  // Cross-document view transitions are supported.
}
```

Baseline status for Navigation API: Newly available. It's been Baseline since 2026-01-13.
Supported by: Chrome 102 (May 2022), Edge 102 (May 2022), Firefox 147 (Jan 2026), and Safari 26.2 (Dec 2025).

Without the Navigation API you can't use it to work out the transition type. Use another way to determine the type, or provide a fallback type; otherwise no type is added and the default transition runs.

To detect support in JavaScript:

```javascript
if (window.navigation?.activation) {
  // The Navigation API is supported.
}
```
