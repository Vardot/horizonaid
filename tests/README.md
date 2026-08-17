# Horizon Aid — Automated Functional Testing suite

Browser-driven BDD suite for the Horizon Aid site template, built on
[`@vardot/varbase-e2e`](https://www.npmjs.com/package/@vardot/varbase-e2e)
(Playwright + Cucumber-js).

## Layout

| Path | Holds |
| --- | --- |
| `tests/features/` | Gherkin suites, one numbered folder per concern. |
| `tests/selectors/horizonaid-theme.json` | Named selectors for the Horizon Aid theme. |
| `tests/reports/` | JSON + HTML + PDF run reports (CI artifacts). |
| `tests/screenshots/` | Failure screenshots (CI artifacts). |

## Suites

| Folder | Proves |
| --- | --- |
| `01-website-base-requirements` | Every shipped Canvas page renders, the main navigation and footer name and reach every section, and the header collapses and expands correctly at a phone width. |
| `02-countries` | The Countries listing, a country page and its sections, and the related-countries block the template ships. |
| `03-programs` | The Programs listing and a program page. |
| `04-resources` | The Resources listing, a resource article, and the keyword and Program filters plus the pager. |
| `05-events` | The Events listing, an event page, and its filters and paging. |
| `06-impact-and-donate` | The Our Impact page's figures and the Donate page. |
| `07-quality` | Accessibility and front-end performance of the shipped pages. |
| `08-seo` | The metatags each page type emits. |
| `09-editorial` | A webmaster can reach the editorial surfaces and can create, verify and delete each content type the template ships, leaving the site as it found it. |
| `10-drupal-canvas` | Every Canvas page the recipe ships opens in the Canvas editor, not just in the front end. One file per page group, because each editor mount is a heavy React SPA. |
| `11-permissions` | Anonymous visitors are denied every administrative surface, and each role reaches only what it should. |
| `12-search` | The header search toggle, the results page's heading, inline search box and row shape, and what the page does when a query finds nothing or more than one page. |

## Running locally

```bash
npm install
./node_modules/.bin/playwright install chromium
LAUNCH_URL=https://horizonaid.ddev.site ./node_modules/.bin/cucumber-js --config cucumber.js --tags "not @wip"
```

`FEATURES` narrows a run to one folder:

```bash
FEATURES="tests/features/02-countries/**/*.feature" LAUNCH_URL=... npm test
```

The suite logs in as the `webmaster` account declared in `cucumber.js`, so a
local site needs that account's password to match (`dD.123123ddd`), and needs
the same preparation CI does before it can drive forms:

```bash
ddev drush user:password webmaster 'dD.123123ddd'
ddev drush pm:uninstall antibot -y
ddev drush config:set user.flood ip_limit 1000000 -y
ddev drush config:set user.flood user_limit 1000000 -y
```

Without that, a login step still reports as passed while the browser stays
anonymous, and only an assertion that needs an authenticated page will fail.

## CI

The `test` stage fans out over `parallel: matrix` with one job per feature
folder, and one job per page group inside `10-drupal-canvas`. Each job builds
its own Varbase 11 site, installs the recipe with
`drush site:install recipes/horizonaid`, serves it, runs its own folder and
writes its own report keyed by `$SUITE`. The whole suite in one job exceeds the
runner's script limit.

## Cold image caches on a fresh install

The theme renders its photography through `drimage_improved`, which creates each responsive
image style on demand: the browser hits `/drimage/{width}/{height}/{fid}/...` and only then
does the style and its WebP derivative exist. Until that has happened once for a width, a
direct request for the derivative returns 404, so a freshly installed site emits harmless
404s on first paint at any width nobody has visited yet, and that first paint is slower.

No scenario in this suite asserts zero console errors or that every asset returns 200,
precisely so this cannot cause a false failure. Where a scenario genuinely depends on a
warmed derivative it warms its own page first (`04-02` warms the article it measures, and
`07-02` self-warms with a reload and carries two budget tiers). There is deliberately no
suite-wide warm-up feature: the `warm up "<path>" at all testing breakpoints` step visits
seven breakpoints inside a single step, and on the heaviest pages that exceeds the 45s
per-step ceiling varbase-e2e enforces, so it failed as a timeout and warmed nothing.

## Notes

- The suite ships no custom step definitions: every step resolves from the
  Varbase E2E core steps.
- The recipe installs its own demo content (the Canvas pages, the countries,
  programs, resources and events, and the menus). The read-only suites create
  nothing; the `09-editorial` suites delete whatever they create.
