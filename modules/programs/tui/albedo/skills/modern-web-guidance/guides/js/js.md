# JavaScript

Modern JavaScript and web platform runtimes have built-in primitives for deep cloning, non-mutating collection transforms, asynchronous coordination, query-string parsing, binary text encoding and DOM mutation. Using them instead of userland workarounds (`JSON.parse(JSON.stringify(...))`, `[...arr].sort()`, `.reduce()` bucket accumulators, manual `AbortController` timers, `innerHTML = ''` and clearing loops) avoids subtle data corruption, prototype pollution, call-stack overflows and needless parser work.

## Related guides

| Workflow | Guide |
| :--- | :--- |
| Exact calendar durations (`years`, `months`, `days`) between dates or events | the `calculate-event-differentials` guide |
| Calendar dates (`PlainDate`), wall-clock times (`PlainTime`) or recurring rules without time-zone shift bugs | the `capture-location-agnostic-data` guide |
| Converting instants across IANA time zones (`ZonedDateTime`) with DST disambiguation | the `coordinate-global-events` guide |
| Sorting and comparing nanosecond-precision timestamps (`Temporal.Instant.compare`) | the `sort-high-precision-timestamps` guide |
| Projecting dates into non-Gregorian calendars (`hebrew`, `islamic-civil`, `japanese`, `chinese`) | the `support-global-calendar-systems` guide |
| Sanitizing untrusted HTML strings before DOM insertion | the `sanitize-untrusted-html` guide |

## 1. Immutable data, deep cloning and grouping

### Deep cloning with `structuredClone()`

Use `structuredClone(value)` to deep-copy nested objects, arrays and built-in platform types without a round trip through a JSON string.

- Prefer `structuredClone(value)` over `JSON.parse(JSON.stringify(value))` or recursive cloning utilities (`_.cloneDeep`) for copying structured state in memory.
- It preserves cyclic references, shared references (DAGs), `Date`, `RegExp`, `Map`, `Set`, `ArrayBuffer`, `TypedArray`, `DataView`, `BigInt`, `Error` instances, `undefined` property values, `NaN`, `Infinity`, `-0` and sparse array holes.
- Pass `{ transfer: [arrayBuffer] }` to move ownership of `ArrayBuffer` or `MessagePort` instances without copying the underlying bytes.
- Keep `JSON.parse(JSON.stringify(value))` when callers depend on JSON wire normalization or transforms, because `structuredClone()` does none of these:
  - Converting `Date` instances to ISO 8601 strings (`Date.prototype.toJSON()`), or running a `JSON.stringify` `replacer` (allowlists, redaction) or a `JSON.parse` `reviver`.
  - Calling custom `.toJSON()` methods. `structuredClone()` ignores inherited or non-enumerable `.toJSON()` methods and throws `DataCloneError` if an object has own enumerable function properties, such as `.toJSON` or the methods of an imported library singleton or options object.
  - Dropping keys whose values are `undefined`, functions or `Symbol`s; turning `NaN`, `Infinity`, `-Infinity` and sparse holes into `null` (and `-0` into `+0`); or deliberately breaking shared DAG references (`a.x !== a.y`) so callers can mutate aliased branches independently.
- `structuredClone()` throws a `DOMException` (`DataCloneError`) on non-cloneable values, so do not pass:
  - Functions, or library singletons and options objects with own enumerable methods. (`JSON.stringify` silently omits function properties on objects and turns function array elements into `null`.)
  - `Symbol` values or `Symbol`-keyed properties. (`JSON.stringify` silently ignores them.)
  - DOM nodes (`Element`, `Document`, `Node`); live browser/WebIDL objects such as `window.location`, `localStorage`, `element.dataset` (`DOMStringMap`), `getComputedStyle(el)` (`CSSStyleDeclaration`), DOM `Event`, `URLSearchParams`, `FormData` and `Headers` (serializable geometry objects like `DOMRect` do clone); `Promise`, `WeakMap`, `WeakSet`; or any `Proxy`, including generic wrappers and reactive stores such as Vue `reactive()` or MobX observables.
- `structuredClone()` does not preserve custom class prototypes, class methods, non-enumerable properties, property descriptors or `#private` fields. Like the JSON round trip, it resets the prototype chain to `Object.prototype`, drops non-enumerable properties and `#private` fields, and evaluates enumerable getters once into plain data properties.

