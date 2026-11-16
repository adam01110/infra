# Accessibility coding guidelines

Rules for building web pages that work for everyone, including people who use assistive technologies. Two principles apply throughout:

- Conformance to standards is the floor, not the goal; aim for real usability.
- Patterns depend on the use case. No checklist replaces real testing, including testing with disabled users, to confirm an implementation is accessible in context.

Each rule names the WCAG 2.2 success criterion and level it supports, or "best practice" when it goes beyond WCAG.

## 1. Content navigability and structure

### Landmarks

- Put all content inside landmarks, `<header>`, `<nav>`, `<main>`, `<aside>` and `<footer>`, so assistive technology users can jump between regions. (1.3.6 Identify Purpose, AAA)
- Use each landmark for its purpose (1.3.1 Info and Relationships, A):
  - `<header>`: introductory content.
  - `<nav>`: site-wide or in-page navigation links.
  - `<main>`: the main content of the page.
  - `<aside>`: content tangentially related to the main content.
  - `<footer>`: information about the related content, such as author, copyright and links to related documents.
- Use one `<main>` per page. (1.3.1, A)
- When a page has several `<nav>` elements, give each a distinguishable name with `aria-label`, such as `<nav aria-label="Primary">` and `<nav aria-label="Secondary">`. (Best practice)
- Do not overuse landmarks; too many dilute their value. In particular, avoid labelling a `<section>`, which turns it into a `region` landmark. Use `region` only as a last resort when no other landmark fits. (Best practice)

### Headings

- Structure the main content with `<h1>` to `<h6>` in sequence, so screen reader users get a navigable outline. (1.3.1, A)
- Never style a `<div>` or `<span>` to look like a heading instead of using a real heading element. (1.3.1, A)
- Match heading levels to visual importance: a sub-heading that is visually less important than its parent gets a lower level. (1.3.1, A)
- Use one `<h1>` per page, for its main heading. With several, screen reader users struggle to identify the real main heading. (Best practice)
  - A modal dialog marked up with `<dialog>`, `role="dialog"` or `role="alertdialog"` may have its own `<h1>`, because the dialog is a separate window from the page.
- Do not skip levels (for example `<h1>` straight to `<h4>`); it breaks the logical hierarchy. (Best practice)
- Do not put headings inside `<summary>`. Some browsers still expose `<summary>` as a button, which strips the roles of its children, including headings. If a heading must trigger a disclosure, build an ARIA accordion or disclosure in which the heading element wraps the button, instead of `<details>` and `<summary>`. (Best practice)

### Lists

- Use lists for repeated, contiguous content. `<ul>` and `<ol>` tell assistive technology the item count up front and let users skip the whole list. (1.3.1, A)
- Use `<ul>` when item order does not matter (a list of related products) and `<ol>` when it does (a list of instructions). (1.3.1, A)
- Do not mark up separate paragraphs as a list; screen readers announce list information, which is confusing and redundant there. (1.3.1, A)
- Do not wrap checkboxes or radio buttons in a list. Correctly marked-up groups already announce the number of options and the position of the focused one, so list markup duplicates it. (1.3.1, A)

### Tables

- Use the table elements: `<table>` for the table, `<caption>` for its title and accessible name, `<tr>` for rows, `<th>` for header cells and `<td>` for data cells. (1.3.1, A)
- Use the `scope` attribute on `<th>` elements: `scope="row"` for row headers, `scope="col"` for column headers. (1.3.1, A)
- Never use tables for layout. Screen readers announce redundant table information, and table markup affects reading and focus order. Use CSS grid or flexbox for layout. (1.3.1, A)
- Avoid overly complex tables. Spanned rows or columns, nested tables and expandable rows can make visual sense and still pass WCAG, but they are disorienting to navigate with a screen reader. Split them into smaller tables. (Best practice)

### Skip links

- Provide a skip link before repeated content, such as a site header with navigation or a long or infinite list, so keyboard users can bypass it. (2.4.1 Bypass Blocks, A)
  - Screen magnifiers sometimes do not follow focus when the skip link's target is not normally focusable. The usual workaround is `tabindex="-1"` on the target, which makes it programmatically focusable without adding it to the tab order.
  - If that target contains focusable elements, clicking inside it then always sets the sequential focus navigation starting point to the target rather than between focusable elements. To satisfy both needs, target the first meaningful element inside the section with `tabindex="-1"`, such as its heading (`<h1 id="content" tabindex="-1">`).
  - Any content before that element is skipped, including other relevant content in the section, which leaves gaps for other assistive technology users.
