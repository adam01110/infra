# HTML

Sections:

1. Document semantics and validation
2. Content grouping and attribution
3. Resource prioritization and performance
4. Native overlays: dialogs and popovers
5. Disclosures: details and summary
6. Focus boundaries and visibility
7. Form helpers and autocomplete
8. Native media elements
9. Dynamic styles and interactivity

## 1. Document semantics and validation

- Start with the `<!DOCTYPE html>` doctype to avoid quirks-mode rendering.
- Set `lang` on `<html>` to the primary document language, and on any element whose language differs from it. Screen readers use it for pronunciation, translation tools rely on it, and locale-sensitive features such as CSS `hyphens` depend on it.
- Include `<meta name="viewport" content="width=device-width, initial-scale=1.0">` so the page is responsive.
- Use a single `<h1>` per page or view for the main topic. A modal dialog may also have its own single `<h1>`.
- Keep the heading hierarchy sequential without skipping levels: `<h2>` to `<h3>`, not `<h2>` to `<h4>`.
- Use the landmark elements `<header>`, `<nav>`, `<main>`, `<aside>` and `<footer>` so assistive technologies can navigate by region. Use at most one `banner`, `main` and `contentinfo` landmark per page.
- Wrap search and filtering controls in `<search>`; it replaces `role="search"`.
- Use `<button>` for actions (scripts, modals, forms) and `<a>` only for navigating to a URL. Give non-submit buttons inside forms `type="button"` so they do not submit the form.
- Use `<ul>`, `<ol>` and `<dl>` for list content.
- Give every interactive element, such as links and buttons, an accessible name, and a role that matches what it does, whether implicit or set with the `role` attribute: controls that act on the same page or view have the `button` role, and controls that take people elsewhere have the `link` role.
- Hide purely decorative SVGs from assistive technology with `aria-hidden="true"`. Give decorative `<img>` elements an empty `alt=""`.
- Give informative SVGs (logos, data visualizations, icon buttons) an accessible name, and give complex visuals a text alternative that conveys the same information as the visual.
- Use semantic elements instead of generic `<div>` or `<span>` wherever they exist, for example for interactive elements, headings, and independently reusable self-contained content.
- Prefer native elements with built-in semantics and behavior over generic elements with ARIA roles or states added, and change an element's native semantics with ARIA only when it is a critical requirement.
- Write boolean attributes without a value: `disabled`, not `disabled="disabled"`.
- Never put `role="presentation"` or `aria-hidden="true"` on focusable elements or on their parents or ancestors.
- Do not disable page zoom.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard | Platform</title>
</head>
<body>
  <header>
    <nav>
      <ul>
        <li><a href="#">About</a></li>
        <li><a href="#">Contact</a></li>
      </ul>
    </nav>
  </header>
  <main>
    <h1>Analytics</h1>
    <search>
      <form action="/filter" method="GET">
        <label for="search-input">Scan items:</label>
        <input type="search" id="search-input" name="q">
        <button type="submit">Search</button>
      </form>
    </search>
    <article>
      <h2>First post</h2>
    </article>
  </main>
  <footer>
    Platform - Policies and legal information
  </footer>
</body>
</html>
```

## 2. Content grouping and attribution

- Use `<blockquote>` for extended quotations from another source, with a `cite` attribute holding a machine-readable URL for the source. Do not use it just to indent non-quoted text.
- Use `<figure>` for self-contained content (images, code snippets, quotes) that is referenced from the main flow but could move to an appendix or sidebar without changing the document's meaning. Do not wrap every image in one; use it only when a caption is needed or the content is a distinct, referenced unit.
- Put `<figcaption>` as the first or last child of `<figure>` for a human-readable caption or attribution.
- Inside a caption or attribution, use `<cite>` for the title of a work (a book or website name), not for the author's name.
- Use `<code>` for short fragments of code such as variable names, file paths or inline snippets.
- For code blocks, wrap `<code>` in `<pre>`. `<pre>` alone preserves whitespace and line breaks but does not convey that the content is code.
- If a code block can scroll, add `tabindex="0"` to the `<pre>` so keyboard users can reach it, plus `role="region"` and an accessible name through `aria-labelledby` (pointing at the `id` of the element that titles the block) or `aria-label`.

```html
<!-- Quote with attribution -->
<figure>
  <blockquote cite="https://html.spec.whatwg.org/">
    <p>The figure element represents some flow content, optionally with a caption, that is self-contained and is typically referenced as a single unit from the main flow of the document.</p>
  </blockquote>
  <figcaption>
    Definition of the &lt;figure&gt; element from the <cite>HTML Living Standard</cite>
  </figcaption>
