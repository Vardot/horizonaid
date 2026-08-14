@any @regression @smoke
Feature: Website Base Requirements - Main navigation and footer
      As a site visitor
      I want the main navigation and footer to name and reach every section
      So that I can move around the site without guessing at URLs.

  # Each item is asserted as a link with an href inside the header landmark, not
  # as page text: "Programs" appears in body copy on several pages, and a
  # heading is not a way to navigate. A menu link lost when the recipe is
  # re-applied fails its own named row.

  @check @smoke @fast @local @development @staging @production @navigation
  Scenario Outline: The main navigation links to the <name> section
    Given I am an anonymous user
     When I go to "/"
      And I wait until the page is loaded
     Then the link "<name>" with the href "<path>" within the element "header[role='banner']" should exist

    Examples: Main menu
      | name      | path       |
      | About     | /about     |
      | Resources | /resources |
      | Programs  | /programs  |
      | Events    | /events    |
      | Countries | /countries |
      | Donate    | /donate    |

  # The header navigation is global: it is rendered from the Canvas Header
  # region, so it must be the same on an interior page as on the home page.
  @check @smoke @fast @local @development @staging @production @navigation
  Scenario: The main navigation is the same on an interior page
    Given I am an anonymous user
     When I go to "/about"
      And I wait until the page is loaded
     Then the link "Programs" with the href "/programs" within the element "header[role='banner']" should exist
      And the link "Events" with the href "/events" within the element "header[role='banner']" should exist
      And the link "Donate" with the href "/donate" within the element "header[role='banner']" should exist

  # The social profiles are icon links, so their accessible names are the only
  # thing a screen reader (or this test) can identify them by.
  @check @regression @fast @local @development @staging @production @navigation
  Scenario: The footer links the organization's social profiles
    Given I am an anonymous user
     When I go to "/"
      And I wait until the page is loaded
     Then the "Linkedin" link should be visible
      And the "Facebook" link should be visible
      And the "Instagram" link should be visible
      And the "X-Twitter" link should be visible