- Leave skip links out where they are not needed: pages whose only common element is a single link to the home page do not need one. (Best practice)
- One skip link, or two for primary and secondary navigation, is usually enough. Extra skip links add Tab stops, which frustrates keyboard-only users. (Best practice)

```html
<a href="#content" class="skip-link">Skip to main content</a>
<main id="content">...</main>
```

Landmarks, heading hierarchy, a list, a table and a skip link together:

```html
<header>
  <a href="#platform-dashboard" class="skip-link visually-hidden">Skip to content</a>
  <nav aria-label="Primary">
    <ul>
      <li><a href="/">Home</a></li>
    </ul>
  </nav>
</header>
<main>
  <h1 id="platform-dashboard" tabindex="-1">Platform Dashboard</h1>
  <section>
    <h2>User Statistics</h2>
    <table>
      <caption>Monthly active users</caption>
      <thead>
        <tr>
          <th scope="col">Month</th>
          <th scope="col">Users</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>January</td>
          <td>12,000</td>
        </tr>
      </tbody>
    </table>
    <h3>Notes</h3>
    <ul>
      <li>Results do not include users without active subscriptions</li>
      <li>Results are accurate as of 31 December 2025</li>
    </ul>
  </section>
</main>
```

## 2. Semantic HTML and ARIA

### Prefer native HTML

- Prefer HTML elements and attributes to ARIA: use `<button>`, not `<div role="button">` or `<a role="button">`. Native elements already have the right role and behaviour, including keyboard support, with no extra JavaScript; `<button>` implies `role="button"` and `required` implies `aria-required`. (Best practice)
  - Use ARIA when HTML has no equivalent. For example, HTML has no tab widget elements, but ARIA has the roles and states for one.
- Do not add redundant roles or properties such as `<ul role="list">`, `<nav role="navigation">` or `<input required aria-required="true">`. (Best practice)
  - Exception: Safari removes list semantics from `<ul>` and `<ol>` outside `<nav>` when `list-style: none` or `display: flex` or `grid` is applied. Add `role="list"` there to restore them.
- Do not put interactive roles on structural elements, which breaks the container's semantics. Write `<li><span role="button">Button in a list</span></li>`, not `<li role="button">Button in a list</li>`. (4.1.2 Name, Role, Value, A)
  - Roles with similar semantics are fine on structural elements, such as a tree view: `<ul role="tree"><li role="treeitem">…</li>…</ul>`.

### ARIA roles and states

- Make behaviour match the role. An element with `role="tab"` must behave like a tab, including its keyboard interactions. Many ARIA patterns need JavaScript and cannot be built in CSS alone. (4.1.2, A)
- Communicate toggle states of custom controls with `aria-expanded` and `aria-pressed`. (4.1.2, A)
- Choose between `disabled` and `aria-disabled` deliberately. `disabled` removes the element from the focus order entirely, and `tabindex="0"` will not bring it back, which is often wrong for toolbar buttons or links. `aria-disabled="true"` keeps it focusable so users can find it and learn it is disabled, but it only informs assistive technology, so you must also block activation (pointer clicks and keyboard triggers) in JavaScript. (4.1.2, A)
- Never put `aria-hidden="true"` on a focusable interactive element or on any of its ancestors. (4.1.2, A)
- Never put `role="presentation"` or `role="none"` on an interactive element. Screen readers still reach and announce the element, but without its role or state, which confuses users and can behave unexpectedly. (4.1.2, A)
- Do not assume a custom element has no ARIA. Custom elements can set ARIA through `ElementInternals`, which some automated test tools cannot see, so missing `role` or `aria-*` attributes in the markup prove nothing. Check the browser's accessibility tree inspector. (Best practice)

## 3. Accessible names and descriptions

Every interactive element and some landmarks need an accessible name, and many benefit from an accessible description. A name is short and identifies the element; a description adds context.

### Naming mechanisms