`structuredClone` is a host-provided global, not an ECMAScript intrinsic. In isolated Node.js `vm.createContext({})` sandboxes, or legacy custom test environments that do not expose host globals on the context object, it may be `undefined` unless injected into the context.

```js
const original = {
  id: 'session-42',
  createdAt: new Date('2026-03-15T12:00:00Z'),
  tags: new Set(['admin', 'audit']),
  metrics: new Float64Array([0.98, 0.99]),
  optionalNote: undefined,
};
original.self = original; // Circular reference.

const copy = structuredClone(original);

console.assert(copy !== original);
console.assert(copy.createdAt instanceof Date);
console.assert(copy.tags instanceof Set && copy.tags !== original.tags);
console.assert(copy.self === copy);
console.assert('optionalNote' in copy && copy.optionalNote === undefined);
```

### Non-mutating array copies and reverse search

The copying array methods (`.toSorted()`, `.toReversed()`, `.toSpliced()`, `.with()`) and reverse search methods (`.findLast()`, `.findLastIndex()`) transform or query an array without mutating it and without an intermediate shallow clone.

- `array.toSorted(compareFn)` replaces `[...array].sort(compareFn)`, `array.slice().sort(compareFn)` and `Array.from(array).sort(compareFn)`.
- `array.toReversed()` replaces `[...array].reverse()` and `array.slice().reverse()`.
- `array.toSpliced(start, deleteCount, ...items)` does immutable insertion, deletion and replacement, instead of cloning and calling `.splice()`.
- `array.with(index, value)` updates one index immutably (negative indices work), instead of copying and assigning `clone[index] = value`.
- `array.findLast(predicate)` and `array.findLastIndex(predicate)` replace `[...array].reverse().find(predicate)` and manual reversed-index math.
- Before refactoring `arr.slice().reverse().findIndex(fn)`, audit multi-argument callbacks and miss handling. `findLast()` / `findLastIndex()` pass the original forward `index` to `(item, index, arr)`, not the reversed-copy index. And the old `arr.length - 1 - (-1)` math yields `arr.length`, an out-of-bounds index, on a miss, whereas `findLastIndex()` returns `-1`.
- Keep the `[...iterable]` / `Array.from()` conversion when the receiver is a string, a non-Array iterable or an array-like (`Set`, `Map.keys()`, `Map.values()`, a generator, `NodeList`, `HTMLCollection`, `arguments`). Calling `.toSorted()` or `.toReversed()` on a string, `Set` or `NodeList` throws a `TypeError`. Convert, then chain the mutating method to avoid a redundant second copy: `[...set].sort(compareFn)`, `[...nodeList].reverse()`, or `Array.from(str).toReversed().join('')`.
- Replace `[...typedArray].sort()` with `typedArray.toSorted()` only if numeric ordering and a `TypedArray` result are intended. `Array.prototype.sort()` / `.toSorted()` compare elements as UTF-16 strings by default (`[10, 2].toSorted()` is `[10, 2]`), whereas `%TypedArray%.prototype.toSorted()` sorts numerically (`new Uint8Array([10, 2]).toSorted()` is `Uint8Array [2, 10]`) and returns a `TypedArray`, not a plain `Array`. `%TypedArray%.prototype` has no `.toSpliced()`, because typed arrays have a fixed byte length.
- Do not use `.toSorted()` or `.toReversed()` where code relies on sparse holes being preserved (`!(i in arr)`). Copying methods always produce dense arrays with holes turned into `undefined` elements (`0 in [, 1].toReversed()` is `true`), whereas `Array.prototype.slice()`, `.sort()` and `.reverse()` keep empty slots.

```js
const tasks = [
  { id: 1, priority: 2, status: 'done' },
  { id: 2, priority: 5, status: 'open' },
  { id: 3, priority: 1, status: 'done' },
];

// `tasks` is not mutated.
const byPriority = tasks.toSorted((a, b) => b.priority - a.priority);
const reopened = tasks.with(-1, { ...tasks.at(-1), status: 'open' });

// No reversed copy is allocated.
const lastCompleted = tasks.findLast((task) => task.status === 'done');
const lastCompletedIndex = tasks.findLastIndex((task) => task.status === 'done');
```

### Grouping iterables (`Object.groupBy()` and `Map.groupBy()`)

`Object.groupBy(items, callbackFn)` and `Map.groupBy(items, callbackFn)` partition any iterable into array buckets in one step.

