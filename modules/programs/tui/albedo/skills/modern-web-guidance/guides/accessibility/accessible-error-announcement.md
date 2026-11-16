# Accessible error announcement

## The problem

HTML validation styles fields through `:invalid` or `:user-invalid`, but it does not keep accessibility attributes such as `aria-invalid` in sync. Styling with `:invalid` alone also lets screen readers announce "invalid entry" as soon as a user tabs into an empty required field, before they have typed anything.

## The approach

Apply the programmatic state (`aria-invalid="true"`) at the same moment as the visual state (`:user-invalid`). `:user-invalid` depends on the browser's internal "user has interacted" flag, and there is no event for it changing, so JavaScript checks whether the field matches `:user-invalid` during the normal interaction events.

1. Visual layer: CSS `:user-invalid` shows borders, icons and the error message.
2. Accessibility layer: `aria-invalid` carries the state, and the error message is listed in `aria-describedby` only while the field is invalid. An error that appears when the user leaves or changes a field is announced through one polite live region for the page.
3. Bridge: a small script listens for `blur`, `change`, `input` and `invalid`, checks `:user-invalid`, and updates the ARIA attributes.
4. Focus on submit: screen readers announce a field's error when focus reaches it, so after a failed submit move focus to the first invalid field, or on a long form to an error summary (a heading followed by a link to each invalid field). Native validation focuses the first invalid field for you; with `novalidate`, do it in your submit handler.

Rules the script follows, and why:

- Set `aria-invalid="false"` until `:user-invalid` matches instead of leaving it unset. Firefox and Safari expose an empty `required` field as invalid from page load, so an unset attribute still causes the premature announcement there. Chromium, in turn, does not expose an empty `required` field as invalid after interaction unless `aria-invalid="true"` is set.
- Link each field to its error by putting the error's `id` in the field's `data-error` attribute (`data-error="email-error"` for `id="email-error"`), and let the script add that `id` to `aria-describedby` only while the field is invalid. Do not reference the error from `aria-describedby` in the markup: the error element is always in the page, and text referenced by `aria-describedby` is announced even when hidden, so it would be read before the user has interacted.
- Announce through one polite live region, after a short delay so the error does not talk over the field that receives focus next. Do not make each error message a live region: a live region that is shown, rather than changed, is not announced reliably. Errors from a failed submit are not announced this way, because moving focus to the first invalid field reads its error.

## 1. HTML

```html
<form>
  <div class="field">
    <label for="email">Email</label>
    <input type="email" id="email" required data-error="email-error">
    <span id="email-error" class="error-msg">
      Please enter a valid email address.
    </span>
  </div>
</form>
```

## 2. CSS

```css
.error-msg {
  display: none;
  color: #d93025;
}

:is(input, select, textarea):user-invalid ~ .error-msg {
  display: block;
}

/* Optional cue on the field itself */
:is(input, select, textarea):user-invalid {
  border-color: #d93025;
}
```

## 3. JavaScript

This script needs `:user-invalid` support: `el.matches(':user-invalid')` throws a `SyntaxError` in browsers without it. Run it only when `CSS.supports('selector(:user-invalid)')` is true, and run the fallback below otherwise.

```javascript
// List the field's error (the id in data-error) in aria-describedby only while it's
// shown: text that aria-describedby references is announced even when hidden.
const linkError = (el, shown) => {
  const errorId = el.dataset.error;
  if (!errorId) return;
  const ids = (el.getAttribute('aria-describedby') || '').split(/\s+/).filter((id) => id && id !== errorId);
  if (shown) ids.push(errorId);
  if (ids.length) el.setAttribute('aria-describedby', ids.join(' '));
  else el.removeAttribute('aria-describedby');
};

// One polite live region for the page. Run this once the form is in the page.
const announcer = document.createElement('div');
announcer.setAttribute('aria-live', 'polite');
announcer.classList.add('visually-hidden');
document.body.append(announcer);
let announceTimer;
let announcedField;

// Text as a screen reader reads it: icons' text alternatives in, aria-hidden text out.
const spokenText = (node) => {
  const copy = node.cloneNode(true);
  copy.querySelectorAll('[aria-hidden="true"]').forEach((n) => n.remove());
  copy.querySelectorAll('[role="img"][aria-label]').forEach((n) => n.replaceWith(`${n.getAttribute('aria-label')}: `));
  return copy.textContent.replace(/\s+/g, ' ').trim();
};
const announceError = (el) => {
  const error = document.getElementById(el.dataset.error);
  if (!error) return;
  const label = el.labels?.[0] ? `${spokenText(el.labels[0])}: ` : '';
  clearTimeout(announceTimer);
  announcer.textContent = '';
  announcedField = el;
  // Wait until the screen reader has announced the field that receives focus next.
  announceTimer = setTimeout(() => { announcer.textContent = label + spokenText(error); }, 500);
};

// Sync aria-invalid with :user-invalid. Only form fields are synced, and an
// aria-invalid="true" this script didn't set (for example from a server check) is left alone.
const flagged = new WeakSet();
// Fields whose current error has been announced, or read by focus after a failed submit.
// A field can become invalid while the user types, so this is tracked separately.
const announced = new WeakSet();
const syncAria = (el, announce = false) => {
  if (!el.matches?.('input, select, textarea')) return;
  const invalid = el.matches(':user-invalid');
  if (invalid) {
    if (announce && !announced.has(el)) {
      announceError(el);
      announced.add(el);
    }
    el.setAttribute('aria-invalid', 'true');
    linkError(el, true);
    flagged.add(el);
  } else if (flagged.has(el) || el.getAttribute('aria-invalid') !== 'true') {
    el.setAttribute('aria-invalid', 'false');
    linkError(el, false);
    flagged.delete(el);
    announced.delete(el);
    // Clear a fixed field's announcement so it isn't found later when reading the page.
    if (announcedField === el) {
      clearTimeout(announceTimer);
      announcer.textContent = '';
    }
  }
};

// Start every field at aria-invalid="false".
document.querySelectorAll('input, select, textarea').forEach((el) => syncAria(el));

// blur shows and announces an error; input clears it.
document.addEventListener('blur', (e) => syncAria(e.target, true), true);
document.addEventListener('input', (e) => {
  if (e.target.hasAttribute('aria-invalid')) syncAria(e.target);
});

// Checkboxes, radios and other controls that commit on change can become
// :user-invalid without losing focus.
document.addEventListener('change', (e) => syncAria(e.target, true), true);

// A failed submit fires 'invalid' (which doesn't bubble) on each failing field, including
// required fields the user never touched. Focus moving to the first invalid field reads
// its error, so these aren't announced.
document.addEventListener('invalid', (e) => {
  announced.add(e.target);
  syncAria(e.target);
}, true);

// Reset clears :user-invalid after the 'reset' event, so sync each field afterwards.
document.addEventListener('reset', (e) => {
  setTimeout(() => [...e.target.elements].forEach((el) => syncAria(el)));
}, true);
```

