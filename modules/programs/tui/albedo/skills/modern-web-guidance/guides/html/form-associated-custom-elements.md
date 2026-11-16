# Form-Associated Custom Elements

To surface a custom control's value to a form, use a Form-Associated Custom Element (FACE) rather than a hidden `<input>`. With `formAssociated` and `ElementInternals`, the element submits its own value, takes part in constraint validation, and reflects form state natively.

```javascript
class RatingInput extends HTMLElement {
  // Required opt-in: without it, the form APIs of attachInternals() are unavailable.
  static formAssociated = true;

  #internals;
  #value = '';

  constructor() {
    super();
    this.#internals = this.attachInternals();
    this.attachShadow({ mode: 'open', delegatesFocus: true });
    // Render the rating buttons into the shadow root here (omitted).
  }

  connectedCallback() {
    // Validate the initial state once attributes such as `required` are present.
    this.#validate();
  }

  get value() { return this.#value; }
  set value(v) {
    this.#value = v;
    this.#internals.setFormValue(v); // submitted with the owning <form>
    this.#validate();
  }

  #validate() {
    if (this.hasAttribute('required') && !this.#value) {
      this.#internals.setValidity(
        { valueMissing: true },
        'Please choose a rating.',
        // Focused when validity is reported; undefined if not rendered yet.
        this.shadowRoot.querySelector('[tabindex]') ?? undefined,
      );
    } else {
      this.#internals.setValidity({});
    }
  }

  // Optional FACE lifecycle hooks.
  formResetCallback() { this.value = ''; }
  formDisabledCallback(disabled) {
    // Disable the internal controls, not `this`: see the notes below.
    for (const el of this.shadowRoot.querySelectorAll('button')) {
      el.disabled = disabled;
    }
  }
  formStateRestoreCallback(state) { this.value = state; }
}
customElements.define('rating-input', RatingInput);
```

Key points:

- `static formAssociated = true` is required. It unlocks the form-related `ElementInternals` methods and the `form*Callback` lifecycle hooks.
- `setFormValue(value)` is what gets submitted; no hidden input is needed. Pass a `FormData` for multi-value controls.
- `setValidity(flags, message, anchor)` plugs into native constraint validation: the form will not submit while the element is invalid, `:invalid` and `:valid` apply, and the anchor element receives focus when validity is reported. Call `setValidity({})` to clear it. The interaction-aware `:user-valid` and `:user-invalid` pseudo-classes are not consistently wired up for form-associated elements across browsers, so verify support before relying on them to track user interaction the way they do for native controls.
- Implement `formResetCallback`, `formDisabledCallback` and `formStateRestoreCallback` so the element behaves like a native control on form reset, inside `fieldset[disabled]`, and on back/forward and autofill restore.
- In `formDisabledCallback(disabled)`, disable the internal controls (or remove them from the tab order and ignore input) instead of setting `disabled` on the host. Setting the host attribute inside the callback leaves the host stuck disabled when an ancestor `<fieldset>` is re-enabled, and the host already matches `:disabled` automatically.
- Follow platform conventions for events: prefer the built-in `input` and `change` events over custom ones. `input` fires when the value changes as a direct result of user action (typing, dragging a slider); `change` fires once per stream of changes, when the user commits (releasing the slider, blurring the field). Construct them with `InputEvent` and `Event` respectively.

## Accessibility considerations

If the custom element handles interaction directly, or acts as a group for individual controls, give it a role through `ElementInternals`, and when it handles interaction directly, expose its state there too.

```js
this.#internals.role = 'group';
```

Do not set an accessible name through `ElementInternals` unless the element contains its own visible label (as a single checkbox-like element might). An internal name would likely override the name an author gives the element, for example with a `<label for>`.

## Fallback strategies

Baseline status for Form-associated custom elements: Widely available. It's been Baseline since 2023-03-27.
Supported by: Chrome 77 (Sep 2019), Edge 79 (Jan 2020), Firefox 98 (Mar 2022), and Safari 16.4 (Mar 2023).

Feature-detect support before relying on `static formAssociated`: `'attachInternals' in HTMLElement.prototype && 'setFormValue' in ElementInternals.prototype`. Where it is unavailable, fall back to a visually hidden native `<input>` kept in sync with the control's value so the form still submits. This is the one case where the hidden-input pattern is justified.