- Use `Object.groupBy(items, (item, index) => key)` instead of `items.reduce((acc, item) => { (acc[key] ??= []).push(item); return acc; }, {})` when grouping into string or symbol keys and each bucket holds the original, unmodified elements. It creates properties with `CreateDataProperty`, so keys like `'constructor'` or `'toString'` never collide with `Object.prototype`.
- Use `Map.groupBy(items, (item, index) => key)` when grouping by object references or class instances, or by primitives whose type (`number`, `boolean`, `undefined`, `BigInt`) must survive. `Object.groupBy()` coerces keys with `ToPropertyKey` (`String(key)`), turning objects into `'[object Object]'`.
- `Object.groupBy()` returns a null-prototype object (`Object.getPrototypeOf(grouped) === null`, `grouped instanceof Object === false`). Read buckets with `Object.hasOwn(groups, key)` or `groups[key] ?? []`. Do not call `Object.prototype` methods on it or rely on `instanceof Object`: `groups.hasOwnProperty` is `undefined`, so calling it throws a `TypeError`.
- Keep `.reduce()` when the accumulator also transforms elements (`acc[key].push(item.id)`), computes scalar aggregates (counts, sums, min/max), or pre-seeds keys with no matching items. `Object.groupBy()` only creates keys that occur at least once in `items`.

```js
const deliveries = [
  { id: 'd1', region: 'eu-west', weightKg: 4.2 },
  { id: 'd2', region: 'us-east', weightKg: 1.1 },
  { id: 'd3', region: 'eu-west', weightKg: 8.5 },
];

// Null-prototype object of arrays, keyed by string.
const byRegion = Object.groupBy(deliveries, (item) => item.region);
const euShipments = byRegion['eu-west'] ?? [];

// Object keys kept as-is in a Map.
const heavyKey = { tier: 'heavy' };
const standardKey = { tier: 'standard' };
const byTier = Map.groupBy(deliveries, (item) =>
  item.weightKg >= 5 ? heavyKey : standardKey,
);
```

## 2. Asynchronous coordination, cancellation and error chaining

### Settling a promise from outside (`Promise.withResolvers()`)

Use `Promise.withResolvers()` when `resolve` and `reject` must be stored or called outside the `new Promise` executor, such as in event listeners, worker message handlers, stream queues or cancellation tokens.

- Write `const { promise, resolve, reject } = Promise.withResolvers()` instead of mutable outer variables (`let resolve, reject; const promise = new Promise((res, rej) => { resolve = res; reject = rej; });`). For a `Promise` subclass, use `Promise.withResolvers.call(SubPromise)`.
- Keep `new Promise((resolve, reject) => { ... })` when the asynchronous operation is self-contained in the executor.
- When moving synchronous setup code out of an executor, wrap it in `try` / `catch` that calls `reject(err)`. A synchronous throw inside an executor rejects the promise automatically; a throw after `Promise.withResolvers()` becomes an uncaught synchronous exception.

```js
export function createRequestGate() {
  const { promise, resolve, reject } = Promise.withResolvers();
  return {
    waitUntilReady: () => promise,
    open: (config) => resolve(config),
    abort: (reason) => reject(new Error(`Gate aborted: ${reason}`)),
  };
}
```

### Timeouts and combined cancellation (`AbortSignal.timeout()` and `AbortSignal.any()`)

`AbortSignal.timeout(ms)` bounds an operation in time, and `AbortSignal.any(signals)` combines cancellation sources without manual timer bookkeeping.

- Pass `{ signal: AbortSignal.timeout(ms) }` directly to `fetch()`, `addEventListener()`, streams or other abortable APIs instead of creating a one-off `AbortController` with `setTimeout(() => controller.abort(), ms)`.
- Combine user cancellation with a deadline using `AbortSignal.any([controller.signal, AbortSignal.timeout(ms)])`. The combined signal aborts as soon as any input aborts and carries that input's `reason`.
- A timeout aborts with a different error name than a manual abort. `controller.abort()` with no argument sets `signal.reason` to a `DOMException` named `'AbortError'`; `AbortSignal.timeout(ms)` uses a `DOMException` named `'TimeoutError'` (`err.code === DOMException.TIMEOUT_ERR`, `23`). If you need to tell user cancellation from a deadline in a `catch` block, check `error.name` for both `'TimeoutError'` and `'AbortError'`.
- `ms` is required and must not be negative: omitting it throws a `TypeError`, and a negative delay throws a `RangeError` or `TypeError`.
- In Node.js, `AbortSignal.timeout(ms)` uses an unref'd timer and does not keep the event loop alive on its own.
- Keep a manual `AbortController` + `setTimeout` when the timer resets on activity (sliding or idle timeouts, debounce) or a custom abort reason is needed before expiry.

