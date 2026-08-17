<img src="logo.png" alt="Horizon Aid" width="96">

# Horizon Aid
[![pipeline status](https://git.drupalcode.org/project/horizonaid/badges/1.0.x/pipeline.svg)](https://git.drupalcode.org/project/horizonaid/-/pipelines)
[![Horizon Aid](https://img.shields.io/badge/Horizon%20Aid-1.0.0--alpha1-0d6efc?labelColor=001d38&style=flat-square)](https://www.drupal.org/project/horizonaid)

A Drupal CMS site template recipe for NGOs, nonprofits and humanitarian/aid organizations, built the Varbase recipe-first way.

## Install with Composer

To install the most recent release of Varbase 11.0.x, run this command:

```bash
composer create-project drupal/varbase_project:~11.0.0 PROJECT_DIR_NAME --no-dev --no-interaction
```

Then require the recipe and apply it with DDEV:

```bash
ddev composer require drupal/horizonaid:1.0.x-dev
ddev drush recipe ../recipes/contrib/horizonaid
ddev drush cache:rebuild
```


## Learn More

- [Issue #3607228](https://www.drupal.org/project/horizonaid/issues/3607228)
- [Drupal Recipes](https://www.drupal.org/docs/extending-drupal/drupal-recipes)
- [Varbase Starter](https://www.drupal.org/project/varbase_starter)
