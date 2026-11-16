# Improve next page load performance

One of the most effective ways to speed up navigation within a site is to start loading the next page before the user visits it. Speculative loading with the Speculation Rules API does this.

## How it works

JSON speculation rules tell the browser which links it may prefetch or prerender, so those pages load faster when clicked.

A rule either lists URLs under a `urls` key (a list rule), or uses a `where` key with href patterns and CSS selectors that match links on the page (a document rule).

The optional `eagerness` property sets when to speculate: `immediate`, `eager`, `moderate` or `conservative`. `immediate` speculates as soon as possible; `eager`, `moderate` and `conservative` wait for user signals: hovering briefly, hovering longer, or starting to click, respectively.

Document rules default to `conservative` eagerness and list rules to `immediate`.

Rules with different eagerness can be combined, for example to prefetch eagerly and prerender once the user shows more intent.

## When to use it

Speculative loading suits static pages whose content rarely changes and that are cheap to produce, especially when cached at the edge. It also works for dynamic pages, but watch for stale content.

It is usually used for same-origin links; advanced options allow some cross-origin speculation. This guide covers the common same-origin case.

More eager speculation fits pages that are likely next, such as a headline article or the next step of a multi-step process like a course.

Less eager speculation fits pages where the next move is unclear, such as many links that are equally likely. Waiting for signals like hovering or the start of a click still gives a head start, even if the page is not fully prefetched or prerendered in time.

Prefetch is more conservative than prerender: it uses fewer resources on client and server but gives less benefit. It is a good first step; move to prerender when the developer explicitly asks for it.

## How to use it

Put the JSON rules in a `<script type="speculationrules">` element, in the `<head>` or `<body>`, or add them dynamically with JavaScript.

An optional `tag`, set globally or per rule, is sent in the `Sec-Speculation-Tags` request header, so the server can tell which speculations were made.

### List rule prefetching predefined URLs

```html
<script type="speculationrules">
  {
    "tag": "product-page-speculations",
    "prefetch": [
      {
        "urls": ["/product/1", "/product/2", "/product/3"]
      }
    ]
  }
</script>
```

### Document rule prerendering all same-origin links

```html
<script type="speculationrules">
  {
    "tag": "all-links-speculations",
    "prerender": [{
      "where": { "href_matches": "/*" }
    }]
  }
</script>
```

### Document rule with exclusions for interactive sites

```html
<script type="speculationrules">
  {
    "tag": "speculations-with-exclusions",
    "prerender": [{
      "where": {
        "and": [
          { "href_matches": "/*" },
          { "not": {"href_matches": "/wp-admin"}},
          { "not": {"href_matches": "/*\\?*(^|&)add-to-cart=*"}},
          { "not": {"selector_matches": ".do-not-prerender"}},
          { "not": {"selector_matches": "[rel~=nofollow]"}}
        ]
      }
    }]
  }
</script>
```

### Mixed rule set

This prefetches all links eagerly, then prerenders the same links with `moderate` eagerness once there are stronger signals. It assumes the developer has opted in to aggressive speculation.

```html
<script type="speculationrules">
  {
    "prefetch": [{
      "tag": "prefetch-speculations",
      "where": { "href_matches": "/*" },
      "eagerness": "eager"
    }],
    "prerender": [{
      "tag": "prerender-speculations",
      "where": { "href_matches": "/*" },
      "eagerness": "moderate"
    }]
  }
</script>
```

## Guidelines

- Prefetch and prerender pages the user is likely to visit next.
- Speculation suits static sites best: content rarely changes and pages are cheap to produce, especially when cached at the edge.
- Take more care with dynamic pages, whose content changes often, can go stale, and is more expensive to produce.
- Prefer document rules to list rules. They are more flexible, one rule can be shared across pages, and they cover pages not known in advance.
- Choose between prefetch and prerender deliberately. Prerender is more expensive and can cause more unintended side effects in complex applications that show dynamic state, but gives a better experience. If the developer has not stated a preference, ask; if you cannot, use prefetch.
- Choose the `eagerness` level deliberately. More eager speculation gives a better experience but uses more resources and can cause more side effects in complex applications with dynamic state. If the developer has not stated a preference, ask; if you cannot, use the less eager option.
- Do not overuse speculation, such as speculating every link on the page. Browsers impose limits (2 speculations for non-eager speculations), and `immediate` should be reserved for a very small number of links.
- Never speculate URLs that likely change state, such as `/logout` or `/add-to-cart`; exclude them explicitly when a document rule could match them.
- Do not use speculation rules in single-page applications (SPAs). They are designed for multi-page applications (MPAs), where each navigation loads a new document. SPA navigations do not load a new document, so the rules do not work as expected.

## Browser support and fallback

Browser support for Speculation rules: Limited availability.
Supported by: Chrome 109 (Jan 2023) and Edge 109 (Jan 2023).
Unsupported in: Firefox and Safari.

Speculative loading is a progressive enhancement: browsers without support ignore the rules. Given the potential gains, it is safe and recommended to use anyway.