- Prefer native naming: `<label>` for form controls, `<caption>` for `<table>`, `<legend>` for `<fieldset>`, `<figcaption>` for `<figure>`. (Best practice)
- Associate each `<label>` with its control explicitly through `for` and `id`. Besides naming the control, this lets users click the label or the control to focus it, a larger target that other labelling methods such as `aria-labelledby` do not reliably give. Some assistive technologies, especially voice recognition software, also require the explicit `for`/`id` relationship even where an equivalent supported approach, such as nesting the `<input>` inside the `<label>`, is used. (4.1.2, A)
- When a visible label exists, prefer `aria-labelledby` to `aria-label`. It avoids duplication, is easier to maintain and translates better. (Best practice)
- Do not name elements with `title`. It shows only on mouse hover and no browser makes it available by keyboard. (Best practice)
  - Exception: `title` is the standard way to name an `<iframe>`.
- Do not name fields with `placeholder`. It disappears once the user types, removing the cue for what the field is, and in most browsers its contrast against the background is very low. (3.3.2 Labels or Instructions, A)
- Do not put `aria-label` or `aria-labelledby` on elements that should not be named, such as a plain `<div>`, `<span>` or a custom element without a role. These attributes are for elements with an explicit or implicit widget role (button, link, tab and so on), landmark, image or iframe role. (1.3.1, A)
  - A custom element may have an implicit role set through `ElementInternals`, so a missing `role` attribute is not conclusive.

### Choosing the name

- Give links to the same page the same accessible name, normally their visible text. If links to `profile.html` say "My Profile" in one place, do not call them "Profile" in another. (Best practice)
- Give controls that look identical but do different things distinguishing names. A page with several "Edit" buttons (edit name, edit password, edit address) may be clear visually, but a screen reader user may hear only "Edit, button". Techniques (4.1.2, A):
  - Visually hidden text: `<button>Edit <span class="visually-hidden">first name</span></button>`, using the visually hidden utility at the end of this section.
  - `aria-label` containing the visible text plus the context: `<button aria-label="Edit name">Edit</button>`, `<button aria-label="Edit address">Edit</button>`.
  - `aria-labelledby` or `aria-describedby` pointing at the related content. Chaining IDs in `aria-labelledby` appends the related text to the name: `<p id="firstName">First name</p> <button id="editFirstName" aria-labelledby="editFirstName firstName">Edit</button>`. `aria-describedby` gives the context as a description instead: `<p id="firstName">First name</p> <button aria-describedby="firstName">Edit</button>`.
- Include a control's visible text, exactly as written, in its accessible name. Extra words may come before or after it, but the visible text itself must be intact. A "Read more" link may be named "Read more about [subject]", but not "Read some more about [subject]", because "some" splits the visible phrase. (2.5.3 Label in Name, A)
- Do not reuse a name for controls with different effects in the same view. (4.1.2, A)
  - Two "Close" buttons in two separate dialogs are fine, because only one dialog is reachable at a time. Several "Edit" buttons with different effects in one dialog are not.
- Do not reuse a name for links to different `href` targets. Instead of two links called "Annual Report" pointing at `annualreport2025.html` and `annualreport2026.html`, name them "Annual Report 2025" and "Annual Report 2026", or use another disambiguation technique.
- Keep descriptions, error messages and instructions out of the label; verbose labels frustrate screen reader users. Associate the extra content with `aria-describedby` instead, so the screen reader announces the label, then the control type, then the extra text, which users who know it can skip: `<label for="yourComments">Your comments</label><p id="yourCommentsWarning">Please do not include any personal information in this field.</p><textarea id="yourComments" aria-describedby="yourCommentsWarning"></textarea>`. (Best practice)
- Do not repeat in the label any state already exposed through `aria-expanded`, `aria-checked`, `aria-selected`, `aria-pressed` or similar attributes; it is redundant and ambiguous. (Best practice)
- Do not include the role in the label: `<nav aria-label="Primary navigation">` is read as "Primary navigation, navigation". (Best practice)

### Descriptions

- Expose instructions, error messages and other important information about a control as its description, for example (1.3.1, A):
  - the password requirements when creating an account;
  - an error message for a field in a previously submitted form;
  - an instruction such as "You must agree to the terms and conditions before you can submit the form".
- Make the description available when the element receives focus (1.3.1, A):
  - if it is visible on the page, associate it with `aria-describedby`;
  - if it is not visible and is meant only for screen reader users (because a visible description would not be appropriate or useful), set it with `aria-description`.
- Do not describe every element. If the label is enough ("First name"), a description is likely redundant. (Best practice)
  - Exceptions: inline error messages tied to controls (above or below a text field) and secondary labels that should be announced on focus.