</figure>

<!-- Image with caption -->
<figure>
  <img
    src="architecture-diagram.webp"
    alt="Diagram showing the flow between Client, API Gateway, and Microservices"
    width="800"
    height="450"
    loading="lazy"
  >
  <figcaption>Figure 1: High-level system architecture overview.</figcaption>
</figure>

<!-- Scrollable code block with accessible name and language hint -->
<figure>
  <figcaption id="code-block-caption">Example configuration:</figcaption>
  <pre role="region" aria-labelledby="code-block-caption" tabindex="0"><code class="language-json">
{
  "name": "example-app",
  "version": "1.0.0",
  "private": true
}
  </code></pre>
</figure>

<!-- Inline code -->
<p>To initialize the project, run the <code>npm install</code> command.</p>
```

## 3. Resource prioritization and performance

- Put `fetchpriority="high"` on the Largest Contentful Paint (LCP) element, such as the hero image, to raise its network priority.
- For an LCP background image defined in CSS, add `<link rel="preload" as="image" fetchpriority="high">`.
- Use `fetchpriority="high"` sparingly: prioritization is zero-sum. Use `fetchpriority="low"` to demote non-critical resources such as trackers or later carousel items.
- Add `loading="lazy"` to off-screen images and iframes to defer their download, but never to above-the-fold or hero images, because it delays LCP.
- Set `width` and `height` on every `<img>` to reserve its aspect ratio and prevent layout shifts (CLS).
- Use `srcset` on `<img>` to offer the same image at several sizes.
- Use `<picture>` with a fallback `<img>` for finer control: switching formats, switching sizes, or cropping differently per device size (art direction).

```html
<!-- High-priority hero image with responsive sizes -->
<img
  src="hero-large.webp"
  srcset="hero-small.webp 480w, hero-medium.webp 800w, hero-large.webp 1200w"
  sizes="(max-width: 600px) 100vw, (max-width: 1200px) 80vw, 70vw"
  alt="Main product view"
  fetchpriority="high"
  width="1200"
  height="600"
>

<!-- Art direction and format switching with <picture> -->
<picture>
  <!-- Mobile: square crop, AVIF with WebP fallback -->
  <source
    media="(max-width: 600px)"
    srcset="hero-mobile.avif 1x, hero-mobile-2x.avif 2x"
    type="image/avif"
    width="600"
    height="600"
  >
  <source
    media="(max-width: 600px)"
    srcset="hero-mobile.webp 1x, hero-mobile-2x.webp 2x"
    width="600"
    height="600"
  >

  <!-- Desktop: modern format -->
  <source srcset="hero-desktop.avif" type="image/avif">

  <!-- The fallback img sets the default aspect ratio (2:1) -->
  <img
    src="hero-desktop.webp"
    alt="Platform dashboard overview"
    width="1200"
    height="600"
  >
</picture>

<!-- Low-priority decorative footer image -->
<img
  src="footer-art.png"
  alt=""
  loading="lazy"
  width="200"
  height="100"
>
```

## 4. Native overlays: dialogs and popovers

For fallback strategies when using the Popover API across browsers, see the `declarative-dialog-popover-control` guide.

- Use `<dialog>` opened from script with `.showModal()` for modal overlays. It traps focus, dims the background and closes on `Esc` without extra code. Add `closedby="any"` for native light dismiss (closing on a backdrop click) without custom JavaScript. Safari does not support `closedby` yet, so treat light dismiss as progressive enhancement; the `light-dismiss-a-dialog` guide has a script fallback.
- Use `showModal()`, not `show()`, wherever a modal focus trap is expected.
- Give every modal a visible close control, so people using voice control software can see how to dismiss it.
- Style the modal background with `::backdrop`.
- Close dialogs with `<form method="dialog">` instead of manual handlers. Submitting with a button, or a button with `formmethod="dialog"`, closes the dialog and sets its `returnValue` to the button's `value`.
- Use the Popover API (the `popover` attribute) for non-modal UI that needs no focus trap, such as menus and tooltips.
- Do not call `showModal()` on an element with a `popover` attribute; the two are mutually exclusive programmatic states. `<dialog popover="auto">` is valid, though, and is the declarative way to combine dialog semantics with light dismiss.

```html
<!-- Popover, toggled without JS -->
<button popovertarget="help-menu">Info</button>
<div id="help-menu" popover="auto">
  <p>Standard help text.</p>
