---
name: unslop
description: >-
  Remove AI writing patterns while preserving meaning and tone. Use when the
  user explicitly invokes unslop or asks to remove AI tells from text.
license: AGPL-3.0-only
compatibility: Requires access to the text being edited.
metadata:
  author: Adam0
  version: "1.1.0"
  short-description: Remove AI writing patterns without changing meaning
allowed-tools: read edit write
---

# unslop

<!-- rumdl-disable MD029 -->

Scan the text for AI tells, rewrite them, and check that meaning and intended
tone survive. Edit the writing, not the facts: do not invent sources,
measurements, or certainty. Return the edited text unless the user asks for an
explanation.

These are editorial checks, not proof of AI authorship. Preserve the intended
voice, genuine opinions and feelings, necessary explanation, and honest
uncertainty. Do not flatten all prose into neutral encyclopedia writing. Cleanup
alone does not authorize imitating the user or changing another author's voice.

Rule ids are referenced by other skills, so keep them stable. Gaps are
intentional; do not renumber.

## Content

3. Empty -ing clauses ("highlighting", "ensuring", "showcasing", "fostering"):
   cut them or replace with sourced facts.
5. Vague attribution ("experts believe", "reports suggest"): name the source or
   cut.

## Words

7. AI vocabulary: additionally, crucial, delve, enduring, enhance, fostering,
   garner, interplay, intricate, landscape, pivotal, showcase, tapestry,
   testament, underscore, vibrant. Use plain words; keep literal meanings.
8. Replace "serves as", "stands as", "boasts", "features" with "is" or "has".
9. Replace "not just X, but Y" with the point stated directly.
10. Replace forced groups of three with the natural count.
11. Avoid synonym cycling: pick one term and repeat it.
12. Replace "from X to Y" without a real scale with a list of topics.

## Style

13. No em dashes. Separate thoughts with periods or commas. Do not substitute
    parentheses, en dashes, or hyphens for dashes.
14. A colon before a list or example is fine. A colon used as a mid-sentence
    connector should be rewritten directly.
15. Use bold only where useful, not on every name or acronym.
16. If a bold label repeats its line, use prose. A lead-in that names the item,
    ends with a period, and adds new detail is fine.
17. Use sentence case headings.
18. No decorative emojis in headings or bullets.
19. Use straight quotes, not curly.

## Chat

20. Cut chatbot filler: "of course", "certainly", "hope this helps",
    "let me know", "found the smoking gun".
22. Cut flattery and agreement theater: "great question", "absolutely right".

## Filler

23. "in order to" -> "to". "due to the fact that" -> "because". Cut "it is
    important to note".
24. For stacked hedges, keep only the uncertainty the evidence needs. "might
    possibly" -> "may".
25. Replace a generic conclusion with a specific fact or plan, or cut it.

## Concrete speech

26. Replace abstract metaphor nouns with the real thing: substrate -> base,
    wedge -> add, vector -> method, gold-plating -> more than needed,
    evacuate -> move out, endgame -> last phase. Also check locus, vantage,
    nexus, primitive, harness, surface, bedrock, scaffolding, modality,
    paradigm, ratchet, north star, flywheel. Keep a literal technical term when
    it is needed.
27. State the mechanism, instruction, fact, or number, not a feeling. "types
    follow schema" -> "a column rename fails the build", only if true. If a
    sentence would fit any project's docs unchanged, make it specific or cut it.
28. Split dense sentences or drop clauses: one idea per sentence.
29. Prefer active voice and name the actor: "queries are validated" ->
    "compiler validates queries". Passive is fine when the actor is unknown or
    irrelevant.
30. Replace a weak verb plus adverb with a stronger verb or a measured delta. Do
    not invent numbers.
31. Use plain words: utilize/leverage -> use, facilitate -> help, numerous ->
    many, in the event that -> if.
32. Cut flourishes, aphorisms, rhetorical fragments, personified code,
    figurative verbs, and stock framing. "rides along" -> "is included". Say
    the literal meaning.
33. Do not over-compress edited prose. Keep articles and verbs. Spell out arrows
    and abbreviations the reader would have to decode. Short whole sentences
    beat shorthand.

## Evidence and unfinished text

34. For citations or source identifiers, check that the source exists and
    supports the attached claim. Correct mismatches only from verified
    evidence; never invent replacement citations. If you cannot verify, flag
    the limitation rather than claim verification or silently remove
    potentially valid evidence.
35. Keep claims of significance, influence, recognition, or broad reception
    proportionate to the supplied facts or sources. An isolated mention or
    media list does not establish widespread acclaim. Preserve clearly stated
    personal opinion without presenting it as independent consensus.
36. When informational prose uses advertising-like praise instead of facts,
    replace unsupported superlatives with specific supported description. Keep
    genuine enthusiasm, subjective judgments, and the requested persuasive
    genre; positive language alone is not an error or a sign of AI authorship.
37. Remove irrelevant model-cutoff disclaimers or assistant-access claims from
    the deliverable. Preserve material uncertainty and relevant historical
    dates. Check time-sensitive claims before presenting them as current; if
    unverified, qualify or flag them instead of guessing.
38. For abrupt truncation, drafting instructions, or unresolved placeholders,
    resolve only from supplied or verified information. Flag missing essential
    content; do not invent it or silently cut it to make the draft look
    complete. Keep intentional placeholders when the user requests a template.

These additions draw on
[Wikipedia's signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing).
Its indicators are descriptive and context-dependent; Wikipedia-only markup
and editorial conventions are not general requirements for other prose.
