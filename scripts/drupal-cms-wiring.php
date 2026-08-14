<?php

/**
 * @file
 * Wires a plain Drupal CMS project for the Horizon Aid site template.
 *
 * Adds what a stock drupal/cms codebase lacks and drupal/varbase_project ships.
 * The values live in assets/drupal-cms.composer.json and
 * assets/drupal-libraries.package.json: edit those, not this script.
 *
 * Usage, from this directory:
 *   php drupal-cms-wiring.php [--dry-run]
 */

// This site template. The rest of this script is identical across the Vardot
// site templates: keep them in sync.
const SITE_TEMPLATE_NAME = 'horizonaid';
const SITE_TEMPLATE_TITLE = 'Horizon Aid';
const SITE_TEMPLATE_PACKAGE = 'drupal/horizonaid';

const JSON_WRITE_FLAGS = JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE;

$dry_run = in_array('--dry-run', $argv, TRUE);

print "🚀 Wiring a Drupal CMS project for the " . SITE_TEMPLATE_TITLE . " site template...\n";
print "📋 This script adds what a stock drupal/cms codebase lacks and drupal/varbase_project ships\n";
if ($dry_run) {
  print "🧪 Dry run: nothing will be written.\n";
}

$assets_dir = __DIR__ . '/assets';
$composer_asset = $assets_dir . '/drupal-cms.composer.json';
$package_asset = $assets_dir . '/drupal-libraries.package.json';

$changed = 0;
$already = 0;

/**
 * Finds the project root: the directory holding the root composer.json.
 *
 * Works both from <root>/recipes/<template>/scripts/ and from the root itself.
 *
 * @return string|null
 *   The project root, or NULL when no root composer.json was found.
 */
function find_project_root(): ?string {
  $candidates = [dirname(__DIR__, 3), getcwd()];
  foreach ($candidates as $dir) {
    $composer = $dir . '/composer.json';
    if (!is_file($composer)) {
      continue;
    }
    $data = json_decode(file_get_contents($composer), TRUE);
    if (!is_array($data)) {
      print "  ⚠️  Could not parse {$composer}\n";
      continue;
    }
    // A root project, not the recipe's own composer.json.
    if (($data['type'] ?? '') !== 'drupal-recipe') {
      return $dir;
    }
  }
  return NULL;
}

/**
 * Reads a JSON file into an array, or returns the fallback when absent.
 */
function read_json(string $file, array $fallback): array {
  if (!is_file($file)) {
    return $fallback;
  }
  return json_decode(file_get_contents($file), TRUE) ?? $fallback;
}

/**
 * Writes an array back out as pretty-printed JSON.
 */
function write_json(string $file, array $data, bool $dry_run): void {
  if ($dry_run) {
    return;
  }
  file_put_contents($file, json_encode($data, JSON_WRITE_FLAGS) . "\n");
}

/**
 * Loads one asset file, or stops with a clear message.
 */
function load_asset(string $file): array {
  if (!is_file($file)) {
    print "❌ Missing {$file}: run this from the recipe's scripts/ directory, with its assets/ alongside.\n";
    exit(1);
  }
  return json_decode(file_get_contents($file), TRUE);
}

/**
 * Merges every leaf of $source into $target, reporting each one.
 *
 * Lists and scalars replace wholesale; maps recurse, so existing sibling keys
 * survive.
 */
function merge_into(array &$target, array $source, array $trail, int &$changed, int &$already): void {
  foreach ($source as $key => $value) {
    $label = implode('.', array_merge($trail, [$key]));
    // A map recurses; a list is a value in its own right.
    if (is_array($value) && $value !== [] && !array_is_list($value)) {
      if (!isset($target[$key]) || !is_array($target[$key])) {
        $target[$key] = [];
      }
      merge_into($target[$key], $value, array_merge($trail, [$key]), $changed, $already);
      continue;
    }
    $encoded = json_encode($value, JSON_UNESCAPED_SLASHES);
    if (array_key_exists($key, $target) && json_encode($target[$key], JSON_UNESCAPED_SLASHES) === $encoded) {
      print "  ➖ {$label}: already {$encoded}\n";
      $already++;
      continue;
    }
    $target[$key] = $value;
    print "  ✅ {$label} → {$encoded}\n";
    $changed++;
  }
}

$root = find_project_root();
if ($root === NULL) {
  print "❌ No root composer.json found. Run this from the project root, or from recipes/" . SITE_TEMPLATE_NAME . "/scripts/.\n";
  exit(1);
}
print "📁 Project root: {$root}\n";