</div>

<!-- Modal dialog closed by a form -->
<button id="show-dialog">Open dialog</button>
<dialog id="fav-modal">
  <!-- method="dialog" closes the dialog and sets returnValue -->
  <form method="dialog">
    <p>Confirm action?</p>
    <button value="cancel">Cancel</button>
    <button value="confirm">Confirm</button>
  </form>
</dialog>

<script>
  const dialog = document.getElementById("fav-modal");
  const openModal = document.getElementById("show-dialog");

  openModal.addEventListener('click', () => dialog.showModal());

  dialog.addEventListener('close', () => {
    console.log(dialog.returnValue); // "confirm" or "cancel"
  });
</script>
```

### Overlay and disclosure matrix

| Feature | Modality | Focus | Dismiss mechanism | Use case |
| :--- | :--- | :--- | :--- | :--- |
| `<dialog>` | Modal or non-modal | Trapped (modal) | Esc, form, `closedby` | Critical actions, settings |
| `[popover]` | Non-modal | Normal tab flow | Light dismiss (click outside) | Menus, tooltips, toasts |
| `<details>` | Inline disclosure | Normal tab flow | Toggling the summary | Accordions, FAQs |

Use `<dialog>` for interruptions that need a user action, `popover` for transient information, and `<details>` for expanding content inline.

## 5. Disclosures: details and summary

- Use `<details>` and `<summary>` for native disclosures and accordions without JavaScript. Make an accordion exclusive by giving its `<details>` elements the same `name` attribute, and wrap the whole accordion in a `<section>` named with `aria-labelledby` (pointing at the `id` of the element that names it) or `aria-label`.
- Make `<summary>` the first child of `<details>`.
- If you want a heading inside a `<summary>`, consider whether the heading is essential for understanding or navigating the document structure. If it is, use a disclosure pattern where the heading wraps the trigger, such as `<h2><button type="button" aria-expanded="false" aria-controls="significant-section-content">Significant section</button></h2>`, so the heading semantics survive and the button and its state are announced.
- Style the expanded state with `details[open]`, and the contents with `details::details-content`.
- Do not put other interactive elements (links, buttons) inside `<summary>`; they can break expected focus behavior and screen reader announcements.
- If you hide the disclosure triangle with `list-style: none`, provide another directional cue with a `::before` or `::after` pseudo-element.
- Mark custom state indicator icons (`<img>` or `<svg>`) as decorative (`alt=""` or `aria-hidden="true"`) rather than giving them a text alternative. The `<summary>` already communicates the state, and a text alternative would duplicate it.
- Do not use the `title` attribute for tooltips; keyboard users cannot reach it. Use an accessible tooltip pattern that keyboard users can trigger and screen readers announce consistently.

```html
<!-- Exclusive accordion -->
<section aria-label="Frequently asked questions">
  <details name="faq">
    <summary>Item 1</summary>
    <p>Contents...</p>
  </details>
  <details name="faq">
    <summary>Item 2</summary>
    <p>Contents...</p>
  </details>
</section>
```

## 6. Focus boundaries and visibility

- Put the global `inert` attribute on whole sections that are hidden or inactive (off-screen menus, the background while a custom modal is open) to remove them from the tab order and the accessibility tree. Pair `[inert]` with a visual cue such as `opacity: 0.5`.
- Rely on DOM order for sequential navigation. Do not reorder visually with CSS (`flex-flow: row-reverse`, `order`) unless the DOM order matches.
- Never use positive `tabindex` values (`1`, `2`). Use `0` to add an element to the tab order and `-1` to make it focusable only from script.
- Make sure a focused element is never obscured. For example, move focus into a modal dialog and keep it there, rather than letting focus reach the obscured content behind it.
- When the focused element is hidden or removed, move focus to a logical neighbour or back to the control that triggered it.
- When content is added in direct response to a user action that moves the workflow into it (opening a dialog, navigating to a new view), move focus to the start of that content. Do not do this for background or live-region updates.
- Use `node.focus({ preventScroll: true })` only after checking usability, because it can leave the focused element off-screen.

```html
<!-- Background app shell made inert while a custom drawer is open -->
<main id="app-shell" inert>
  <a href="/">Dashboard</a>
