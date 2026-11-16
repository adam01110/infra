# Conditional Async Dependencies

Top-level `await` lets a module pause its own evaluation while it awaits a promise. This makes it a good way to load async dependencies, such as polyfills or heavy secondary libraries, only when the browser needs them. The conditional loading logic lives in one module, and modules that import it do not execute until the dependency is loaded and ready.

## Conditional polyfill pattern

Any async module dependency can be loaded this way; polyfills are a common case. The feature detection and the dynamic import sit together in one dependency module.

Here the `popover` polyfill loads only if `popover` is missing from `HTMLElement.prototype`. For a global DOM attribute or property like `popover`, check `HTMLElement.prototype` rather than `window` or `document`.

```javascript
// conditionally-load-polyfill.js

if (!('popover' in HTMLElement.prototype)) {
  // Pauses every module that imports this file until the polyfill has
  // downloaded and run.
  await import('/path/to/popover-polyfill.js');
}

// Optional marker export.
export const polyfillLoaded = true;
```

```javascript
// main.js

// Because the imported module uses top-level await, main.js does not run
// until the polyfill is ready.
import './conditionally-load-polyfill.js';

const myPopover = document.getElementById('my-popover');
if (myPopover) {
  myPopover.showPopover();
}
```

## Sequencing imports and the pre-Safari 27 bug

Structure the module graph so the top-level `await` module is imported from a single entry point and finishes before downstream modules evaluate. Two structures break this:

- Sibling static imports in an entry file, such as `import './conditionally-load-polyfill.js'; import './app.js';`. Per the ECMAScript module evaluation rules, top-level `await` suspends only the module that imports it, not its sibling static imports, so `./app.js` evaluates before the polyfill finishes loading in every browser.
- Importing the top-level `await` module from several sibling modules at once, such as `a.js` and `b.js` both statically importing `./conditionally-load-polyfill.js`. Safari 15–26.6 fails when multiple modules import a module containing top-level `await` at the same time. [Safari 27 fixed WebKit's module loader](https://webkit.org/blog/18227/fixing-top-level-await-in-safari/) to handle this per spec (see [MDN browser compatibility](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/await#browser_compatibility)).

Use one of these patterns instead:

1. Single entry module (the `main.js` above): if the entry module runs the dependent code itself, statically import `./conditionally-load-polyfill.js` at its top and run the code in its body.
2. Bootstrapping separate application modules: if the entry module hands off to other modules such as `./app.js`, chain dynamic `import()` calls with top-level `await`, so `./app.js` is fetched and evaluated only after the polyfill module resolves.

```javascript
// main.js

await import('./conditionally-load-polyfill.js');
await import('./app.js');
```

## Browser support and fallback

Baseline status for Top-level await: Newly available. It's been Baseline since 2026-09-14.
Supported by: Chrome 89 (Mar 2021), Edge 89 (Mar 2021), Firefox 89 (Jun 2021), and Safari 27 (Sep 2026).

Basic top-level `await` has worked in all major browsers since 2021 (Chrome 89, Edge 89, Firefox 89 and Safari 15), but it became fully spec-compliant only in [Safari 27](https://webkit.org/blog/18227/fixing-top-level-await-in-safari/) (see [MDN browser compatibility](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/await#browser_compatibility)).

- Safari 15–26.6: if you follow the single-entry-point pattern above, so that sibling modules never import the top-level `await` module concurrently, top-level `await` is safe without any further fallback.
- Browsers from before 2021 with no top-level `await` support: avoid top-level `await` and wrap the conditional `import()` orchestration in an ordinary `async` function or a `.then()` promise chain.
