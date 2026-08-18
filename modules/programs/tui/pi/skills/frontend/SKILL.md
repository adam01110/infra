---
name: frontend-skill
description: >-
  Use when building or substantially redesigning a visual frontend, including
  landing pages, sites, apps, prototypes, demos, and game UI.
license: AGPL-3.0-only
compatibility: Requires access to the target frontend project and its toolchain.
metadata:
  author: Adam0
  version: "1.0.0"
  short-description: Build or redesign visual frontends
allowed-tools: read grep find bash web_search fetch_content
---

# frontend

quality depends on art direction, hierarchy, restraint, imagery, motion? use
this. goal: deliberate, premium, current. one big idea. strong image. sparse
copy. rigorous space. few memorable motions.

## think before build

write:

- visual thesis: mood, material, energy; one sentence.
- content plan: hero, support, detail, final CTA.
- interaction thesis: 2-3 motions changing feel.

section gets one job, dominant visual, takeaway/action.

## defaults

composition before components. first viewport is poster, not document.
full-bleed hero/canvas anchor. brand/product loudest. copy scan in seconds. use
whitespace, alignment, scale, crop, contrast before chrome. max two typefaces;
one accent by default. cardless first: sections, columns, dividers, lists,
media.

### landing page

sequence: hero -> one proof/feature -> depth/story/workflow -> final CTA.

hero:

- one composition; dominant full-bleed image/plane.
- branded page means hero edge-to-edge: no page gutter, frame, shared max-width.
  constrain inner copy only.
- order: brand, headline, body, CTA.
- no default hero cards, stats, logo clouds, pill soup, floating dashboard.
- desktop headline about 2-3 lines; mobile one-glance readable.
- narrow copy anchored on calm image area. contrast and tap targets strong.

remove image and viewport still works? image too weak. hide nav and brand
disappears? hierarchy too weak.

sticky/fixed header consumes viewport budget. header + hero must fit common
desktop/mobile first screen. `100vh`/`100svh` plus persistent header? use
`calc(100svh - header-height)` or overlay header.

### app

use calm surface hierarchy, strong type/space, few colors, dense readable
information, minimal chrome. card only when card is interaction.

organize primary workspace, navigation, secondary context/inspector, one
action/state accent. start with operating surface: KPIs, charts, filters,
tables, status, task context. hero only when explicitly requested.

avoid dashboard-card mosaic, borders around every region, routine decorative
gradients, competing accents, ornamental icons. panel works as plain layout?
remove card.

## imagery

image must carry narrative. brand, venue, editorial, lifestyle? at least one
strong real-looking image. prefer in-situ photography over abstract
gradient/fake 3D. crop with stable tonal copy area. avoid embedded signage,
logos, typographic clutter. generated image must not bake in UI frames, splits,
cards, panels. multiple moments? multiple images, not collage. texture alone not
viewport anchor.

## copy

product language, never design commentary or prompt language. headline carries
meaning; support usually one short sentence. repeated point? cut. section
responsibility: explain, prove, deepen, convert.

product UI needs utility copy:

- orientation, status, action before promise/mood.
- headings name area or action: `Selected KPIs`, `Plan status`,
  `Search metrics`, `Top segments`, `Last sync`.
- no metaphor, campaign copy, executive banner unless requested.
- support explains scope, behavior, freshness, decision value in one sentence.
- could appear in ad? rewrite.
- does not help operate, monitor, decide? remove.
- headings, labels, numbers alone should explain page.

30% deletion improves page? keep deleting.

## motion

visually led work ships 2-3 intentional motions:

- hero entrance sequence.
- scroll-linked, sticky, or depth effect.
- hover, reveal, or layout transition improving affordance.

Framer Motion available? prefer for reveals, shared layout, scroll
opacity/translate/scale, sticky story, narrative carousel, menus/drawers/modals.

motion must show in quick recording, stay smooth mobile, fast, restrained,
consistent. ornamental only? remove.

## reject

- cards or hero cards by default.
- boxed/center-column hero when brief says full bleed.
- several dominant ideas in section.
- many tiny devices needed to explain section.
- headline overpowering brand.
- filler.
- split hero unless calm unified text side.
- more than two typefaces or one accent without product-system reason.
- generic SaaS card grid first impression.
- image strong but brand weak; headline strong but action absent.
- busy image behind text; repeated mood sections; purposeless carousel.

## final check

brand unmistakable first screen? strong visual anchor? headlines alone explain?
each section one job? every card necessary? motion improves
hierarchy/atmosphere? remove shadows and still premium? no answer means revise.