- Do not repeat in a description what the element's attributes already say. "This is a required field" on an `<input required>` is announced twice. (Best practice)
  - Exception: `aria-invalid="true"` makes many screen readers say "invalid" but not what the error is, so the field also needs the human-readable error as its description. Set `aria-invalid="true"` only while the error message is present.
- Avoid interactive elements inside an `aria-describedby` target unless the whole text reads sensibly as a description (best practice):
  - Acceptable, because the full sentence makes sense: `<p id="description">I understand the <a href="tandc.html">terms and conditions</a>.</p>`
  - Not acceptable, because "Learn more" is announced out of context ("Please don't include personal information in this field. Learn more."): `<p id="description">Please don't include personal information in this field. <a href="…">Learn more</a></p>`. Reference only the plain text instead: `<p><span id="description">Please don't include personal information in this field.</span> <a href="…">Learn more</a></p>`.

### Visually hidden utility

A `.visually-hidden` utility gives screen readers text that is not rendered visually. Typical uses are skip links, extra context on icon-only buttons and supplementary labels.

```css
/* Hidden visually but kept in the accessibility tree. The :focus-within and
   :active exceptions let focusable content, such as skip links, become visible. */
.visually-hidden:where(:not(:focus-within, :active)) {
  position: absolute !important;
  clip-path: inset(50%) !important;
  overflow: hidden !important;
  width: 1px !important;
  height: 1px !important;
  margin: -1px !important;
  padding: 0 !important;
  border: 0 !important;
  white-space: nowrap !important;
}
```

Style the visible state of focusable hidden content for each situation. A skip link to the main content, for example, usually gets fixed positioning at the top left of the viewport so the rest of the page does not shift.

## 4. Document metadata and language

### Language

- Set `lang` on `<html>` to the primary human language of the content, such as `<html lang="en">`. (3.1.1 Language of Page, A)
- Mark language changes by setting `lang` on the element containing the affected content, with that language's code: `<p>In Germany, you may be greeted by someone saying <span lang="de">Guten Morgen</span>.</p>`. (3.1.2 Language of Parts, AA)
- Never set `lang` to a value that does not match the content's language; screen readers and other text-to-speech software then pronounce it unintelligibly. (3.1.1, A; 3.1.2, AA)

### Titles

- Give every page a `<title>` in its `<head>`, including pages embedded in an `<iframe>`. (2.4.2 Page Titled, A)
- Make each title unique and unambiguous about the page's purpose or content. Pages with identical or vague titles cannot be told apart without reading them. (2.4.2, A)
- Put the unique part first: `<title>Page Topic | Site Name</title>`. (Best practice)
- In single-page applications, update the title on each view change. A contact form titled `Contact Us` becomes `Thank you for contacting us!` after a successful submit. (2.4.2, A)
- Never leave the title empty (`<title></title>`), however minor the page. Titles distinguish pages in browser tabs and are usually announced by screen readers when a page opens. (2.4.2, A)

### Iframes

- Give every `<iframe>` a `title` that unambiguously describes its content. (4.1.2, A)
- Do not disable iframe scrolling with `scrolling="no"` (deprecated) or `overflow: hidden`. Users who zoom or enlarge text need to scroll to reach overflowing content. (1.4.4 Resize Text, AA; 1.4.10 Reflow, AA)

```html
<html lang="en">
<head>
  <title>Analytics Reports | Guidance Platform</title>
</head>
<body>
  <p>The motto is <span lang="la">"Carpe diem"</span>.</p>
  <iframe title="Interactive Sales Chart" src="/chart"></iframe>
</body>
</html>
```

## 5. Keyboard and focus management

### Tab order and focusability

- Keep the focus order logical. (2.4.3 Focus Order, A)
  - In left-to-right languages that means top to bottom, left to right; in right-to-left languages, top to bottom, right to left.
- Use `tabindex="0"` only on elements that have an interactive role but are not focusable by default, such as `<span role="button" tabindex="0">Print</span>`. (2.4.3, A)
- Manage focus to and from updated content. When a dialog appears, move focus into it immediately, keep focus inside it, and on dismissal return focus to the element that opened it. (2.4.3, A)
- Do not add `tabindex="0"` to elements already focusable, such as `<button>`, `<input>` and `<a>` with `href`. (2.4.3, A)
- Do not make static, non-interactive or hidden (temporarily or permanently) elements focusable. Only elements that perform an action when activated belong in the tab order. (2.4.3, A)
- Never use positive `tabindex` values (`tabindex="1"` or higher). They impose a tab order unrelated to the intended or expected one. (2.4.3, A)

