# Break Up Long Tasks

Heavy computation or long loops block the main thread, which delays event handlers and hurts Interaction to Next Paint (INP). Yield to the browser periodically with `scheduler.yield()`: it pauses the running task so the browser can handle pending input and rendering, then continues.

`scheduler.yield()` only splits a task that is already running. It does not order separate work streams (`'user-blocking'`, `'user-visible'`, `'background'`), defer non-urgent work before it starts, or abort and reprioritize queued tasks through `TaskController`. So when work needs different priorities, keep `scheduler.postTask()` or `TaskController` rather than replacing them with `scheduler.yield()`; the `schedule-tasks-by-priority` guide covers that. When a task scheduled with `scheduler.postTask()` itself runs longer than 50ms, combine the two by calling `await scheduler.yield()` inside the `postTask()` callback; the continuation inherits the enclosing task's priority and `TaskSignal`.

## Breaking up long tasks

Call `scheduler.yield()` inside async functions. Use a time-based deadline of 50ms, the threshold at which a task becomes a long task: when the deadline passes, yield, then set a new deadline 50ms ahead.

```javascript
async function processLargeArray(items) {
  let deadline = performance.now() + 50;

  for (const item of items) {
    processItem(item);

    if (performance.now() >= deadline) {
      await scheduler.yield();
      deadline = performance.now() + 50;
    }
  }
}
```

## Fallback

Browser support for Scheduler API: Limited availability.
Supported by: Chrome 129 (Sep 2024), Edge 129 (Sep 2024), and Firefox 142 (Aug 2025).
Unsupported in: Safari.

If your Baseline target lacks the Scheduler API, fall back to `setTimeout` so long loops still yield without throwing. If you also use `scheduler.postTask()`, feature-detect `postTask` separately.

```javascript
async function processLargeArrayWithFallback(items) {
  let deadline = performance.now() + 50;

  for (const item of items) {
    processItem(item);

    if (performance.now() >= deadline) {
      if ('scheduler' in window && 'yield' in window.scheduler) {
        await scheduler.yield();
      } else {
        await new Promise(resolve => setTimeout(resolve, 0));
      }
      deadline = performance.now() + 50;
    }
  }
}
```
