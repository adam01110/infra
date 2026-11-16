# Reliably measure full-session analytics and telemetry

To send analytics, Core Web Vitals and telemetry data that cover the whole visit to a page, not just the time until load, use the `fetchLater()` API.

`fetchLater()` is the most reliable way to send data when no response is needed and delivery is not urgent: user analytics, telemetry, error tracking, and performance metrics such as Core Web Vitals.

Older techniques, such as creating an `<img>` pixel in an `unload` listener, are unreliable, especially on mobile, and hurt performance because `unload` listeners make pages ineligible for the back/forward cache (bfcache).

## How to implement

1. As soon as relevant data is available, call `fetchLater()` with the payload. This queues it to be sent later.
2. When more data arrives or the state changes, abort the previously scheduled request and call `fetchLater()` again with the full updated snapshot.
3. When the user navigates away or closes the tab, the browser sends the payload from the most recent `fetchLater()` call.

## Example

This measures session duration, queuing a new beacon with the updated duration every 10 seconds.

```javascript
const ANALYTICS_ENDPOINT = '/path/to/analytics/endpoint';

const sessionData = {
  duration: 0,
  id: crypto.randomUUID(),
};

let fetchLaterController = null;

function queueBeacon() {
  // Abort the pending beacon before scheduling a new one.
  if (fetchLaterController) {
    fetchLaterController.abort();
  }
  fetchLaterController = new AbortController();

  sessionData.duration = performance.now();

  // fetchLater() throws on quota errors, so wrap it in try/catch.
  try {
    fetchLater(ANALYTICS_ENDPOINT, {
      method: 'POST',
      headers: {'content-type': 'application/json'},
      body: JSON.stringify(sessionData),
      signal: fetchLaterController.signal,
    });
  } catch (error) {
    // Handle errors as needed.
  }
}

setInterval(queueBeacon, 10000);
```

## Guidelines

- Use `fetchLater()` whenever data goes to a server, no response is needed, and it need not be sent immediately.
- Use an `AbortController` to cancel the pending fetch when the data may change before the user leaves.
- Keep the payload small to stay under the quota (currently roughly 64KB per origin).
- Wrap `fetchLater()` calls in `try/catch` to handle quota errors.
- Feature-detect `fetchLater` on `globalThis` and provide a fallback for browsers without it.
- Do not pass a `ReadableStream` as the request body; it throws an error.

## Browser support and fallback

Browser support for fetchLater: Limited availability.
Supported by: Chrome 135 (Apr 2025) and Edge 135 (Apr 2025).
Unsupported in: Firefox and Safari.

If `fetchLater()` is not in your Baseline target, you need a fallback. Still use `fetchLater()` where it is supported, because it is more reliable and performs better.

The recommended fallback is the polyfill below. It uses `fetch()` with `keepalive` or `navigator.sendBeacon()` internally. For data sent this way, your own code should always call `fetchLater()`, not `fetch()`, `sendBeacon()` or other beacon APIs directly; the polyfill handles delivery.

### `fetchLater()` polyfill

This minimal polyfill follows the API as closely as possible. The one notable difference is that it uses `visibilitychange` (sending when the page becomes hidden) to detect that the user is leaving, instead of the browser's native unload handling. That is internal to the polyfill: your code does not need to listen for `visibilitychange` or any other lifecycle event. Call `fetchLater()` and the polyfill handles delivery.

```js
globalThis.fetchLater ??= function fetchLater(url, init = {}) {
  let timeoutHandle;
  let activated = false;

  function sendNow() {
    if (!(init.signal && init.signal.aborted)) {
      // Use fetch keepalive when supported or when custom fetch options
      // (method, headers) are set; otherwise use navigator.sendBeacon().
      if (
        'keepalive' in Request.prototype ||
        init.method !== 'POST' ||
        init.headers
      ) {
        fetch(url, Object.assign({}, init, {keepalive: true}));
        activated = true;
      } else {
        activated = navigator.sendBeacon(url, init.body);
      }
    }
    destroy();
  }

  function destroy() {
    document.removeEventListener('visibilitychange', sendNow);
    clearTimeout(timeoutHandle);
  }

  if (document.visibilityState === 'hidden') {
    // Already hidden: send soon, after the current synchronous code runs.
    queueMicrotask(sendNow);
  } else {
    document.addEventListener('visibilitychange', sendNow);

    if (typeof init.activateAfter === 'number' && init.activateAfter >= 0) {
      timeoutHandle = setTimeout(sendNow, init.activateAfter);
    }
  }

  if (init.signal) {
    init.signal.addEventListener('abort', destroy);
  }

  return {
    get activated() {
      return activated;
    },
  };
};
```
