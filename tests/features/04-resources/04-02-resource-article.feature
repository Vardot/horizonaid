@any @regression @content @resources
Feature: Resources - Resource article - Story, share actions and related reading
      As a site visitor
      I want a resource article page with its story, share actions and related reading
      So that I can read the work Horizon Aid published and find more of it.

  # A resource full page is the one place the recipe's editorial structure shows:
  # an h1, the authored date, the sectioned body the demo content ships
  # ("Introduction", then the narrative headings), a Share block and a related
  # listing. Assert the sections by their visible headings - a Canvas full-view
  # template that regressed to an empty content region still returns HTTP 200 and
  # would pass a reachability check.
  #
  # The warm-up is not padding: the theme renders responsive images through
  # drimage_improved, which builds each derivative the first time a browser asks
  # for that width. On a fresh CI site this folder inherits no warm cache from
  # folder 01, so the hero image is primed at every breakpoint before it is
  # asserted on.
  @check @acceptance @local @development @staging @production @resources
  Scenario: Check a resource article renders its title, body sections and image
    Given I am an anonymous user
     When I warm up "/resources/clinic-networks-dense-settlements" at all testing breakpoints
      And I go to "/resources/clinic-networks-dense-settlements"
      And I wait until the page is loaded
     Then the page should have a main landmark
      And the page should have exactly one h1
      And "h1" should have text "Clinic networks in dense settlements"
      And I should see "Introduction"
      And I should see "The problem, before the work started"
      And I should see "What comes next"
      And "main img" should be visible within 10 seconds

  # The Webshare block is recipe configuration, not decoration: each network is a
  # separate link with its own accessible name, and the names are what an
  # assistive-technology user hears. A share block that lost a platform in the
  # recipe's social-platform settings fails on the missing name.
  @check @regression @fast @local @development @staging @production @resources
  Scenario: Check a resource article offers the configured share actions
    Given I am an anonymous user
     When I go to "/resources/clinic-networks-dense-settlements"
      And I wait until the page is loaded
     Then I should see "Share"
      And the "Share on Facebook (opens in a new tab)" link should be visible
      And the "Share on LinkedIn (opens in a new tab)" link should be visible
      And the "Share on X (opens in a new tab)" link should be visible
      And the "Share on Instagram (opens in a new tab)" link should be visible

  # An article has to lead back to its section and on to the next read, or every
  # visitor who lands from search is a dead end. The breadcrumb comes from the
  # alias pattern and the related block from the Blog view's "latest" display, so
  # this covers both.
  @check @regression @fast @local @development @staging @production @resources
  Scenario: Verify a resource article leads back to Resources and on to related reading
    Given I am an anonymous user
     When I go to "/resources/clinic-networks-dense-settlements"
      And I wait until the page is loaded
     Then "Home" should be in the breadcrumb
      And "Resources" should be in the breadcrumb
      And the link "Resources" with the href "/resources" should exist
      And I should see "Latest News"
      And I should see "Join Our Mission"

  # One row per shipped alias, so a resource whose alias, title or render
  # pipeline breaks when the recipe is re-applied fails its own named row
  # instead of hiding behind a single sample article. Each row pairs the title it
  # must show with the two failure pages it must not be.
  @check @smoke @fast @local @development @staging @production @resources
  Scenario Outline: Check the <title> article renders for an anonymous visitor
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then "h1" should have text "<title>"
      And I should see "Share"
      And I should not see "The website encountered an unexpected error"
      And I should not see "Page not found"

    Examples: Shipped resource articles
      | path                                                   | title                                      |
      | /resources/clinic-networks-dense-settlements            | Clinic networks in dense settlements       |
      | /resources/community-led-reconstruction                 | Community-led reconstruction               |
      | /resources/winterisation-reaches-frontline-households   | Winterisation reaches frontline households |
      | /resources/emergency-relief-flooded-states              | Emergency relief in flooded states         |
