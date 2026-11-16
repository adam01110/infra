# Custom Button Actions

The Invoker Commands API lets buttons trigger actions on target elements declaratively through HTML attributes. It reduces manual event listeners and decouples the UI from implementation details. For application-specific actions you can define your own commands; their names must start with a double dash (`--`) so they never collide with future built-in commands.

## Implementation steps

1. Identify the element that responds to the action, and give it a unique `id` if it has none.
2. On the invoker button, point `commandfor` at the target's `id` and set `command` to the custom command name (starting with `--`).
3. Attach a `command` listener directly on the target element. The event has a `command` property, a `target` (the element named by `commandfor`) and a `source` (the button).
4. Manage ARIA states such as `aria-pressed` or `aria-expanded` yourself; custom commands have no built-in semantics.

## Example: custom animation controls

```html
<div id="action-target" class="target">
  Action Target
</div>

<!-- Each button sends its own custom command to the target. -->
<button commandfor="action-target" command="--spin">
  Spin
</button>

<button commandfor="action-target" command="--grow">
  Grow
</button>

<button commandfor="action-target" command="--reset">
  Reset All
</button>

<script>
  // Optional: a registry of actions keeps the handler simple.
  const commandRegistry = {
    '--spin': (target, source) => {
      const isSpun = target.classList.toggle('is-spun');
      // Custom commands have no semantics, so set ARIA state yourself.
      source?.setAttribute('aria-pressed', isSpun);
    },
    '--grow': (target, source) => {
      const isGrown = target.classList.toggle('is-grown');
      source?.setAttribute('aria-pressed', isGrown);
    },
    '--reset': (target) => {
      target.classList.remove('is-spun', 'is-grown');
      // Reset every associated button's ARIA state.
      document.querySelectorAll(`button[commandfor="${target.id}"]`).forEach(btn => {
        btn.setAttribute('aria-pressed', 'false');
      });
    },
  };

  // Listen on the target itself: the native command event doesn't bubble.
  document.getElementById('action-target').addEventListener('command', (event) => {
    const command = event.command;
    const target = event.target;
    const source = event.source; // The triggering button.
    const action = commandRegistry[command];

    if (action) {
      action(target, source);
    }
  });
</script>
```

## Key constraints

- Every custom command name starts with `--` (for example `command="--my-action"`).
- `commandfor` must match the `id` of an element in the same document tree.
- The `command` event doesn't bubble. With several possible targets, listen on an ancestor with `{ capture: true }`.
- If the target may be in a shadow root, use `event.composedPath()[0]` instead of `event.target`.

## Accessibility

Custom commands carry no semantics, so apply states explicitly:

- If the button shows additional content, use `aria-expanded`: `"false"` by default and `"true"` while the content is shown.
- If the button is itself a toggle (play and pause, mute and unmute), use `aria-pressed`: `"false"` when inactive, `"true"` when active.
- If the button opens an element with role `menu`, `listbox`, `tree`, `grid` or `dialog`, give it `aria-haspopup` set to that role.
- If the button becomes disabled when activated, use `aria-disabled="true"` instead of `disabled` so focus isn't lost.

## Fallback strategies

Baseline status for Invoker commands: Newly available. It's been Baseline since 2025-12-12.
Supported by: Chrome 135 (Apr 2025), Edge 135 (Apr 2025), Firefox 144 (Oct 2025), and Safari 26.2 (Dec 2025).

Without the API the `command` event never fires. For support across all modern browsers, use invokers-polyfill (<https://github.com/keithamus/invokers-polyfill>) from npm or a CDN. It fully supports custom `--` commands and dispatches `command` exactly like the native API.

### Load the polyfill only when needed

Load it only in browsers without native support, which saves bandwidth and script execution for everyone else:

```javascript
const hasNativeSupport = 'commandForElement' in HTMLButtonElement.prototype;

if (!hasNativeSupport) {
  // An async IIFE avoids top-level await, which older browsers may not support.
  (async () => {
    try {
      await import('https://esm.run/invokers-polyfill');
    } catch (err) {
      console.error('Error loading fallback:', err);
    }
  })();
}
```

The polyfill doesn't manage ARIA states such as `aria-pressed` or `aria-expanded` for custom commands. Keep them in sync in your listener:

```javascript
document.getElementById('action-target').addEventListener('command', (event) => {
  const command = event.command;
  const target = event.target;
  const source = event.source; // The button that triggered the command.

  if (command === '--spin') {
    const isSpun = target.classList.toggle('is-spun');
    source?.setAttribute('aria-pressed', isSpun);
  }
});
```

### Manual fallback

Without a polyfill, combine event delegation, which dispatches the events, with a command registry that handles them. This is a common, efficient and scalable pattern.

```javascript
// Optional: a registry of actions.
const commandRegistry = {
  '--spin': (target) => target.classList.toggle('is-spun'),
  '--grow': (target) => target.classList.toggle('is-grown'),
  '--reset': (target) => target.classList.remove('is-spun', 'is-grown'),
};

// No CommandEvent means no native support: define it and dispatch commands manually.
if (!globalThis.CommandEvent) {
  globalThis.CommandEvent = class CommandEvent extends Event {
    constructor(type, { source, command, ...options } = {}) {
      super(type, options);
      this.source = source;
      this.command = command;
    }
  }

  document.addEventListener('click', (event) => {
    const button = event.composedPath().find((el) => el.matches?.("button[commandfor]"));
    if (!button) return;

    const target = document.getElementById(button.getAttribute('commandfor'));
    const command = button.getAttribute('command');

    if (target && command) {
      target.dispatchEvent(new CommandEvent('command', {
        command,
        source: button,
      }));
    }
  });
}

// One listener on the target handles native and fallback events.
document.getElementById('action-target').addEventListener('command', (event) => {
  const command = event.command;
  const target = event.target;
  const action = commandRegistry[command];

  if (action) {
    action(target);
  }
});
```
