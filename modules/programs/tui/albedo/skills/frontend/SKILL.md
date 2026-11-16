---
name: frontend
description: >-
  Use for frontend or UI work: building, redesigning, styling, or adjusting
  landing pages, sites, apps, dashboards, components, prototypes, demos, and
  game UI. Guides aesthetic direction, typography, layout, and copy so the
  result does not read as a templated default.
license: Apache-2.0
compatibility: Requires the target project's toolchain and the albedo browser binding for screenshots.
metadata:
  author: Anthropic (frontend-design), adapted by Adam0
  version: "2.0.0"
  short-description: Distinctive, intentional visual design for frontends
---

# frontend

## Scope

New products, standalone pages, and redesigns get the full process below.
Work inside an existing interface, including a new page or view, keeps that
interface's visual language: read the project's existing tokens, components,
and conventions, and match them, because a part that introduces a new visual
language makes the product less coherent. That work skips the direction and
design plan; the design principles and spacing advice apply where the existing
system leaves a choice open, and the writing guidance, quality floor, and
visual check apply either way.

Build working code, not a mock, in the project's existing framework and
component library. A standalone prototype with no stated stack is a single HTML
file. Adding a UI library or other dependency follows the `library-first`
skill, and raster images such as photos, illustrations, and textures come from
the `imagegen` skill. Diagrams are SVG or CSS. Icons come from the project's
existing icon set; when it has none, use Lucide (its package for the project's
framework, or `lucide-static` for a standalone file) rather than drawing icons
by hand, and list the icons you added in the report as placeholders.

## Direction

On new products, standalone pages, and redesigns, approach the work as the
design lead at a studio known for giving every client a distinct visual
identity. The client has rejected proposals that felt templated and is paying
for a point of view, so make deliberate choices about palette, typography, and
layout that are specific to this brief, and commit to an aesthetic risk when the
brief justifies it.

If the brief does not say what the product is, who it is for, and what the
design's primary job is, infer one concrete answer from the repository, project
memory, and context, and state it as an assumption. Ask only when plausible
readings would lead to materially different designs. The subject's industry,
materials, and vernacular are where distinctive choices come from: a toy for
eight-year-olds and a dashboard for financial analysts should look nothing
alike. Use the brief's real content wherever it exists.

## Design principles

On a web page, the hero is the first thing people see. Open with the most
characteristic thing in the subject's world, in whatever form suits it: a
headline, an image, an animation, a live demo, or an interactive moment. A big
number with a small label, supporting stats, and a gradient accent is what
generated pages default to, so use it only when it is truly the best option.
Product surfaces such as apps and dashboards open with the working surface
instead: the data, controls, and status a person came to use, with tabular
figures for numeric data so columns align. Game UI puts legibility first: HUD
text and status stay readable over moving scenes, and interface motion stays
out of the way of gameplay.

Typography carries the personality. One family is often enough; if you use
two, make them clearly distinct. Choose typefaces for this project rather than
the families you would reach for anywhere, and set a clear type scale in the
spirit of The Elements of Typographic Style, with intentional weights, widths,
and spacing. When type is a headline or visual element, make the treatment
of the whole line part of the design: size, weight, width, spacing, and
setting. Give each typeface a fixed role and keep it there: switching a
sentence or phrase in running text to a serif or display face for emphasis or
mood is a common generated habit that breaks the type system, so
emphasis inside running text uses weight or the body family's italic.
Headlines set every word in the same face, style, and color: italicizing,
bolding, or recoloring one word of a headline is among the commonest tells of
a generated page, so do it only when the brief asks for it. Keep line lengths
under about 80 characters; serif body text can run slightly longer and wants
slightly more line-height than sans-serif.

Visual structure is information. Outlines, borders, numbering, eyebrows,
dividers, and labels should encode something true about the content. Numbered
markers (01 / 02 / 03) belong only on real sequences, such as steps or a
timeline.

Use ambient motion, the kind the user did not trigger, sparingly and to direct
attention. One orchestrated moment, such as a single page-load sequence or
reveal, lands better than scattered effects; a fade-and-slide-up on every
section and hover transitions on every card read as generated. Motion that
answers a person's action, such as opening, expanding, or confirming, is
welcome when it shows what changed.

## Process: plan, check against the brief, build

Generated design currently clusters around a few looks:

1. A warm cream background with a high-contrast serif display and a
   terracotta or clay accent.
2. A near-black background with one acid-green or vermilion accent.
3. A broadsheet layout: hairline rules, zero border-radius, dense columns.
4. The SaaS card kit: content chopped into identical rounded cards with one
   radius and the same soft grey shadow everywhere, plus decorative gradient
   washes.