### Keyboard handlers

- When a native `<button>` cannot be used, custom button-like elements need keyboard handlers that match it: Enter on `keydown` (it repeats while held) and Space on `keyup` (it fires on release). (2.1.1 Keyboard, A)
- Do not add Enter or Space handlers to native interactive elements. `<button>`, `<input>` and `<a href>` already respond to Enter, and all but `<a>` to Space. (Best practice)
  - An `<a>` repurposed with `role="button"` still needs a `keyup` handler for Space to match `<button>`.

This pattern is only for custom widgets with no native HTML equivalent, such as tree items or tabs, and the element must have the matching ARIA role (for example `role="treeitem"` or `role="tab"`). Use native `<button>` or `<input>` for standard interactions.

```javascript
customWidget.addEventListener('keydown', (e) => {
  if (e.key === 'Enter') {
    toggleWidgetState();
  }
  if (e.key === ' ') {
    e.preventDefault(); // Stop Space from scrolling the page.
  }
});

customWidget.addEventListener('keyup', (e) => {
  if (e.key === ' ') {
    toggleWidgetState();
  }
});

function toggleWidgetState() {
  const isExpanded = customWidget.getAttribute('aria-expanded') === 'true';
  customWidget.setAttribute('aria-expanded', !isExpanded);
}
```

### Focus indicators

- Style custom focus indicators on `:focus-visible`, not `:focus`. (Best practice)
- Prefer the browser's native focus indicator; customise it only to meet contrast or design requirements. (Best practice)
- If you remove the native indicator with `outline: none`, always provide a custom one with a contrast ratio of at least 3:1 against adjacent content. (2.4.7 Focus Visible, AA; 1.4.11 Non-text Contrast, AA)
- Prefer `outline` for focus rings. If a ring must use `box-shadow`, add an `outline` fallback for high contrast mode inside a `forced-colors` media query. (Best practice)
- Pair custom outlines with `outline-offset` to separate the ring from the element. (Best practice)

```css
:where(a:any-link, button):focus-visible {
  outline: 3px solid #ff0055;
  outline-offset: 3px;
}
```

### Target sizes

- Give interactive elements a target of at least 24×24 CSS pixels. Enforce it with `min-block-size` and `min-inline-size` or with padding rather than `width` and `height`, so content can grow the target but not shrink it. (2.5.8 Target Size (Minimum), AA)
  - A smaller target passes if a 24 CSS pixel diameter circle centred on its bounding box does not intersect another target, or the circle of another undersized target.
- Enlarge targets on coarse pointers with `@media (pointer: coarse) { … }`. (2.5.8, AA)
- Do not use `touch-action: none` for custom gestures; it disables page scrolling through the element. Restrict to the axis you need: `pan-y` for horizontal swipes (the page still scrolls vertically), `pan-x` for vertical swipes. Keep `none` for elements where no native touch behaviour makes sense, such as a drawing canvas. (2.1.1, A)

## 6. Alternative text and media

### Images

- Give every `<img>` an `alt` attribute; screen readers present its value in place of the image. (1.1.1 Non-text Content, A)
- Describe the image's purpose, not its appearance: "Search", not "Magnifying glass". (1.1.1, A)
- Give decorative images `alt=""` so screen readers skip them. (1.1.1, A)
- Do not start alt text with "Image of…" or "Picture of…". (Best practice)
- Use dashes rather than underscores in image file names, in case the file name is announced as a fallback. (Best practice)

```html
<!-- Decorative -->
<img src="divider.png" alt="">

<!-- Functional -->
<a href="/search">
  <img src="glass.png" alt="Search the platform">
</a>
```

### Inline SVGs

- Put `role="img"` on non-decorative `<svg>` elements so every browser exposes them as images. (4.1.2, A)
- Give non-decorative SVGs a text alternative, either a child `<title>` element or `aria-label` on the `<svg>`. (1.1.1, A)
- Hide decorative SVGs with `aria-hidden="true"`. (1.1.1, A)