</main>
<aside id="drawer">
  <button>Close</button>
</aside>
```

```css
/* On [inert] only: opacity on descendants too would compound. */
[inert] {
  opacity: 0.5;
  cursor: default;
  user-select: none;
}
```

## 7. Form helpers and autocomplete

For more on building modern web forms, see the `forms` guide.

- Use the `form="form-id"` attribute to associate a control with a `<form>` it is not nested in.
- Use `<datalist>` with `<input list="id">` for lightweight suggestions. Its popup cannot be styled and it has screen reader quirks.
- Put an `autocomplete` token on fields that ask for personal information: `name` for a combined name field, `given-name` and `family-name` for separate ones.
- Use `autocomplete="current-password"` for sign-in and `autocomplete="new-password"` for registration and password changes, so password managers offer the right action.
- Match `autocomplete` with the corresponding `type` and `inputmode`, for example `type="email"`, `inputmode="email"` and `autocomplete="email"`. They control validation, the on-screen keyboard and autofill respectively, and reinforce each other.
- Do not use `autocomplete="off"` on credential, address, payment or contact fields; browsers and password managers ignore it there by design. Use a specific token such as `email`, `street-address` or `cc-number`, with standard input types such as `type="email"` and `type="tel"`. Reserve `autocomplete="off"` for highly sensitive tracking tokens, since it works against password managers.

```html
<form>
  <fieldset>
    <legend>Address Information</legend>
    <label for="city">City:</label>
    <input type="text" id="city" list="cities" autocomplete="address-level2">
    <datalist id="cities">
      <option value="New York">
      <option value="London">
    </datalist>
  </fieldset>
</form>
```

## 8. Native media elements

- Set `width` and `height` on `<video>` to prevent layout shifts (CLS).
- Provide a `poster` image.
- Provide captions and subtitles with `<track>`.
- Prefer the native `controls` attribute over JavaScript controls when it covers what you need.
- Background videos must be `muted` and use `role="none"` or `aria-hidden="true"`. Omit the `controls` attribute so the video is not focusable, and give users full control over playback with a separate, focusable play/pause button outside the video.
- Never put `role="none"` or `aria-hidden="true"` on focusable elements, such as an embedded interactive `<iframe>`: hiding something from assistive technology while it stays in the keyboard tab order breaks accessibility. The background video is an exception only because omitting `controls` makes `<video>` non-focusable.
- Do not autoplay audio when a page opens unless there is an accessible pause or stop control, or a volume control independent of the operating system's volume (WCAG 1.4.2 Audio Control, Level A).

```html
<video
  controls
  width="800"
  height="450"
  poster="poster.webp"
>
  <source src="intro.webm" type="video/webm">
  <source src="intro.mp4" type="video/mp4">
  <track src="caps.vtt" kind="captions" srclang="en" label="English">
</video>
```

## 9. Dynamic styles and interactivity

- Use the `style` attribute only to pass state to CSS through custom properties, so the visual logic stays in the stylesheet and JavaScript supplies just the data. Keep static design (colors, padding, margins) in the stylesheet, not inline.
- Attach behavior with `addEventListener()`, not inline handlers such as `onclick`.
- Make information available to screen reader users through text alternatives, accessible names, roles and programmatic state.
- Do not convey state, interaction or information through color alone.

```html
<body>
  <label for="upload-progress">Upload status:</label>
  <progress id="upload-progress" class="loading-bar" value="0" max="100" style="--brand-hue: 200;"></progress>

  <script>
    const updateProgress = (percent, hue) => {
      const bar = document.querySelector('.loading-bar');
      bar.value = percent;
      if (hue) bar.style.setProperty('--brand-hue', hue);
    };

    // Move to 85% and shift the color to green (hue 120).
    setTimeout(() => updateProgress(85, 120), 1000);
  </script>
</body>
```

```css
.loading-bar {
  accent-color: hsl(var(--brand-hue, 200) 80% 50%);
  transition: accent-color 0.3s ease;
}
```
