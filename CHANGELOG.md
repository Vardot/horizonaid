# Changelog

All notable changes to the Horizon Aid site template recipe are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://git.drupalcode.org/project/horizonaid/-/compare/1.0.0-alpha1...1.0.x
[1.0.0-alpha1]: https://git.drupalcode.org/project/horizonaid/-/tags/1.0.0-alpha1
