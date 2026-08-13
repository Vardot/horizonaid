Feature: Website Base Requirements - Responsive navigation - Header collapse and listings at small viewports
      As a site visitor on a phone
      I want the main navigation and the listings to work at a small viewport
      So that I can reach every section without a desktop browser.

  # Nothing else in the suite runs at a small viewport, so a menu that collapses
  # behind a toggle nobody can open, or a listing whose cards only render above a
  # breakpoint, would ship unnoticed.
  #
  # The Horizon Aid header is a Bootstrap `navbar-expand-lg`, so the main menu
  # collapses behind a toggle below the lg breakpoint. Both halves are asserted:
  # at a phone width the toggle is the way in and the menu starts collapsed, at a
  # desktop width the menu is laid out and the toggle is gone. A collapse that
  # never collapses and one that never expands both fail.
  #
  # The collapsed state is asserted on the `.navbar-collapse` container rather
  # than on a menu link, because the footer repeats the same section names at
  # every width, so a page-wide link check would never see the menu as closed.
  #
  # Selectors are written as CSS here rather than by the names in
  # tests/selectors/horizonaid-theme.json: the quoted-string visibility steps
  # take a raw selector, and a name in that position is read as a CSS descendant
  # combinator, which silently matches nothing. Clicking a CSS target needs
  # "I click on the element" too: the shorter `I click "X" by attr` matches an
  # element's value/placeholder/aria-label/title, not a selector.

  @check @critical @exploratory @fast @local @development @staging @production @navigation
  Scenario: Check the main menu sits behind a navigation toggle on a phone
    Given I am an anonymous user
     When I set the viewport to the "xs" breakpoint
      And I go to "/"
      And I wait until the page is loaded
     Then "header[role='banner'] button.navbar-toggler" should be visible
      And "header[role='banner'] .navbar-collapse" should not be visible

  @check @critical @exploratory @fast @local @development @staging @production @navigation
  Scenario: Verify the navigation toggle opens the main menu on a phone
    Given I am an anonymous user
     When I set the viewport to the "xs" breakpoint
      And I go to "/"
      And I wait until the page is loaded
     Then "header[role='banner'] .navbar-collapse" should not be visible
     When I click on the element "header[role='banner'] button.navbar-toggler"
      # A budget, not a sleep: the collapse animates open, and the web-first
      # assertion polls until it is laid out.
     Then "header[role='banner'] .navbar-collapse" should be visible within 5 seconds
      And I should see "Countries"
      And I should see "Programs"
      And I should see "Donate"

  @check @critical @regression @fast @local @development @staging @production @navigation
  Scenario: Check the main menu is laid out and needs no toggle on a desktop
    Given I am an anonymous user
     When I set the viewport to the "xl" breakpoint
      And I go to "/"
      And I wait until the page is loaded
     Then "header[role='banner'] .navbar-collapse" should be visible
      And "header[role='banner'] button.navbar-toggler" should not be visible
      And I should see "Countries"

  # Each listing must still render its content at a phone width: the grid
  # reflows, it does not drop items. A marker title proves the cards rendered,
  # rather than a count, which shifts while the editorial scenarios add and
  # remove content in the same run.
  @check @exploratory @fast @local @development @navigation
  Scenario Outline: Check the <name> listing renders its content on a phone
    Given I am an anonymous user
     When I set the viewport to the "xs" breakpoint
      And I go to "<path>"
      And I wait until the page is loaded
     Then I should see "<marker>"
      And I should not see "The website encountered an unexpected error"

    Examples:
      | name      | path       | marker      |
      | Countries | /countries | Afghanistan |
      | Programs  | /programs  | Education   |
      | Resources | /resources | Resources   |
      | Events    | /events    | Events      |

  # The breadcrumb is the only way back up from a node page on a phone, where the
  # main menu starts collapsed.
  @check @exploratory @fast @local @development @staging @production @navigation
  Scenario: Check a country page keeps its breadcrumb trail on a phone
    Given I am an anonymous user
     When I set the viewport to the "xs" breakpoint
      And I go to "/countries/afghanistan"
      And I wait until the page is loaded
     Then "nav[aria-label='breadcrumb']" should be visible
      And I should see "Afghanistan"
