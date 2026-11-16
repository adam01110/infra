# Debounce and batch multiple analytics events

Most analytics, telemetry and Core Web Vitals data is lower priority than responding to the user, so it can wait until the user leaves the page. The exception is real-time reporting, where timeliness matters.

For real-time updates with the fewest beacons, use `fetchLater()` with the `activateAfter` option. It batches every event in a time window into one beacon, and the browser still sends it if the user leaves before the timeout expires.

## How to implement

1. Schedule the request: as soon as analytics data is available, call `fetchLater()` with the payload and an `activateAfter` value. The data is sent after that time passes, or earlier if the user leaves the page.
2. Batch events: if a new event occurs before the `activateAfter` timeout expires, abort the previously scheduled request and call `fetchLater()` again, with the same `activateAfter` value, sending the full event queue as one payload.
3. Reset the queue once the beacon has sent: if a new event occurs after the scheduled beacon was sent (the `fetchLater()` result's `activated` is `true`), clear the queue first.
4. If the user navigates away or closes the tab before the timeout, the browser still sends the payload from the most recent `fetchLater()` call.

## Example

This tracks every `load` and `click` event and batches events that occur within a 10-second window.

```javascript
const ANALYTICS_ENDPOINT = '/path/to/analytics/endpoint';

// Events within this window are batched together.
const BATCH_WINDOW = 10 * 1000;

// An event-count cap that stands in for the byte quota: keep it low enough
// that the payload stays under the page's fetchLater() quota.
const MAX_QUEUE_SIZE = 100;

const eventQueue = [];
let fetchLaterResult;
let fetchLaterController;

function trackEvent(eventData) {
  // Start a new queue if the previous beacon was sent or the queue is full.
  if (fetchLaterResult?.activated || eventQueue.length > MAX_QUEUE_SIZE) {
    fetchLaterController = null;
    fetchLaterResult = null;
    eventQueue.length = 0;
  }

  eventQueue.push(eventData);

  // Abort the pending beacon before scheduling a new one.
  if (fetchLaterController) {
    fetchLaterController.abort();
  }
  fetchLaterController = new AbortController();

  // fetchLater() throws on quota errors, so wrap it in try/catch.
  try {
    fetchLaterResult = fetchLater(ANALYTICS_ENDPOINT, {
      method: 'POST',
      headers: {'content-type': 'application/json'},
      body: JSON.stringify(eventQueue),
      signal: fetchLaterController.signal,
      activateAfter: BATCH_WINDOW,
    });
  } catch (error) {
    // Handle errors as needed.
  }
}

window.addEventListener('load', () => {
  trackEvent({type: 'page_load'});
});

window.addEventListener('click', (event) => {
  // serializeElement() is your own helper.
  trackEvent({type: 'click', target: serializeElement(event.target)});
});
```

## Guidelines

- Use `fetchLater()` with `activateAfter` to batch analytics events that occur close together.
- Use an `AbortController` to cancel the pending fetch when a new event arrives.
- Cap the batch size so you stay under the `fetchLater()` quota (currently roughly 64KB per origin).
- Wrap `fetchLater()` calls in `try/catch` to handle quota errors.
- Feature-detect `fetchLater` on `globalThis` and provide a fallback for browsers without it.
- Do not pass a `ReadableStream` as the request body; it throws an error.

## Browser support and fallback

Browser support for fetchLater: Limited availability.
Supported by: Chrome 135 (Apr 2025) and Edge 135 (Apr 2025).
Unsupported in: Firefox and Safari.

A fallback is usually required. Still use `fetchLater()` where it is supported, because it is more reliable and performs better.

### `fetchLater()` polyfill

This minimal polyfill follows the API as closely as possible. The one notable difference: instead of sending when the user leaves the page, it sends when `visibilityState` changes to `"hidden"`, the most reliable widely available end-of-session signal.

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
