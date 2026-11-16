# Schedule Tasks By Priority

Tasks in a complex web application differ in urgency: work for the current view matters more than sending analytics or prefetching assets. The Prioritized Task Scheduling API (`scheduler.postTask()` and `TaskController`) schedules, reprioritizes and cancels work across priority levels, so the main thread stays responsive to input.

`scheduler.postTask()` controls when tasks start relative to each other, but a single callback that runs longer than 50ms still blocks the main thread once it starts. To split long work inside a task while keeping its priority and `TaskSignal`, call `await scheduler.yield()` periodically inside the callback; the `break-up-long-tasks` guide covers this.

## Scheduling tasks by priority

`scheduler.postTask()` takes one of three priorities:

- `user-blocking`: tasks that block user interaction, such as input handling or critical rendering.
- `user-visible`: tasks the user sees but that do not block interaction. This is the default.
- `background`: work that is not time-critical, such as analytics, background indexing or prefetching.

```javascript
// Critical updates that affect user interaction.
scheduler.postTask(() => {
  handleCriticalUpdate();
}, { priority: 'user-blocking' });

// Visible, non-critical content (defaults to 'user-visible').
scheduler.postTask(() => {
  renderSecondaryContent();
});

// Heavy background work that is not time-critical.
scheduler.postTask(() => {
  sendAnalytics();
}, { priority: 'background' });
```

## Aborting or reprioritizing tasks with `TaskController`

`TaskController` is optional. Use it when queued work can become stale or change urgency, such as background indexing that should stop on navigation or a prefetched view that the user opens: create a controller and pass `controller.signal` to `scheduler.postTask()`.

Do not also pass `priority` in that call: an explicit `priority` alongside `signal` overrides the signal's priority, and `controller.setPriority()` then has no effect.

```javascript
const controller = new TaskController({ priority: 'background' });

const taskPromise = scheduler.postTask(async () => {
  await buildSearchIndex();
}, { signal: controller.signal });

// Promote it if the user needs it now, or call controller.abort() to cancel.
controller.setPriority('user-blocking');
```

## Browser support and fallback

Browser support for Scheduler API: Limited availability.
Supported by: Chrome 129 (Sep 2024), Edge 129 (Sep 2024), and Firefox 142 (Aug 2025).
Unsupported in: Safari.

If your Baseline target lacks the Prioritized Task Scheduling API and your application relies on ordering across priority levels (`user-blocking`, `user-visible`, `background`) or on `TaskController.setPriority()`, feature-detect `scheduler.postTask` and load `scheduler-polyfill` with a dynamic `import()` only when it is missing, so supporting browsers pay no bundle cost. Top-level `await` needs a module script, and the bare specifier needs a bundler or import map:

```javascript
if (!('scheduler' in window && 'postTask' in window.scheduler)) {
  await import('scheduler-polyfill');
}

// scheduler.postTask and TaskController now work in every browser.
scheduler.postTask(() => {
  sendAnalytics();
}, { priority: 'background' });
```

If you use `scheduler.postTask()` only to move non-urgent background work off the current turn, and need neither cross-task priority ordering nor `setPriority()`, skip the dependency: fall back to `setTimeout(callback, 0)` when `scheduler.postTask` is unavailable, and if you pass an `AbortSignal`, check `signal?.aborted` before running the callback.
