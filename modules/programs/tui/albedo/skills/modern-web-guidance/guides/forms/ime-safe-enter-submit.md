# IME-safe enter-to-submit

Many chat interfaces submit the message when the user presses Enter in a `<textarea>`. That works for direct Latin keyboard input such as English, but breaks for users composing text with an Input Method Editor (IME) in languages such as Japanese, Chinese or Korean. There, Enter (Return) confirms the current conversion candidate. A `keydown` handler that submits on Enter immediately sends the message while the user is still converting characters, producing incomplete, fragmented or wrong messages.

The check applies to every custom `keydown` handler that acts on Enter, not only multiline `<textarea>` fields. Single-line `<input>` fields with their own Enter handling, such as search and find bars, inline rename fields, modal dialog fields and command palettes, receive the same IME-confirming Enter `keydown` with `isComposing` set to `true`. Native implicit submission of a `<form>` from an `<input>` with no custom Enter handler needs nothing extra: browsers suppress implicit submission when an IME consumes the Enter keystroke.

## Implementation

In a custom enter-to-submit handler on a `<textarea>` or `<input>`, check the `KeyboardEvent`'s `isComposing` property before submitting. Also call `event.preventDefault()`: Enter's default action inserts a newline in a `<textarea>`, and in an `<input>` inside a `<form>` it triggers implicit submission, which would submit a second time.

```html
<form id="chat-form">
  <label for="chat-input" class="visually-hidden">Message</label>
  <textarea id="chat-input" placeholder="Type a message..."></textarea>
  <button type="submit" id="send-button">Send</button>
</form>
```

```js
const textarea = document.getElementById('chat-input');
const form = document.getElementById('chat-form');

textarea.addEventListener('keydown', (event) => {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault();

    // The user is confirming an IME candidate, not submitting.
    if (event.isComposing) {
      return;
    }

    form.requestSubmit();
  }
});
```

For a single-line `<input>`, use the same handler without the `!event.shiftKey` condition, which exists only because Shift+Enter inserts a newline in a `<textarea>`.

Other submit shortcuts such as Cmd+Enter or Ctrl+Enter do not conflict with IME confirmation and need no IME check.

## Accessibility

1. Always include a `<button type="submit">`. Keyboard shortcuts are helpers and must not replace the native submit path.
2. Associate every `<input>` and `<textarea>` with a `<label>` through matching `id` and `for` attributes.

## Fallback strategies

Browser support for `KeyboardEvent.isComposing`: Limited availability.
Supported by: Chrome 56 (Jan 2017), Edge 79 (Jan 2020) and Firefox 31 (Jul 2014).
Unsupported in: Safari.

In recent Safari versions, an event-ordering issue (WebKit bug 165004) delivered `compositionend` to script handlers before the confirming Enter `keydown`, even though the events were dispatched in the opposite order. By the time the `keydown` handler ran, `event.isComposing` was already `false`, so the check alone did not prevent premature submission.

Because of this ordering bug, the `isComposing` check alone is not reliable in Safari. When Safari is a target, or to cover older Safari versions and other platforms, use one of these strategies.

### Strategy 1: also check `keyCode === 229` (recommended)

During IME composition, browsers report `keyCode` 229 (`VK_PROCESSKEY`) instead of 13 on `keydown`, even while `event.key` is `'Enter'` on the confirming keystroke. Checking `event.isComposing || event.keyCode === 229` reliably catches Safari's out-of-order confirming Enter. Because the check sits inside the `event.key === 'Enter'` condition, it does not misfire on mobile virtual keyboards that report 229 for normal character entry.

This also means legacy handlers that test `event.keyCode === 13` are already immune to IME confirmation, and migrating them to `event.key === 'Enter'` without the `isComposing` and `keyCode === 229` checks introduces premature submission.

```js
textarea.addEventListener('keydown', (event) => {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault();

    if (event.isComposing || event.keyCode === 229) {
      return;
    }

    form.requestSubmit();
  }
});
```

### Strategy 2: `event.timeStamp` window (alternative)

If the codebase forbids deprecated APIs such as `keyCode`, or the 229 check has known problems in a target environment, compare event timestamps instead. Safari dispatches the confirming Enter `keydown` very close to `compositionend`, often within 5 ms, and sometimes with the `keydown` timestamp slightly earlier because of the inverted handler delivery. A time-difference check is therefore highly reliable and unlikely to give false positives on mobile virtual keyboards under normal conditions.

```js
let lastCompositionEndAt = null;

textarea.addEventListener('compositionend', (event) => {
  // Use event.timeStamp, not Date.now() or performance.now(): handler-time
  // measurements drift when the main thread is blocked.
  lastCompositionEndAt = event.timeStamp;
});

textarea.addEventListener('keydown', (event) => {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault();

    if (event.isComposing) {
      return;
    }

    // Ignore Enter within 50 ms of composition ending, in either direction,
    // because Safari can deliver the events in inverted order.
    if (
      lastCompositionEndAt !== null &&
      Math.abs(event.timeStamp - lastCompositionEndAt) < 50
    ) {
      return;
    }

    form.requestSubmit();
  }
});
```
