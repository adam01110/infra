# Optimize script priority

Browsers assign script priorities by document position and by attributes such as `async` and `defer`. `fetchpriority` lets you override this so critical scripts load first and non-essential ones stay out of the way.

## How to implement

1. Identify the scripts essential to the page's core functionality or first interaction.
2. Add `fetchpriority="high"` to critical scripts loaded with `async` or `defer`, so they are prioritized when discovered.
3. Add `fetchpriority="low"` to scripts not needed immediately, such as analytics, ads or below-the-fold widgets, and make sure they use `async`, `defer` or `type="module"` so they do not block.
4. Add `fetchpriority="low"` to parser-blocking scripts at the end of the body, so they do not compete for bandwidth with more critical resources.

## Example

```html
<!-- Critical app logic. -->
<script src="/js/app.js" async fetchpriority="high"></script>

<!-- Non-essential tracking. -->
<script src="/js/tracker.js" async fetchpriority="low"></script>

<!-- Late-body script, deprioritized in favor of critical images or CSS. -->
<script src="/js/legacy-widgets.js" fetchpriority="low"></script>
```

## Guidelines

- Use `fetchpriority="high"` on at most 1–2 critical scripts; more causes network contention and dilutes the boost.
- Use `fetchpriority="high"` mainly for `async` scripts known to be critical for Interaction to Next Paint (INP).
- Use `fetchpriority="low"` for scripts the initial experience does not need.
- Do not add `fetchpriority` to every script. Use it only where the browser's default heuristic is known to be suboptimal.
- Do not use the deprecated `importance` attribute; `fetchpriority` replaced it.

## Browser support and fallback

Baseline status for Fetch priority: Newly available. It's been Baseline since 2024-10-29.
Supported by: Chrome 103 (Jun 2022), Edge 103 (Jun 2022), Firefox 132 (Oct 2024), and Safari 17.2 (Dec 2023).

`fetchpriority` is a progressive enhancement. Browsers without support ignore it and use their own scheduling without error, so basic use needs no feature detection or fallback.
