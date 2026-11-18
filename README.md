<img src="logo.png" alt="Horizon Aid" width="96">

# Horizon Aid
[![pipeline status](https://git.drupalcode.org/project/horizonaid/badges/1.0.x/pipeline.svg)](https://git.drupalcode.org/project/horizonaid/-/pipelines)
[![Horizon Aid](https://img.shields.io/badge/Horizon%20Aid-1.0.x--dev-0d6efc?labelColor=001d38&style=flat-square)](https://www.drupal.org/project/horizonaid)

A Drupal CMS site template recipe for NGOs, nonprofits and humanitarian/aid organizations, built the Varbase recipe-first way.

## Install with Composer

To install the most recent release of Varbase 11.0.x, run this command:

```bash
composer create-project drupal/varbase_project:~11.0.0 PROJECT_DIR_NAME --no-dev --no-interaction
```

Then require the recipe and apply it with DDEV:

```bash
ddev composer require drupal/horizonaid:~1.0.0
ddev drush recipe ../recipes/contrib/horizonaid
ddev drush cache:rebuild
```

## Search

Search comes from [Varbase Search Base](https://www.drupal.org/project/varbase_search_base). The
results page at `/search` is a Canvas page with a keyword box, a filter rail (Category, Content
Type, Date Published) and the results as cards. Category combines the resource and event
categories.

## Brand kit

Change the site's colours in **Canvas > Brand kit**, no code needed. The palette is Bootstrap's own
colour variables with this theme's values: the eight theme colours (Primary to Dark) plus body text
and background, emphasis, secondary and tertiary text and backgrounds, headings, link and link hover,
border, code and highlight, plus Bootstrap's named colours (Blue to Gray dark). Editing one restyles the whole site: buttons, links, bands, tints, forms.

Canvas global CSS (`canvas.asset_library.global`) derives the colours Bootstrap compiles as literals
(tints, focus ring, button states, utilities); keep it when you add your own global CSS. Content
editors and content admins have the `administer brand kit` permission. The theme loads the brand kit
CSS after its own, so these colours win over its defaults.

## Telemetry

Drupal CMS telemetry is off in this project's CI (`DRUPAL_CMS_TELEMETRY=0`). To keep it off on your own install, set `DRUPAL_CMS_TELEMETRY=0` in the environment before installing the site template.

## Learn More

- [Issue #3607228](https://www.drupal.org/project/horizonaid/issues/3607228)
- [Varbase Search Base](https://www.drupal.org/project/varbase_search_base)
- [Drupal Recipes](https://www.drupal.org/docs/extending-drupal/drupal-recipes)
- [Varbase Starter](https://www.drupal.org/project/varbase_starter)