```js
export async function fetchJsonWithDeadline(url, userSignal, timeoutMs = 5_000) {
  const signal = userSignal
    ? AbortSignal.any([userSignal, AbortSignal.timeout(timeoutMs)])
    : AbortSignal.timeout(timeoutMs);

  try {
    const response = await fetch(url, { signal });
    if (!response.ok) {
      throw new Error(`HTTP ${response.status} for ${url}`);
    }
    return await response.json();
  } catch (err) {
    if (err instanceof DOMException && err.name === 'TimeoutError') {
      throw new Error(`Request to ${url} timed out after ${timeoutMs}ms`, { cause: err });
    }
    throw err;
  }
}
```

### Chaining errors with `{ cause }`

When catching an error and re-throwing it as a different error across architectural layers, attach the original with the `{ cause }` option.

- Pass `{ cause: err }` as the second argument to `new Error(message, { cause: err })` or a built-in subclass (`TypeError`, `RangeError`, `SyntaxError`, `URIError`, `EvalError`, `AggregateError`). Custom `Error` subclasses must accept `(message, options)` and forward both to `super(message, options)`, or `.cause` is lost.
- Replace string-concatenated re-throws (`new Error('Failed: ' + err.message)`) with `new Error(message, { cause: err })` where the concatenation only stood in for structured chaining. Keep the interpolated `${err.message}` alongside `{ cause: err }` when callers or tests assert on a substring of the outer `.message`.
- Set the cause through the constructor, not with `wrapper.cause = err` afterwards, which creates an enumerable property instead of the spec's non-enumerable one.
- Cause chains can contain database queries, file paths or credentials. Do not send them raw to untrusted clients; log the full `error.cause` chain server-side and sanitize client-facing payloads.

```js
export class ProfileLoadError extends Error {
  constructor(message, options) {
    super(message, options);
    this.name = 'ProfileLoadError';
  }
}

export async function loadUserProfile(userId, readRecord) {
  try {
    const raw = await readRecord(`users:${userId}`);
    return JSON.parse(raw);
  } catch (err) {
    throw new ProfileLoadError(
      `Failed to load profile for user "${userId}": ${err.message}`,
      { cause: err },
    );
  }
}
```

## 3. URL query strings and binary text encoding

### Parsing and building query strings (`URLSearchParams`)

Use `URLSearchParams` (and `new URL(input, base).searchParams`) to parse, inspect, change and serialize query strings instead of `.split('&')` / `.split('=')` loops with `decodeURIComponent`.

- Read or change parameters with `new URLSearchParams(search)` (`.get(key)`, `.getAll(key)`, `.has(key)`, `.set(key, value)`, `.toString()`), or turn them into a plain object with `Object.fromEntries(new URLSearchParams(search))`.
- Starting from a full URL string (`https://example.com/path?a=1#section`), use `new URL(fullUrl, baseOrigin).searchParams`. `new URLSearchParams(fullUrl)` only strips one leading `?`, so it treats `https://example.com/path?a` as part of the first key name.
- `URLSearchParams` keeps `=` characters inside values (such as Base64 padding in `?token=aGVsbG8=`, which `.split('=')[1]` truncates) and avoids `Object.prototype` pollution when building lookup maps.
- It follows `application/x-www-form-urlencoded` rules, which differ from hand-rolled parsers:
  - `+` decodes as a space, whereas `decodeURIComponent('a+b')` keeps `a+b`. When `+` must stay literal (phone numbers, Base64), encode it as `%2B` at the source.
  - Valueless flags: `?debug` and `?debug=` both give `""` (`params.has('debug') === true`, `params.get('debug') === ''`), where custom `split('=')` parsers sometimes produce `undefined` or `true`.
  - Duplicate keys (`?tag=a&tag=b`): `params.get('tag')` returns the first value (`'a'`), `Object.fromEntries(params)` keeps the last (`'b'`), and `params.getAll('tag')` returns `['a', 'b']`.
  - Malformed input does not throw. Non-hex escapes (`%ZZ`) stay literal `'%ZZ'`, and invalid UTF-8 sequences (`%E0%A4%A`) become `\uFFFD`. Keep `decodeURIComponent` inside `try` / `catch` when malformed URIs must be rejected.
  - Bracket keys (`?ids[]=1&user[name]=alice`) stay flat literal keys.
  - Only one leading `?` is stripped: `new URLSearchParams('??a=1')` has `'?a'` as its first key.
