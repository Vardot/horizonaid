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
| `01-website-base-requirements` | Every shipped canvas page renders; the main navigation and footer name and reach every section. |
| `02-editorial` | The webmaster reaches the content listing, the media library and the page form. |
| `03-permissions` | Anonymous visitors are denied every administrative surface; the login form renders. |

## Running locally

```bash
npm install
./node_modules/.bin/playwright install chromium
LAUNCH_URL=https://horizonaid.ddev.site ./node_modules/.bin/cucumber-js --config cucumber.js --tags "not @wip"
```

`FEATURES` narrows a run to one folder:

```bash
FEATURES="tests/features/01-website-base-requirements/**/*.feature" LAUNCH_URL=... npm test
```

## Notes

- The suite ships no custom step definitions: every step resolves from the
  Varbase E2E core steps.
- The recipe installs its own demo content (the canvas pages and menus); the
  suite creates nothing and deletes nothing.
