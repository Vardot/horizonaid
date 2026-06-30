[![Varbase](https://raw.githubusercontent.com/Vardot/varbase/11.0.x/images/varbase-logo.png)](https://www.drupal.org/project/varbase)

# Horizon Aid
[![pipeline status](https://git.drupalcode.org/project/horizonaid/badges/1.0.x/pipeline.svg)](https://git.drupalcode.org/project/horizonaid/-/pipelines)
[![Horizon Aid](https://img.shields.io/badge/Horizon%20Aid-1.0.x--dev-0d6efc?labelColor=001d38&style=flat-square)](https://www.drupal.org/project/horizonaid)

A Drupal CMS site template recipe for NGOs, nonprofits and humanitarian/aid organizations, built the Varbase recipe-first way.

## Requirement

After creating a **Varbase 11** or a **Drupal CMS** project with DDEV, require Horizon Aid and apply the recipe:

```bash
ddev composer require drupal/horizonaid:1.0.x-dev
ddev drush recipe ../recipes/contrib/horizonaid
ddev drush cache:rebuild
```

The recipe assembles a complete site through the Drupal Recipe Installer Kit and ships the [vartheme_bs5_horizonaid](https://www.drupal.org/project/vartheme_bs5_horizonaid) Bootstrap 5 front-end theme.

## Learn More

- [Issue #3607228](https://www.drupal.org/project/horizonaid/issues/3607228)
- [Drupal Recipes](https://www.drupal.org/docs/extending-drupal/drupal-recipes)
- [Varbase Starter](https://www.drupal.org/project/varbase_starter)
