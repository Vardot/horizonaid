@any @regression @perf
Feature: Quality - Performance - Page load budgets on the Horizon Aid pages
      As a site owner
      I want every Horizon Aid page to load within a budget
      So that a regression in page weight, image derivatives or query count is caught the day it lands.

  # Horizon Aid pages are image-led: hero banners, country cards, programme cards
  # and resource cards all render responsive derivatives, and each Canvas page
  # composes many components. That is where weight creeps in unnoticed.
  #
  # The budget is measured with Navigation Timing (navigationStart to
  # loadEventEnd) by the core `should load in less than` step.
  #
  # Cold cache is the thing that makes a naive budget lie. The theme renders
  # responsive images through drimage_improved, which builds each WebP derivative
  # ON DEMAND the first time a browser asks for it at a given rendered width; a
  # request for a derivative that has never been built returns 404 until
  # /drimage/{width}/{height}/{fid}/... has been hit once. In CI every matrix job
  # installs its own site, so this folder inherits no warm-up from folder 01 and
  # a first visit pays for generating everything it needs.
  #
  # Two budgets, therefore, and each scenario says which one it is measuring:
  #
  #   - First visit, 20 seconds. Generous on purpose: it covers one-off
  #     derivative generation on a fresh install. It still catches the failure
  #     that matters at this tier, a page that never finishes.
  #
  #   - Repeat visit, 8 seconds. Every derivative exists and every render cache is
  #     built, so this is the number a real visitor sees and the one that should
  #     stay flat release to release. Each scenario warms its own page with a
  #     first navigation and measures the reload, which makes it independent of
  #     run order and of whatever other folders did before it.
  #
  # Measured on this DDEV box on 12 August 2026: 0.07s to 0.4s warm, up to 1.6s
  # cold, with the two view-driven pages (/countries, /programs) the slowest. Both
  # budgets are therefore multiples of the worst real number, which is what makes
  # them regression alarms rather than flake generators. A tight budget on a box
  # shared with other test runs fails on a neighbour's load, and a suite that
  # cries wolf gets muted.
  #
  # The `warm up "<path>" at all testing breakpoints` step is deliberately not
  # used here: it visits a page once per configured breakpoint (seven of them),
  # and on a cold site that exceeds the 45 second per-step ceiling varbase-e2e
  # sets, so it fails as a timeout rather than warming anything. Self-warming
  # inside each scenario costs one extra navigation and cannot time out.

  @check @perf @regression @local @development @staging @production
  Scenario Outline: Check the <name> page loads within the repeat-visit budget
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
      And I reload the page
      And I wait until the page is loaded
     Then the page should load in less than 8 seconds
      And I should see "<text>"

    Examples: Canvas pages
      | name   | path     | text                             |
      | Home   | /        | Donate                           |
      | About  | /about   | About                            |
      | Impact | /impact  | Lives Protected                  |
      | Donate | /donate  | For over two decades             |

    Examples: Section pages that embed a listing view
      | name      | path       | text      |
      | Countries | /countries | Countries |
      | Programs  | /programs  | Programs  |
      | Resources | /resources | Resources |
      | Events    | /events    | Events    |

  # The first visit on a fresh install. The positive content assertion is what
  # stops a fast error page passing as a fast page.
  @check @perf @acceptance @local @development @staging @production
  Scenario Outline: Check the <name> page first visit stays within the cold-cache budget
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the page should load in less than 20 seconds
      And I should see "<text>"

    Examples:
      | name      | path       | text                 |
      | Home      | /          | Donate               |
      | Countries | /countries | Countries            |
      | Programs  | /programs  | Programs             |
      | Impact    | /impact    | Lives Protected      |
      | Donate    | /donate    | For over two decades |

  # A phone viewport asks the theme for the smallest derivatives, which are a
  # different set of files from the desktop ones, so a mobile regression can hide
  # behind a healthy desktop number. Mobile is where most aid-campaign traffic
  # lands, so it gets its own rows rather than an assumption.
  # Speed tags in this feature: measured twice on this box, and only one row earns
  # one. /impact on a phone took 45.4s and 41.0s of wall time (the budget itself
  # passes; the cost is generating the phone-width derivatives), so it is @slow.
  # Nothing here is @fast: the fastest rows land at 3.3s to 5.7s across the two
  # runs, straddling the 5 second line, and a budget scenario that only looks
  # fast because a previous navigation warmed the cache should not advertise a
  # speed it cannot keep on a fresh install. Everything unlabelled is the 5-30s
  # middle band by measurement, not by omission.
  @check @perf @exploratory @local @development @staging @production
  Scenario Outline: Check the <name> page loads within the repeat-visit budget on a phone
    Given I am an anonymous user
     When I set the viewport to the "xs" breakpoint
      And I go to "<path>"
      And I wait until the page is loaded
      And I reload the page
      And I wait until the page is loaded
     Then the page should load in less than 8 seconds
      And I should see "<text>"

    Examples:
      | name   | path     | text                 |
      | Home   | /        | Donate               |
      | Donate | /donate  | For over two decades |

    @slow
    Examples: The page whose phone-width derivatives cost the most to build
      | name   | path     | text                 |
      | Impact | /impact  | Lives Protected      |