Hide the live region with a `.visually-hidden` utility, which hides content visually but keeps it in the accessibility tree:

```css
.visually-hidden:where(:not(:focus-within, :active)) {
  position: absolute !important;
  clip-path: inset(50%) !important;
  overflow: hidden !important;
  width: 1px !important;
  height: 1px !important;
  margin: -1px !important;
  padding: 0 !important;
  border: 0 !important;
  white-space: nowrap !important;
}
```

## Fallback strategies

Baseline status for `:user-valid` and `:user-invalid`: Widely available, Baseline since 2023-11-02.
Supported by Chrome 119 (Oct 2023), Edge 119 (Nov 2023), Firefox 88 (Apr 2021) and Safari 16.5 (May 2023).

### CSS fallback

Wrap the pseudo-class in `:is()`: in a plain selector list, one unsupported selector drops the whole rule. This applies to every field that can be invalid (`input`, `select`, `textarea`).

```css
:is(:user-invalid, .user-invalid-fallback) {
  border-color: #d93025;
  background-color: #fce8e6;
}

:is(:user-invalid, .user-invalid-fallback) + .error-msg {
  display: block;
}
```

### JavaScript fallback

This utility runs only where `:user-invalid` is unsupported. It tracks interaction state in a `WeakMap` rather than adding "dirty" classes or data attributes to the DOM.

```javascript
const UserInvalidFallback = (() => {
  const dirtyState = new WeakMap();

  const updateState = (input) => {
    // validity.valid reads the state without firing 'invalid', unlike checkValidity().
    const isValid = input.validity.valid;
    input.classList.toggle('user-invalid-fallback', !isValid);
    input.classList.toggle('user-valid-fallback', isValid);
    input.setAttribute('aria-invalid', isValid ? 'false' : 'true');
    linkError(input, !isValid);
  };

  // List the error (the id in data-error) in aria-describedby only while it's shown.
  const linkError = (input, shown) => {
    const errorId = input.dataset.error;
    if (!errorId) return;
    const ids = (input.getAttribute('aria-describedby') || '').split(/\s+/).filter((id) => id && id !== errorId);
    if (shown) ids.push(errorId);
    if (ids.length) input.setAttribute('aria-describedby', ids.join(' '));
    else input.removeAttribute('aria-describedby');
  };

  const handleEvent = (event) => {
    const input = event.target;

    if (event.type === 'reset') {
      const controls = input.elements || [];
      for (const control of controls) {
        dirtyState.delete(control);
        control.classList.remove('user-invalid-fallback');
        control.classList.remove('user-valid-fallback');
        if (control.matches('input, select, textarea')) control.setAttribute('aria-invalid', 'false');
        if (control.dataset?.error) linkError(control, false);
      }
      return;
    }

    if (!input.checkValidity) return;

    // A submit attempt counts as interaction: 'invalid' fires on each failing field,
    // including required fields the user never touched.
    if (event.type === 'invalid') {
      dirtyState.set(input, { hasInteracted: true, hasBlurred: true });
      updateState(input);
      return;
    }

    if (event.type === 'input' || event.type === 'change') {
      const state = dirtyState.get(input) || { hasInteracted: false, hasBlurred: false };
      state.hasInteracted = true;
      dirtyState.set(input, state);
      if (state.hasBlurred) updateState(input);
    } else if (event.type === 'blur') {
      const state = dirtyState.get(input) || { hasInteracted: false, hasBlurred: false };
      state.hasBlurred = true;
      dirtyState.set(input, state);
      if (state.hasInteracted) updateState(input);
    }
  };

  const init = (root = document) => {
    if (CSS.supports('selector(:user-invalid)')) return;

    // Firefox and Safari expose an empty required field as invalid from page load.
    root.querySelectorAll('input, select, textarea').forEach((el) => {
      if (!el.hasAttribute('aria-invalid')) el.setAttribute('aria-invalid', 'false');
    });

    root.addEventListener('blur', handleEvent, true);
    root.addEventListener('input', handleEvent);
    root.addEventListener('change', handleEvent);
    root.addEventListener('invalid', handleEvent, true); // 'invalid' doesn't bubble
    root.addEventListener('reset', handleEvent, true);
  };

  return { init };
})();

// Pass the form, or call init() with no argument to cover the whole document.
UserInvalidFallback.init(document.querySelector('form'));
```