```html
<!-- Non-decorative, named with <title> -->
<svg role="img" viewBox="0 0 24 24">
  <title>Home</title>
  <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
</svg>

<!-- Non-decorative, named with aria-label -->
<svg role="img" viewBox="0 0 24 24" aria-label="Home">
  <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
</svg>

<!-- Decorative -->
<svg aria-hidden="true" viewBox="0 0 24 24">
  <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
</svg>
```

### Complex images and charts

- Give charts and infographics a long description with `<figure>` and `<figcaption>` or with `aria-describedby`. (1.1.1, A)
- Provide semantic data tables as alternatives to charts and other complex visualisations. (1.1.1, A)

```html
<figure>
  <img src="chart.png" alt="Sales growth graph 2024.">
  <figcaption>Sales grew 20% in Q3 due to new platform launch.</figcaption>
</figure>
```

### Audio and video

- Provide a verbatim transcript for audio-only content and for video with audio, including all dialogue and descriptions of important non-speech sounds such as sound effects. (1.2.1 Audio-only and Video-only (Prerecorded), A; 1.2.3 Audio Description or Media Alternative (Prerecorded), A)
- Provide a text description or an audio track for video-only content, such as text instructions accompanying a product animation, or a separate audio track describing the action. (1.2.1, A)
- Provide synchronised WebVTT captions for the audio in videos. They should be verbatim and include all dialogue and meaningful non-speech content, such as sound effects and other information carried by the soundtrack ("Ominous music plays"). (1.2.2 Captions (Prerecorded), A)
  - Captions are not required when the video is a decorative alternative to text already on the page and is clearly identified as such.
- Provide audio description for videos: an additional audio track, placed in natural pauses in the dialogue, that conveys visual information the main audio does not. (1.2.3 Audio Description or Media Alternative (Prerecorded), A; 1.2.5 Audio Description (Prerecorded), AA)

```html
<video controls>
  <source src="intro.mp4" type="video/mp4">
  <track src="caps.vtt" kind="captions" srclang="en" label="English">
</video>

<audio controls src="podcast.mp3" aria-details="podcast-transcript"></audio>
<details id="podcast-transcript">
  <summary>View Transcript</summary>
  <div class="transcript-content">
    Welcome to the show...
  </div>
</details>
```

### CSS generated content

Give CSS generated content alt text with the alternative text argument of `content` (`content: url(icon.svg) / "Save";`), and keep meaningful text in the DOM. The `accessible-generated-content` guide has the details and fallbacks. (1.1.1, A)

### Content visibility

| Intent | Visual | Screen reader | Focusable | Pattern |
| :--- | :--- | :--- | :--- | :--- |
| Visible to all | Yes | Yes | Yes | Normal rendering |
| Screen reader only | No | Yes | Yes, if interactive | Visually hidden utility (`.visually-hidden`) |
| Visual only | Yes | No | No | `aria-hidden="true"` |
| Hidden from all | No | No | No | `hidden` attribute or `display: none` |

Anything that can receive keyboard focus must not have `aria-hidden="true"`. Use screen-reader-only content as a last resort: content that matters should be visible to everyone.

## 7. Forms and input controls

### Labels and hints

- Label every form control. The current selection or value is not a label. (3.3.2 Labels or Instructions, A)
- Connect labels programmatically with `<label for="id">` and `<input id="id">`. (1.3.1, A)
- Do not use placeholders as labels; they are not persistent. Use them only for brief hints, such as an example of valid input. (3.3.2, A)
- Link hints to their inputs with `aria-describedby`, and place the hint above the input so autocomplete popups do not cover it while the user types. (1.3.1, A)

```html
<form>
  <label for="pwd">Password:</label>
  <span id="pwd-hint">Must contain at least 8 characters.</span>
  <input id="pwd" type="password" aria-describedby="pwd-hint" autocomplete="current-password" required>
</form>
```

### Input assistance and validation

- Set `autocomplete` to the correct value (such as `"email"` or `"given-name"`) on every `<input>`, `<textarea>` and `<select>` that collects personal information about the user. (1.3.5 Identify Input Purpose, AA)
- Mark mandatory fields with `required`, or with `aria-required="true"` only where `required` does not apply. (4.1.2, A)
- Do not change context on focus changes alone, such as auto-submitting a form or navigating away. (3.2.1 On Focus, A; 3.2.2 On Input, A)

## 8. Live regions

Live regions let assistive technology announce updates that are not tied to navigation or focus changes. They are easy to misuse: too many regions, or noisy ones, quickly become spam for screen reader users.

