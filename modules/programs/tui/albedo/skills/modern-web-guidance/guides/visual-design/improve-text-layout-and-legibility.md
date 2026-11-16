# Improve Text Layout and Legibility

How text breaks, especially at the ends of lines and paragraphs, affects legibility and appearance. CSS text-wrapping options improve specific cases:

- `text-wrap: balance` distributes text as evenly as possible across lines for a more symmetrical shape. Use it for short blocks such as headings.
- `text-wrap: pretty` uses a more sophisticated wrapping algorithm for body text. It is designed to avoid orphans (a single word on the last line of a paragraph, also called runts) and to give long text a more even rag.

## Implementation

### 1. Choose the elements

For `text-wrap: balance`, pick short text blocks such as headings and table headers. Avoid elements with a visible box (border, background), where balancing can leave visibly empty areas.

For `text-wrap: pretty`, pick elements that may hold long runs of text, where orphans and poor breaks are most noticeable: `<p>`, `<blockquote>`, `<li>`, and any other element that may contain long text.

| Criterion | `text-wrap: balance` | `text-wrap: pretty` | `text-wrap: wrap` (default) |
| :--- | :--- | :--- | :--- |
| Best for | Short blocks (headings, titles) | Long blocks (paragraphs, lists) | Performance-critical content |
| Visual goal | Symmetrical line lengths | Avoiding orphans | Fast, standard wrapping |
| Line count | Up to 6–10 lines (algorithm limit) | 3 lines or more | No limit |
| Performance cost | High: binary search | Medium: look-back | Low: standard greedy algorithm |

### 2. Apply the wrapping

Apply `text-wrap: balance` to short multi-line elements such as headings (`h1`–`h6`), subheadings and pull quotes.

```css
h1, h2, h3, h4, h5, h6 {
  text-wrap: balance;
}
```

`text-wrap: pretty` evaluates the last few lines of a paragraph to find better break points.

```css
p, blockquote, li, .pretty-text {
  text-wrap: pretty;
}
```

## Constraints and performance

### `text-wrap: balance`

- Line limit: to protect performance, browsers balance only up to a number of lines (typically 6 in Chromium, 10 in Firefox). Longer text falls back to normal `wrap`, so don't use `balance` on text likely to exceed these limits.
- Apply it to specific short elements, never globally (as in `* { text-wrap: balance; }`): the iterative binary-search algorithm is computationally expensive.
- It doesn't change the container's width (`inline-size`), only how text wraps within it. This can leave empty space at the end of the container, which may affect layouts that rely on full-width text blocks.

### `text-wrap: pretty`

- It costs more than the default greedy `wrap` algorithm because it evaluates several lines (typically the last four) to optimize break points. Don't apply it to every element on pages with very large amounts of text.
- Its benefit shows in paragraphs of three or more lines; it does little or nothing for short, single-line text.
- Implementations differ: Chromium-based browsers typically consider the last four lines, while other engines may evaluate the whole paragraph.

## Fallback strategies

Baseline status for text-wrap: balance: Newly available. It's been Baseline since 2024-05-13.
Supported by: Chrome 114 (May 2023), Edge 114 (Jun 2023), Firefox 121 (Dec 2023), and Safari 17.5 (May 2024).

Browser support for text-wrap: pretty: Limited availability.
Supported by: Chrome 117 (Sep 2023), Edge 117 (Sep 2023), and Safari 26 (Sep 2025).
Unsupported in: Firefox.

Browsers that don't support `balance` or `pretty` ignore the value and wrap text with the default `wrap` behavior. Both are progressive enhancements, so content stays readable everywhere.

Where refined text layout is a hard requirement, a JavaScript library can do it, but it may be slow and cause performance problems.