- `URLSearchParams` does not strip `#`. Passing `location.hash` directly makes `'#tab=2'` parse as key `'#tab'`, so use `hash.slice(1)`. For hash-routing fragments (`'#/route?a=1'`), extract the part after `?` first: `hash.slice(hash.indexOf('?') + 1)`.
- `URLSearchParams` splits only on `&`, so it cannot parse semicolon-delimited strings such as `document.cookie` or RFC 6265 `Cookie` headers.

```js
const query = '?filter=active&token=eyJhbGciOiJIUzI1NiJ9==&tag=js&tag=web';
const params = new URLSearchParams(query);

const token = params.get('token'); // 'eyJhbGciOiJIUzI1NiJ9==' (trailing '==' kept)
const allTags = params.getAll('tag'); // ['js', 'web']
const lastWinsDict = Object.fromEntries(params); // { filter: 'active', token: '...', tag: 'web' }

// Changing parameters on a full URL.
const endpoint = new URL('https://api.example.com/v1/items?page=1#results');
endpoint.searchParams.set('page', '2');
endpoint.searchParams.append('limit', '50');
```

### UTF-8 text decoding and encoding (`TextDecoder` and `TextEncoder`)

Use `TextDecoder` and `TextEncoder` to convert between `Uint8Array` byte buffers and strings.

- Decode UTF-8 bytes with `new TextDecoder().decode(bytes)`, not `decodeURIComponent(escape(binaryString))`, `String.fromCharCode.apply(null, bytes)` or `String.fromCharCode(...bytes)`. `String.fromCharCode` treats each byte as a UTF-16 code unit, which turns multi-byte UTF-8 into Latin-1 mojibake and overflows the call stack at around 65 KB and up. `Uint16Array` elements above `0xFF` are 16-bit code units, not raw UTF-8 bytes.
- Encode strings to UTF-8 `Uint8Array`s with `new TextEncoder().encode(str)` instead of character-code loops.
- For chunked input (`ReadableStream`, WebSocket frames, file chunks), reuse one `TextDecoder`, call `decoder.decode(chunk, { stream: true })` per chunk, and finish with a bare `decoder.decode()` to flush. This reassembles multi-byte code points split across chunk boundaries.
- Pass `{ fatal: true }` when invalid UTF-8 must throw instead of becoming `\uFFFD`. The error is a `TypeError`, not a `URIError`; `decoder.decode(string)` (passing a string) always throws a `TypeError`.
- By default a leading UTF-8 BOM (`0xEF 0xBB 0xBF`) is stripped; pass `{ ignoreBOM: true }` to keep it.
- Use `new TextDecoder('latin1')` (or `'iso-8859-1'`) only when you need one character per byte on large buffers without call-stack limits. Per the WHATWG Encoding standard both labels map to `windows-1252`, so bytes `0x80`–`0x9F` decode to characters such as `€` (`\u20AC`), not `\u0080`–`\u009F`.
- Raw binary strings for `btoa()` / `atob()` (one code unit per byte, `0x00`–`0xFF`) are not UTF-8 text, so do not build them with `new TextDecoder('utf-8')`: passing multi-byte UTF-8 decoder output to `btoa()` throws `InvalidCharacterError`. Use `TextEncoder` / `TextDecoder` for UTF-8 text payloads, and chunked `String.fromCharCode` (or Node.js `Buffer.from(bytes).toString('base64')`) for binary strings passed to `btoa()`.

```js
const encoder = new TextEncoder();
const decoder = new TextDecoder('utf-8', { fatal: true });

// No call-stack limit.
const bytes = encoder.encode('🚀 Modern Web Platform — 100% UTF-8');
const text = decoder.decode(bytes);

// Streaming decode across arbitrary chunk boundaries.
export async function readUtf8Stream(readableStream) {
  const streamDecoder = new TextDecoder();
  let output = '';
  for await (const chunk of readableStream) {
    output += streamDecoder.decode(chunk, { stream: true });
  }
  output += streamDecoder.decode(); // Flush trailing bytes.
  return output;
}
```