5. Template chrome regardless of subject: a tracked-out all-caps eyebrow or
   label over every heading and block, meta strings joined with middle dots,
   "WORD — fragment" labels, monospace for small labels, and an arrow appended
   to link and button text.

Each is legitimate for some briefs, but they appear whatever the subject, so
they are defaults rather than choices. When the brief or the project's existing
brand pins down a visual direction, follow it exactly, including when it asks
for one of these looks. When it leaves an axis free, spend that freedom on
something specific to the brief. Avoiding these looks is not a direction in
itself; the self-check below is the test.

Plan before building: write a compact design plan in your reply, about ten
lines plus any wireframes:

- Color: a base palette of 4-6 named colors with values, derived from the
  subject.
- Type: the typefaces and their roles.
- Space and shape: the spacing scale, and how radius, borders, and shadow vary
  with hierarchy.
- States: how hover, focus, loading, empty, and error look.
- Layout: the concept in a sentence or two, with ASCII wireframes if comparing
  options, and the alignment approach.
- Principles: what makes this design specific to this brief.

Then check the plan against the brief: imagine a similar prompt for a
different subject, and if you would arrive at the same choice, that part is a
default. Revise it and say what changed and why. Then build from the revised
plan without waiting for approval; the plan is there to be checked, not signed
off.

While building, give spacing one owner. Generated CSS often has a generic
layout rule (`.section`) and a component rule (`.cta`) both setting padding or
margin, so gaps between sections double or cancel. Let the layout container
own the gaps between its children, for example with `gap` or a stack rule, and
keep components free of outer margin. In a project with a CSS framework or
spacing tokens, use those instead.

## Restraint

Match execution to the direction. A restrained direction puts its boldness in
one memorable element and keeps the rest quiet; a maximalist one commits fully,
with execution as elaborate as the vision. Meet a quality floor without
announcing it: responsive down to mobile, visible keyboard focus,
`prefers-reduced-motion` respected, sufficient contrast, and a harmonious
palette.

On new products, standalone pages, and redesigns, before finishing, look at
the decoration you added and cut any element that contributes little, unless
the brief asks for excess. On a lasting project, when you settle on a direction
(palette, type, layout concept) or reject one, record it in one line with
`memory.append`, so later work stays consistent with it and does not retry what
was rejected; skip this for throwaway prototypes.

## Writing in design

Words exist to make the interface easier to understand and use, so treat copy
with the same intent and economy as spacing and color. Decide what the design
needs to say before writing it. Briefs often lack real content, so you will
write the copy and placeholders yourself; generic copy makes a page feel as
templated as a generic layout, so write it for this subject and audience.
Placeholder data is realistic, never lorem ipsum, and includes the edge cases:
long names, empty lists, and many items.

- Name things from the user's perspective in plain language: a user manages
  notifications, not webhook config. Describe what something is or does; when a
  page needs to persuade, make the case with specifics rather than
  superlatives. Specific beats clever.
- Label actions with what they do ("Save changes", not
  "Submit"; "Delete project", not "OK"), and keep an action's name through
  the flow, so "Publish" produces "Published". Consistent vocabulary is how
  people learn their way around.
- Write errors and empty states as directions: say what happened and how to fix
  it, in the interface's voice, without apology or vagueness. An empty screen
  invites the next action.
- Keep the tone conversational and matched to the audience: plain verbs in
  active voice, sentence case unless the project's style differs, no filler, one
  job per element.

## Visual check

A picture shows problems the code hides, so look at the result after each
major step and again before reporting. Every web visual change, small fixes
included, gets a browser check: serve the page the way the project does and
collect load errors, screenshot it at about 1440 and 390 wide (and 820 when the
layout changes there), count elements that overflow at 320 wide, then check
focus and one interactive state. Before the first check, read the tested
recipe with
`print((await skills.read("frontend", "references/visual-check.md")).content)`.
In the screenshots, look for clipped or overlapping text and tap targets
smaller than about 44 by 44 CSS pixels on mobile (the WCAG AAA target; 24 by
24 is the AA minimum).

A native, terminal, or engine-rendered (non-browser) frontend uses the app's or
engine's own screenshot path instead; if no visual check is possible, say so in
the report.

## Report

Beside the result, the report states the widths checked and what the visual
check found, or that none was possible. Where they apply, it also names the
assumptions made about the subject, the plan revisions from the self-check, any
icons added as placeholders, and any direction recorded in memory.
