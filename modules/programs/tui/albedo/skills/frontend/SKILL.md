---
name: frontend
description: >-
  Use for frontend or UI work: building, redesigning, styling, or adjusting
  landing pages, sites, apps, components, prototypes, demos, and game UI.
license: AGPL-3.0-only
compatibility: Requires access to the target frontend project and its toolchain.
metadata:
  author: Adam0
  version: "1.0.0"
  short-description: Build or redesign visual frontends
---

# frontend

Use when quality depends on art direction, hierarchy, restraint, imagery, or
motion. Aim for deliberate, premium, current: one big idea, strong image, sparse
copy, rigorous spacing, few memorable motions.

## Plan before building

Write:

- Visual thesis: mood, material, energy; one sentence.
- Content plan: hero, support, detail, final CTA.
- Interaction thesis: 2-3 motions that change the feel.

Each section gets one job, one dominant visual, one takeaway or action.

## Defaults

Composition before components. On landing pages and branded sites, the first
viewport is a poster, not a document: anchor it with a full-bleed hero or
canvas; brand or product is loudest. Copy scans in seconds. Use whitespace,
alignment, scale, crop, and contrast before chrome. Use at most two typefaces
and one accent by default. Start cardless: sections, columns, dividers, lists,
media.

### Landing pages

Sequence: hero, one proof or feature, depth (story or workflow), final CTA.

Hero:

- One composition; a dominant full-bleed image or plane.
- On a branded page the hero is edge to edge: no page gutter, frame, or shared
  max-width. Constrain only inner copy.
- Order: brand, headline, body, CTA.
- No default hero cards, stats, logo clouds, pill soup, or floating dashboard.
- Desktop headline about 2-3 lines; readable at a glance on mobile.
- Anchor narrow copy on a calm image area. Keep contrast and tap targets strong.

Viewport still works without the image? The image is too weak. Brand vanishes
when the nav is hidden? Hierarchy is too weak.

Sticky or fixed headers consume viewport budget; header plus hero must fit the
first screen on common desktop and mobile. With `100vh`/`100svh` and a
persistent header, use `calc(100svh - header-height)` or overlay the header.

### Apps

Use calm surface hierarchy, strong type and spacing, few colors, dense readable
information, minimal chrome. Use a card only when the card is the interaction.

Organize: primary workspace, navigation, secondary context or inspector, and one
action/state accent. Start with the operating surface: KPIs, charts, filters,
tables, status, task context. Add a hero only when explicitly requested.

Avoid dashboard-card mosaics, borders around every region, routine decorative
gradients, competing accents, ornamental icons. If a panel works as plain
layout, remove the card.

## Imagery

Images carry the narrative. Brand, venue, editorial, or lifestyle work needs one
or more strong, real-looking images. Prefer in-situ photography over abstract
gradients or fake 3D. Crop with a stable tonal copy area. Avoid embedded
signage, logos, typographic clutter. Generated images must not bake in UI
frames, splits, cards, or panels. Multiple moments: multiple images, not a
collage. Texture alone cannot anchor a viewport.

## Copy

Use product language, never design commentary or prompt language. The headline
carries meaning; support is usually one short sentence. Cut repeated points.
Each section has one responsibility: explain, prove, deepen, or convert.

Product UI needs utility copy:

- Orientation, status, and action before promise or mood.
- Headings name area or action: `Selected KPIs`, `Plan status`,
  `Search metrics`, `Top segments`, `Last sync`.
- No metaphor, campaign copy, or executive banner unless requested.
- Support explains scope, behavior, freshness, or decision value in one sentence.
- Could it appear in an ad? Rewrite.
- Remove anything that does not help operate, monitor, or decide.
- Headings, labels, and numbers alone explain the page.

If cutting 30% improves the page, keep cutting.

## Motion

Visually led work ships 2-3 intentional motions:

- Hero entrance sequence.
- Scroll-linked, sticky, or depth effect.
- Hover, reveal, or layout transition that improves affordance.

If Motion (formerly Framer Motion) is available, prefer it for reveals, shared
layout, scroll opacity/translate/scale, sticky story, narrative carousel,
menus/drawers/modals.

Motion must show in a quick recording and stay smooth on mobile, fast,
restrained, consistent. Remove purely ornamental motion. Respect
`prefers-reduced-motion`: reduce or drop movement, keep content and state
changes visible.

## Reject

- Cards or hero cards by default.
- Boxed or center-column hero when the brief says full bleed.
- Several dominant ideas per section.
- Many tiny devices needed to explain a section.
- Headline overpowering the brand.
- Filler.
- Split hero, unless the text side is calm and unified.
- More than two typefaces or one accent without product-system reason.
- Generic SaaS card grid first impression.
- Strong image, weak brand; strong headline, absent action.
- Busy image behind text; repeated mood sections; purposeless carousel.

## Final check

For new or redesigned pages, render at desktop and mobile widths, for example
with the browser tools, and look at the screenshots before finishing. Revise on
any no: Brand unmistakable on the first screen? Strong visual anchor? Headlines
alone explain the page? One job per section? Every card necessary? Motion
improves hierarchy or atmosphere? Still premium with shadows removed?