## 4. DOM child replacement and custom events

### Replacing and clearing children (`Element.prototype.replaceChildren()`)

`element.replaceChildren(...nodesOrStrings)` clears a container, or replaces all its children, in one operation.

- Clear all `childNodes` with `container.replaceChildren()` (no arguments) instead of:
  - `container.innerHTML = ''`, which invokes the HTML parser and fails under Trusted Types;
  - removal loops, where a forward `for` loop over live `children` / `childNodes` skips every other node.

  `replaceChildren()` batches the change into a single `MutationObserver` `childList` record (zero records on an already-empty element), and through `[CEReactions]` it fires custom elements' `disconnectedCallback()` after all removals finish rather than interleaved per node.
- `container.replaceChildren(...nodes)` clears and inserts new `Node`s or `DocumentFragment`s atomically: its `HierarchyRequestError` validation runs before any existing child is touched.
- Pass plain strings to insert literal text without HTML parsing: `container.replaceChildren(text)`. `el.replaceChildren('')` inserts an empty `Text` node (`childNodes.length === 1`), unlike `el.replaceChildren()`.
- For a `<template>`, call `templateElement.content.replaceChildren(...)`. `templateElement.replaceChildren()` leaves the inert `content` `DocumentFragment` untouched.
- In TypeScript, narrow `Node` references to `ParentNode` (`Element`, `Document`, `DocumentFragment`); leaf nodes (`Text`, `Comment`) have no `replaceChildren()`.
- Cases where `replaceChildren()` is the wrong replacement:
  - `while (el.firstElementChild) el.removeChild(el.firstElementChild)` when inline `Text` or `Comment` nodes must stay; `replaceChildren()` removes all `childNodes`.
  - Chained assignments such as `a.innerHTML = b.innerHTML = ''`; `replaceChildren()` returns `undefined`.
  - Raw HTML strings (`'<li>Item</li>'`) expected to become elements; strings are inserted as text. For untrusted HTML strings, follow the `sanitize-untrusted-html` guide.
  - A live `HTMLCollection` / `NodeList` such as `source.children` when `source` must keep its children; the nodes are moved, not copied.
  - `element.innerHTML = ''` on `<object>` or `<embed>` plugin containers, or in test harnesses that assert HTML parser steps.

```js
export function renderNotificationList(listElement, messages) {
  const items = messages.map((msg) => {
    const li = document.createElement('li');
    li.className = 'notification-item';
    li.textContent = msg;
    return li;
  });

  // Replaces all existing <li> children in one DOM operation.
  listElement.replaceChildren(...items);
}

// Clears a <template>'s inert DocumentFragment.
export function clearTemplate(templateEl) {
  templateEl.content.replaceChildren();
}
```

### Constructing events (`new Event()` and `new CustomEvent()`)

Use event constructors instead of the deprecated `document.createEvent()` with `initEvent()` / `initCustomEvent()`.

- Use `new Event(type, { bubbles, cancelable, composed })` for plain notifications and `new CustomEvent(type, { detail, bubbles, cancelable, composed })` for structured `event.detail` payloads.
- Replace `initMouseEvent` / `initKeyboardEvent` / `initUIEvent` with the specific WebIDL constructors (`new MouseEvent()`, `new KeyboardEvent()`, `new UIEvent()`). This avoids legacy `initKeyboardEvent` argument quirks and the read-only `keyCode === 0` problem.
- `bubbles` and `cancelable` default to `false`. Set `bubbles: true` for events that must bubble up the tree and `cancelable: true` for events that support `event.preventDefault()`. Set `composed: true` for events that must cross a shadow DOM boundary.
- Do not use `document.createEvent('Event')`, `document.createEvent('CustomEvent')`, `event.initEvent()` or `event.initCustomEvent()`.
- WebIDL dictionary fields are type-checked: a non-`EventTarget` value such as `relatedTarget: 0` in `MouseEventInit` throws a `TypeError`.

```js
// A bubbling, cancelable custom event that crosses shadow boundaries.
export function notifyFilterChange(filterPanel) {
  const filterChanged = new CustomEvent('filter-change', {
    detail: { category: 'architecture', minScore: 80 },
    bubbles: true,
    cancelable: true,
    composed: true,
  });

  return filterPanel.dispatchEvent(filterChanged);
}
```
