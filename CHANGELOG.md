# Changelog

All notable changes to the Horizon Aid site template recipe are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.3] - 2026-09-14
### Added
- feat: [#3622833](https://www.drupal.org/i/3622833) Add a Newsletter Canvas page at `/newsletter` and
  point the footer Subscribe button at it. The page is built from the existing template components (a
  media banner, a heading, supporting text, the Newsletter Subscribe webform block and three icon
  cards), so it stays editable in Canvas and a submission renders its confirmation message inside the
  page instead of on a bare form route.

### Fixed
- fix: [#3622817](https://www.drupal.org/i/3622817) Give the footer Subscribe button a link
  destination. It rendered as a button with no target, so the footer newsletter call to action did
  nothing when clicked.

### Changed
- Require `drupal/varbase_webform_base:~1.0.2`, which carries the email field height fixes the
  Newsletter page depends on, and `drupal/vartheme_bs5_horizonaid:~1.0.2`. The remaining
  `varbase_*_base` recipes stay at `~1.0.0`.

### Known issues
- [#3620718](https://www.drupal.org/i/3620718) A fresh install can leave a stale cache such that the
  first web request fatals site-wide with
  `PluginNotFoundException: The "redirect" entity type does not exist`. Running `drush cr` clears it
  immediately and the site is then fully correct. Not fixed in this release.

## [1.0.2] - 2026-09-10
### Fixed
- fix: [#3622092](https://www.drupal.org/i/3622092) Install `canvas_page_template_component` from the
  recipe so Canvas does not install it during `RecipeAppliedEvent`. Installing the site template with
  `drush site:install recipes/horizonaid` on a stock `drupal/cms` build aborted with
  `You have requested a synthetic service ("kernel")`; it now exits 0, with no patches of any kind.
- fix: [#3621847](https://www.drupal.org/i/3621847) Remove the nineteen Canvas Component config
  entities shipped in the fallback state, which logged 477 PHP warnings from
  `Drupal\canvas\Entity\Component::getSlotDefinitions()` on every install. The install now logs
  zero warnings and zero PHP errors.
- fix: [#3621848](https://www.drupal.org/i/3621848) Point the header search box at a plain form
  instead of the search page's Views exposed block, so the Component keeps its dependencies.
- fix: [#3622140](https://www.drupal.org/i/3622140) Restore the inline exposed form on the search
  results page, so the page renders its own search box again.
- fix: [#3622112](https://www.drupal.org/i/3622112) Rename user 1 so the functional suite can log in,
  and shorten the two job names.
- fix: [#3622114](https://www.drupal.org/i/3622114) Clear the restored `cmssite` directory before
  `composer create-project`, so a cached CI run no longer fails.

### Changed
- task: [#3622094](https://www.drupal.org/i/3622094) Test Horizon Aid on Drupal CMS only, and rename
  the test job to functional testing. CI now builds a single Drupal CMS host and runs the functional
  suite against it, as `🧩 Drupal CMS - Horizon Aid` and `🧪 Functional`, and the
  `vardot/varbase-patches` wiring was removed from the pipeline.

### Known issues
- [#3620718](https://www.drupal.org/i/3620718) A fresh install can leave a stale cache such that the
  first web request fatals site-wide with
  `PluginNotFoundException: The "redirect" entity type does not exist`. Running `drush cr` clears it
  immediately and the site is then fully correct. Not fixed in this release.

## [1.0.1] - 2026-09-08
### Fixed
- fix: [#3621336](https://www.drupal.org/i/3621336) Remove the three never-applied base recipes, so
  the template resolves on Stable for Drupal CMS.

## [1.0.0] - 2026-09-06
### Changed
- First stable release. Promotes 1.0.0-rc1 to 1.0.0 with no functional change to the recipe.
- A stock `drupal/cms` root ships `minimum-stability: stable`. While every published version was a
  pre-release, a site builder had to run `composer config minimum-stability dev` before
  `drupal/horizonaid` would resolve. The stability setting was the gate rather than the version
  constraint: `~1` normalizes to a lower bound of 1.0.0.0-dev and an upper bound below 2.0.0.0, so it
  already admitted a pre-release once stability permitted. With 1.0.0 stable,
  `composer require drupal/horizonaid` works on an untouched Drupal CMS root.
- Every cross-dependency now names a stable constraint: the sixteen `varbase_*_base` recipes and
  `drupal/vartheme_bs5_horizonaid`, all at `~1.0.0`, all resolving to a published stable 1.0.0.

### Added
- test: [#3621203](https://www.drupal.org/i/3621203) Name the `color-contrast` and
  `page-has-heading-one` accessibility rules in the home page regression scenarios, with an explicit
  single-`h1` assertion. Both rules had regressed on a sibling Varbase site template.

## [1.0.0-rc1] - 2026-09-06
### Changed
- Promote the recipe to a release candidate. This release carries no functional change over
  1.0.0-beta1; it is a maturity step on the way to 1.0.0 stable, so that the Horizon Aid site
  template recipe works with Drupal CMS by default, on stable releases. Today
  `drupal/horizonaid:~1` resolves only after `minimum-stability` is loosened to `dev`, because every
  published version is still a pre-release. The constraint is not the blocker: `~1` normalizes to
  `>=1.0.0.0-dev <2.0.0.0`, so a pre-release does satisfy the range once the stability setting
  permits it. Once 1.0.0 stable exists, `composer require drupal/horizonaid` works against a stock
  `drupal/cms` root with its default `minimum-stability: stable` and no extra configuration.
- Re-pin every cross-dependency to its published constraint after the Back to DEV change: the
  sixteen `varbase_*_base` recipes at the floors verified for 1.0.0-beta1, and
  `drupal/vartheme_bs5_horizonaid` at `~1.0.0-rc1`.
- Update the version badge and the Composer install command to `1.0.0-rc1` in `README.md`.

## [1.0.0-beta1] - 2026-09-05
### Fixed
- Reshoot the installer card at 500x400, the aspect ratio the Drupal CMS site-template picker
  actually renders. The picker draws the card in a 368x294 box (ratio 1.25) with `object-fit: cover`,
  so the previous 632x304 image (ratio 2.08) had roughly 40% of its width discarded, cutting the logo
  and nav off the preview. Every other site template ships 500x400
  ([#3620998](https://www.drupal.org/i/3620998)).
- Rewrite the recipe description in the house style of the other site templates, opening with what
  the template is designed for and naming what it ships ([#3620998](https://www.drupal.org/i/3620998)).

## [1.0.0-alpha2] - 2026-09-05
### Added
- Re-export the Drupal Canvas component configs so the Canvas Icon Picker is available on the shipped
  components ([#3620065](https://www.drupal.org/i/3620065)).
### Changed
- Install the front-end libraries with Composer rather than `drupal-libraries-sync`, so a build needs no
  extra sync step ([#3620353](https://www.drupal.org/i/3620353)).
- Move Search after Varbase Content Base in `recipe.yml`, so the search index is built against content
  that already exists ([#3620223](https://www.drupal.org/i/3620223)).
- Complete the Varbase Patches wiring that shipped only partly in 1.0.0-alpha1
  ([#3614681](https://www.drupal.org/i/3614681)), then move it back out: `vardot/varbase-patches` and the
  Drupal CMS wiring script belong to the project template, not to a site template recipe, so the recipe no
  longer carries either ([#3618245](https://www.drupal.org/i/3618245)).
- Add quick smoke checks to the Drupal CMS install job, so the Varbase functional testing suite runs
  against the Drupal CMS install in CI ([#3618301](https://www.drupal.org/i/3618301)).
- Pin every cross-dependency to its own published pre-release rather than `1.0.x-dev`: the sixteen
  `varbase_*_base` recipes and `drupal/vartheme_bs5_horizonaid` (`~1.0.0-alpha4`). A pre-release sorts
  below its own release, so each constraint names its own pre-release rather than using `~1.0.0`.
- Update the version badge and the Composer install command to `1.0.0-alpha2` in `README.md`.
### Fixed
- Pin the header SDC and block component versions to `active`, as a hard-coded hash 500s on every
  request once the component changes ([#3620437](https://www.drupal.org/i/3620437)).
- Remove the Varbase Dev Base requirement, as the recipe is never applied by this site template
  ([#3620330](https://www.drupal.org/i/3620330)).
- Remove the Varbase API Base requirement and drop the swagger-ui library assertion that the removed
  requirement satisfied ([#3620725](https://www.drupal.org/i/3620725)).

## [1.0.0-alpha1] - 2026-08-17
### Added
- Initial release of the Horizon Aid site template: a Drupal CMS site template recipe for NGOs,
  nonprofits and humanitarian/aid organizations, built the Varbase recipe-first way. It installs from
  the site-template step of the Drupal installer and ships the Horizon Aid brand assets, the recipe
  logo and the installer screenshot.
- Country, Program and Event content types with their listings, exposed filters, pagers, card view
  modes and Drupal Canvas full-page layouts, plus all twelve countries as demo content.
- Home page sections fed from views rather than hand-placed cards, a Resources listing with its
  filters and pager, and the Latest Updates, Latest News, More Events and See Other Countries rails.
- Global header and footer regions built in Drupal Canvas to the design, including the header search
  toggle, the Quicklinks footer menu and the breadcrumb on every non-home page.
- A header search toggle that reveals the search form as an inline bar, with search index view modes
  and displays for the content types and taxonomy terms, and a readable results page.
- The Varbase functional testing suite covering every shipped section, on the shared fast CI.
### Changed
- Pin every cross-dependency to a real released constraint: the eighteen `varbase_*_base` recipes and
  the `drupal/vartheme_bs5_horizonaid` theme (`~1.0.0-rc1`, `~1.0.0-alpha2`). A pre-release sorts
  below its own release, so each constraint names its own pre-release rather than using `~1.0.0`.
- Place the header search toggle as an inline bar (`panel: bar`) that stays expanded in the Drupal
  Canvas editor, and resolve its component version against the re-synced theme component.
- Follow the inline bar's own behaviour in the Varbase functional testing suite: the bar takes the
  toggle button's place while open and carries its own close control, and it deliberately hides the
  exposed form's submit button, so the suite closes the bar with that close control and sends the
  query with Enter in the field.
- Update the version badge to `1.0.0-alpha1` in `README.md`.

[Unreleased]: https://git.drupalcode.org/project/horizonaid/-/compare/1.0.2...1.0.x
[1.0.2]: https://git.drupalcode.org/project/horizonaid/-/compare/1.0.1...1.0.2
[1.0.0-beta1]: https://git.drupalcode.org/project/horizonaid/-/compare/1.0.0-alpha2...1.0.0-beta1
[1.0.0-alpha2]: https://git.drupalcode.org/project/horizonaid/-/compare/1.0.0-alpha1...1.0.0-alpha2
[1.0.0-alpha1]: https://git.drupalcode.org/project/horizonaid/-/tags/1.0.0-alpha1