// 1. composer.json: dev stability for the 1.0.x-dev requirements, plus the
// allow-plugins and patches allowlist varbase-patches needs to run at all.
print "\n📦 composer.json  <- assets/" . basename($composer_asset) . "\n";
$composer_file = $root . '/composer.json';
$composer = read_json($composer_file, []);
merge_into($composer, load_asset($composer_asset), [], $changed, $already);
write_json($composer_file, $composer, $dry_run);

// 2. package.json: the drupal-libraries block drupal-libraries-sync.js reads.
print "\n📦 package.json  <- assets/" . basename($package_asset) . "\n";
$package_file = $root . '/package.json';
$package = read_json($package_file, [
  'name' => SITE_TEMPLATE_NAME . '-drupalcms-project',
  'private' => TRUE,
]);
merge_into($package, load_asset($package_asset), [], $changed, $already);
write_json($package_file, $package, $dry_run);

// 3. .yarnrc.yml: Yarn 4 defaults to PnP and writes no node_modules/ for the
// sync script to copy from.
print "\n📦 .yarnrc.yml\n";
$yarnrc_file = $root . '/.yarnrc.yml';
$yarnrc = is_file($yarnrc_file) ? file_get_contents($yarnrc_file) : '';
if (preg_match('/^nodeLinker:\s*node-modules\s*$/m', $yarnrc)) {
  print "  ➖ nodeLinker: already node-modules\n";
  $already++;
}
elseif (preg_match('/^nodeLinker:/m', $yarnrc)) {
  if (!$dry_run) {
    file_put_contents($yarnrc_file, preg_replace('/^nodeLinker:.*$/m', 'nodeLinker: node-modules', $yarnrc));
  }
  print "  ✅ nodeLinker -> node-modules\n";
  $changed++;
}
else {
  $block = rtrim($yarnrc);
  $block .= $block === '' ? '' : "\n\n";
  $block .= "nodeLinker: node-modules\n\nenableScripts: true\n\nnpmMinimalAgeGate: 0\n";
  if (!$dry_run) {
    file_put_contents($yarnrc_file, $block);
  }
  print "  ✅ .yarnrc.yml written (nodeLinker, enableScripts, npmMinimalAgeGate)\n";
  $changed++;
}

// 4. The sync script itself, next to package.json where the postinstall expects
// it.
print "\n📦 scripts/drupal-libraries-sync.js\n";
$sync_source = __DIR__ . '/drupal-libraries-sync.js';
$sync_target = $root . '/scripts/drupal-libraries-sync.js';
if (!is_file($sync_source)) {
  print "  ⚠️  Not found next to this script: run this from recipes/" . SITE_TEMPLATE_NAME . "/scripts/ to install it.\n";
}
elseif (is_file($sync_target) && file_get_contents($sync_target) === file_get_contents($sync_source)) {
  print "  ➖ already in place\n";
  $already++;
}
else {
  if (!$dry_run) {
    if (!is_dir(dirname($sync_target))) {
      mkdir(dirname($sync_target), 0777, TRUE);
    }
    copy($sync_source, $sync_target);
  }
  print "  ✅ copied to scripts/drupal-libraries-sync.js\n";
  $changed++;
}

print "\n🎉 Wiring complete! {$changed} changed, {$already} already in place.\n";

print "
👉 Next, from the project root:

   composer require vardot/varbase-patches
   composer require " . SITE_TEMPLATE_PACKAGE . " -W
   corepack enable && corepack yarn install

   vardot/varbase-patches carries the curated Drupal core patches this template
   relies on - in particular the fix for core issue #2741429, without which
   drupal_cms_search's display cloning fatals during the install (see below).
   The allow-list above only permits those patches; it does not pull them in.

   -W (--with-all-dependencies) is required: a partial update keeps the locked
   symfony/css-selector, which drupal/storybook (via varbase_dev_base) conflicts
   with, and composer refuses to resolve.

Then install the site template, picking " . SITE_TEMPLATE_TITLE . " in the installer:

   drush site:install drupal_cms_installer installer_site_template_form.add_ons=" . SITE_TEMPLATE_NAME . "

Patch resolution is default-deny, and a dependency that declares a patch with a
   path relative to the project root is ignored outright (drupal/ai_context is
   one). Such a path only resolves from a root that happens to ship the file, so
   leaving it enabled aborts the require before the install begins.

ℹ️  Both install paths work once vardot/varbase-patches is required: `drush
   site:install` and picking the template in the browser installer. Skipping it
   leaves core without the fix for issue #2741429, and the install dies with
   \"getConfigDependencyName() on null\" - Drupal CMS installs layout_builder and
   drupal_cms_search clones every node view display into a search_index view
   mode that core does not ship, so the dependency lookup dereferences NULL.
";
