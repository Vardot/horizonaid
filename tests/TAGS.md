# Horizon Aid — the suite's tag taxonomy

One page, so that `@smoke` means the same thing here as on every other Vardot suite.
Tags are the API between this suite and everything that runs it: CI lanes, a hotfix
confidence check, a nightly run. Adding a tag is cheap, retrofitting one is not, so new
tags get reviewed in the merge request the way a new dependency would.

Tags inherit downward: a tag on the `Feature:` line applies to every scenario in the
file, and a scenario's effective set is the union of the feature's tags, its own, and any
on its `Examples:` block.

Every scenario carries **one purpose tag, one speed tag, its environment tags, and at
least one domain tag**. Technology and status tags appear only when they apply.

## Purpose — why the scenario exists

| Tag | Means |
| --- | --- |
| `@smoke` | Read-only, under 5 seconds, safe on production. The "is this site alive" set: a page answers, the navigation is there, a listing has content. |
| `@regression` | Guards behaviour that already shipped. The default for most scenarios. |
| `@acceptance` | Proves a capability the template promises: a filter narrows, a pager pages, an editor can create a country. |
| `@exploratory` | Edge cases and unusual flows: the last page of a listing, a filter that matches nothing, the menu at a phone width. |

`@check` is kept alongside these for continuity with the other Varbase suites, where it
marks a scenario that asserts rather than prepares. A scenario that only prepares state
carries `@tools` instead, because it asserts nothing.

## Severity — how much it matters

`@critical` is a severity tag, not a purpose tag, and it is orthogonal to the four above:
it marks a scenario whose failure means the template is broken for a visitor, whatever
kind of scenario it is. It is what makes `test:hotfix` wider than `test:smoke`: a critical
scenario too slow to be `@smoke` still belongs in a pre-ship check. A scenario carries one
purpose tag and, when it earns it, `@critical` as well.

## Speed — measured, not guessed

| Tag | Means |
| --- | --- |
| `@fast` | Best observed run under 5 seconds. |
| (untagged) | Between 5 and 30 seconds. |
| `@slow` | Best observed run over 30 seconds. |
| `@nightly` | Too slow to earn a place on every push, such as the Canvas editor mounts. |

Speed tags come from the JSON reports of real runs
(`tests/reports/*.json`, `elements[].steps[].result.duration`, nanoseconds), taking each
scenario's **best** observed time so a loaded runner does not relabel the suite. Re-derive
them when the suite changes shape, not by eye.

## Technology — what the scenario needs

| Tag | Means |
| --- | --- |
| `@api` | Asserts on the response or its metadata, not on a rendered page. |
| `@no-javascript` | Passes with JavaScript off. |

**`@javascript` is deliberately unused in this suite.** In varbase-e2e that tag is not a
label, it switches JavaScript error capture into fail mode, so a single console error
fails the scenario. Horizon Aid renders its photography through `drimage_improved`, which
creates each responsive image style on demand: on a freshly installed site the first
request for an uncached width returns 404 until `/drimage/{width}/{height}/{fid}/...` has
been hit once. Every CI job installs its own site, so those 404s are normal on first
paint and `@javascript` would fail honest scenarios. `@screenshots`, `@video` and
`@no-video` are runtime switches in the same way: use them for what they do, never as
labels.

## Environment — where it may run

`@local`, `@development`, `@staging`, `@production`, listed explicitly rather than
collapsed into `@any`, matching the other Varbase suites. Anything that writes content
never carries `@production`.

## Status — the scenario's own state

| Tag | Means |
| --- | --- |
| `@wip` | Half written. Excluded from CI, costs nothing, fails nothing. |
| `@flaky` | Not used here, by policy. A scenario that passes alone and fails in the suite has a state-leak to fix, and tagging it hides the bug. |
| `@skip` | Temporarily disabled. Needs a comment saying why and who is undoing it. |

## Domain — which part of the template

`@navigation`, `@countries`, `@programs`, `@resources`, `@events`, `@impact`, `@donate`,
`@editorial`, `@crud`, `@canvas`, `@permissions`, `@security`, `@seo`, `@a11y`, `@perf`.

## The canonical runs

Expressions live in `package.json` scripts, so nobody types them by hand and two runs are
always comparable:

```bash
npm run test:ci          # not @wip and not @flaky and not @skip
npm run test:smoke       # @smoke and not @wip
npm run test:hotfix      # (@smoke or @critical) and not @wip and not @flaky
npm run test:lane:fast   # @fast and not @wip
npm run test:production   # @production and not @wip and not @slow
npm run test:nightly     # not @wip and not @skip, the whole thing including @nightly
```

Quote every expression: the parentheses and spaces mean something to the shell too, and
an unquoted filter that "mostly works" is how a pipeline ends up silently running the
wrong subset.

## Known limits of this taxonomy, as measured

Written down rather than smoothed over, because each one is a decision someone may want to
revisit:

1. **A Scenario Outline cannot carry a speed tag per row.** One `Examples:` block shares a
   tag set, and rows can differ by an order of magnitude: the header donate call to action
   runs about 2s on `/events` and 13s on `/countries`, where more image derivatives are
   generated. Outlines are therefore tagged by their **slowest** row's best time, so the
   tag is never a lie for any row, at the cost of a few genuinely fast rows sitting outside
   `@fast`. Splitting such a block by speed is the fix if it ever matters more than the
   file's readability.
2. **The smoke lane has no Impact or Donate coverage.** Every scenario there measures over
   5 seconds, mostly in derivative generation on first paint, so nothing qualifies under
   the "under 5 seconds" clause. Rather than bend the clause, the gap is recorded here: the
   donate path is covered by `@critical` and by `test:hotfix`, not by `test:smoke`.
3. **`test:production` is not as quick as it sounds.** Excluding `@slow` still admits the
   whole 5-to-30-second middle band, which on the Impact page alone is around three and a
   half minutes. If a post-deploy check needs a hard ceiling, give it its own lane rather
   than redefining `@slow`.
4. **`@nightly` is currently unused.** The slow donate scenarios are the revenue path and
   stay on every push, which is the right call even though they are the slowest scenarios
   in the suite. The tag stays defined for the Canvas editor mounts if their cost grows.