| Urgency | Visual analogue | `aria-live` value | Effect | Example |
| :--- | :--- | :--- | :--- | :--- |
| Critical | Modal, alert | `assertive` (or `role="alert"`) | Interrupts immediately and clears the speech queue | Session timeout, API failure |
| Standard | Toast, banner | `polite` | Announced at the next pause | Search results, "Saved" status |
| Passive | Silent text | `off` | Read only if the user navigates to it | Live character count |

Use `assertive` only for critical, time-sensitive updates that need immediate attention or block safe continuation, such as data loss, session timeouts or network drops.

### When to announce

- Announce dynamic errors with `aria-live`, or move focus to an error list. (4.1.3 Status Messages, AA)
- Do not announce interim states such as "Loading…" or "Updating…" unless they carry real information; they are usually noise. Use the HTML `<progress>` element or the ARIA `progressbar` role for them instead. (Best practice)

```html
<div role="alert" class="timeout-warning">
  Your session will expire in 2 minutes.
  <button type="button" onclick="extendSession()">Extend Session</button>
</div>
```

### Managing announcements

- Centralise announcements that have no visible counterpart in one `polite` and one `assertive` region per page, with whatever `aria-atomic` setting you need. This keeps announcements consistent and maintainable. If your framework ships its own announcer, use it. (Best practice)
- Debounce regions that can update many times a second, such as a combobox's result count while the user types. (Best practice)
- Add a short delay before announcing while the user is typing or focus is being moved, so the announcement does not overlap other speech. (Best practice)
- Do not update live regions inside inert content. When a dialog opens or a section becomes `inert`, queued or debounced messages go unannounced, or are announced from content the user cannot reach. Coordinate live region updates with dialog and inert state changes. (4.1.3, AA)

## 9. Color

The `color` guide covers accessible color: contrast requirements, light and dark color schemes, forced colors mode and more.

## 10. Typography

The `typography` guide covers readable typography.

## 11. Motion and preferences

The `motion` guide covers motion and user motion preferences.

## 12. Modals and native dialogs

Native modal dialogs handle focus containment, hiding outside content from assistive technology, stacking on top and dimming the background. Custom implementations of these are error-prone and need heavy JavaScript event tracking.

### Native `<dialog>`

- Use `<dialog>` and open it with `.showModal()`. A modal dialog makes the outside content inert: it is removed from the accessibility tree and cannot be focused or interacted with. (1.3.2 Meaningful Sequence, A; 2.4.3, A; 4.1.2, A)
  - Users can still move focus to the browser's own interface while the dialog is open.
- Do not add a focus trap to a native modal dialog; the inert outside content already keeps focus inside the dialog. (Best practice)

```html
<button id="open-btn">Open Dialog</button>

<dialog id="accessible-modal" aria-labelledby="title-id">
  <h2 id="title-id">Account Settings</h2>
  <p>Update your details here.</p>
  <button onclick="this.closest('dialog').close()">Close Dialog</button>
</dialog>

<script>
  document.getElementById('open-btn').addEventListener('click', () => {
    document.getElementById('accessible-modal').showModal();
  });
</script>
```

### Custom overlays

- When `<dialog>` cannot be used (some non-modal overlays, framework constraints, or designs where its top-layer positioning conflicts), set `inert` on the outside content so it cannot be reached by keyboard, pointer or assistive technology. Structure the DOM so the overlay is not a descendant of the inert element. (1.3.2, A; 2.4.3, A)
- Put `role="dialog"` on the overlay's container so assistive technology exposes it as a dialog. (4.1.2, A)
- Move keyboard and screen reader focus into the overlay container so users can start navigating its content; do not leave focus in the outside content. (1.3.2, A; 2.4.3, A)

## 13. Testing

### Automated checks

- Run axe-core or Lighthouse audits (for example Lighthouse in Chrome DevTools) to catch problems such as missing alt text or low contrast.
- Do not rely on scores alone; a 100% score does not guarantee real usability.

### Manual testing

- Using only the keyboard (Tab, Shift+Tab, arrow keys, Enter, Space and Esc), confirm that every interactive element is reachable and operable and that focus never gets stuck.
- Test with screen readers in the browsers they are usually paired with: JAWS with Chrome, NVDA with Firefox, Narrator with Edge, VoiceOver with Safari on macOS and iOS, TalkBack with Chrome on Android.
