---
name: unslop
description: >-
  Remove AI writing patterns while preserving meaning and tone. Use when the
  user explicitly invokes unslop or asks to remove AI tells from text.
license: AGPL-3.0-only
compatibility: Requires access to the text being edited.
metadata:
  author: Adam0
  version: "1.0.0"
  short-description: Remove AI writing patterns without changing meaning
allowed-tools: read edit write
---

# unslop

<!-- rumdl-disable MD029 -->

text has AI tells? scan, rewrite, check meaning and intended tone stay.
edit writing, not facts. no invented sources, measurements, or certainty.
return edited text unless user asks for explanation.

rule ids stay stable for other skills. gaps intentional. never renumber.

## content

3. empty -ing clauses: "highlighting", "ensuring", "showcasing", "fostering".
   cut or replace with sourced facts.
5. vague attribution: "experts believe", "reports suggest". name source or cut.

## words

7. AI vocabulary: additionally, crucial, delve, enduring, enhance, fostering,
   garner, interplay, intricate, landscape, pivotal, showcase, tapestry,
   testament, underscore, vibrant. use plain words; keep literal meanings.
8. "serves as", "stands as", "boasts", "features"? use "is" or "has".
9. "not just X, but Y"? state point directly.
10. forced groups of three? use natural count.
11. synonym cycling? pick one term, repeat it.
12. "from X to Y" without real scale? list topics.

## style

13. no em dashes. separate thoughts with periods or commas. no parentheses,
    en dashes, or hyphens as dash substitutes.
14. colon before list/example fine. mid-sentence connector? rewrite directly.
15. bold only where useful, not every name/acronym.
16. bold label repeats line? use prose. lead-in names item, ends with period,
    adds new detail? fine.
17. sentence case headings.
18. no decorative emojis in headings/bullets.
19. straight quotes, not curly.

## chat

20. cut chatbot filler: "of course", "certainly", "hope this helps",
    "let me know", "found the smoking gun".
22. cut flattery/agreement theater: "great question", "absolutely right".

## filler

23. "in order to" -> "to". "due to the fact that" -> "because".
    "it is important to note"? cut.
24. stacked hedges? keep only uncertainty evidence needs. "might possibly" -> "may".
25. generic conclusion? give specific fact/plan or cut.

## concrete speech

26. abstract metaphor nouns? name real thing. substrate -> base, wedge -> add,
    vector -> method, gold-plating -> more than needed, evacuate -> move out,
    endgame -> last phase. check locus, vantage, nexus, primitive, harness,
    surface, bedrock, scaffolding, modality, paradigm, ratchet, north star,
    flywheel. literal technical term needed? keep it.
27. say mechanism, instruction, fact, or number. not feeling.
    "types follow schema" -> "a column rename fails the build" only if true.
    sentence fits any project's docs unchanged? make specific or cut.
28. dense sentence? split or drop clauses. one idea per sentence.
29. prefer active voice, name actor. "queries are validated" -> "compiler
    validates queries". actor unknown or irrelevant? passive fine.
30. weak verb plus adverb? use stronger verb or measured delta. no fake numbers.
31. plain word: utilize/leverage -> use, facilitate -> help, numerous -> many,
    in the event that -> if.
32. cut flourish, aphorisms, rhetorical fragments, personified code, figurative
    verbs, stock framing. "rides along" -> "is included". say literal meaning.
33. do not over-compress edited prose. keep articles and verbs. spell out arrows
    and abbreviations when reader must decode. short whole sentences beat shorthand.
