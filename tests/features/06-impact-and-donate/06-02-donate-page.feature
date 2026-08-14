@any @regression @content @impact @donate
Feature: Impact and Donate - Donate page - The site-wide donate call to action
      As a visitor who has decided to give
      I want the Donate call to action to be reachable from anywhere and to land on a real page
      So that my intent to donate is never lost.

  # Donate is the one page in an aid template that carries revenue, and the
  # header call to action is the only navigation item the theme styles to stand
  # out (nav-link--cta). Two things can break it independently: the menu link,
  # and the page it points at. Both are asserted here, and the call to action is
  # asserted by following it rather than by reading its markup, because a link
  # with the right href sitting under an overlay is still a lost donation.
  #
  # What is deliberately NOT asserted: a donation form. The Canvas page the
  # 1.0.x recipe ships today is a banner, a heading and one paragraph. There is
  # no webform, no amount picker and no payment step on it. Writing form
  # scenarios now would mean testing a feature nobody has built, and a scenario
  # asserting the ABSENCE of a form would only ossify the gap. When the donation
  # form lands, its scenarios belong here beside these.

  @check @critical @acceptance @slow @local @development @staging @production @donate
  Scenario: Check the Donate page renders its heading and its invitation
    Given I am an anonymous user
     When I go to "/donate"
      And I wait until the page is loaded
     Then I should see "Donate" in the "main" element
      And I should see "For over two decades"
      And I should see "communities too often overlooked"
      And "nav[aria-label='breadcrumb']" should be visible within 10 seconds
      And I should not see "The website encountered an unexpected error"
      And I should not see "Page not found"

  # The header call to action is the site-wide donate path. Following it proves
  # the menu link, the alias and the page in one scenario.
  @check @critical @acceptance @slow @local @development @staging @production @donate
  Scenario: Verify the header donate call to action takes a visitor to the Donate page
    Given I am an anonymous user
     When I go to "/impact"
      And I wait until the page is loaded
     Then the link "Donate" with the href "/donate" within the element "header[role='banner']" should exist
     When I click on the element "header[role='banner'] a.nav-link--cta"
      And I wait until the page is loaded
     Then the path should be "/donate"
      And I should see "Donate" in the "main" element

  # The donate call to action is only useful if it is on every page a visitor
  # might be reading when they decide to give, so the link is asserted inside
  # the header region of each shipped section rather than once on the home page.
  @check @regression @local @development @staging @production @donate
  Scenario Outline: Check the donate call to action is in the header on the <name> page
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the link "Donate" with the href "/donate" within the element "header[role='banner']" should exist

    Examples: Shipped sections
      | name      | path       |
      | home      | /          |
      | about     | /about     |
      | countries | /countries |
      | programs  | /programs  |
      | resources | /resources |
      | events    | /events    |
      | impact    | /impact    |

  # The banner image is the whole visual weight of the page. A missing
  # derivative leaves a blank band above the ask, and the alt text is what a
  # screen-reader donor hears in its place.
  @check @regression @fast @local @development @staging @production @donate
  Scenario: Check the Donate page banner image renders with alternative text
    Given I am an anonymous user
     When I go to "/donate"
      And I wait until the page is loaded
     Then "main img" should be visible within 10 seconds
      And every image should have an alt attribute

  # Mobile is where most campaign traffic arrives. The call to action has to
  # survive the collapsed navbar: a donate link that only exists in the desktop
  # menu is a donation lost on a phone.
  @check @exploratory @slow @local @development @staging @production @donate
  Scenario: Verify the donate call to action survives the collapsed navigation on a phone
    Given I am an anonymous user
     When I set the viewport to the "xs" breakpoint
      And I go to "/"
      And I wait until the page is loaded
     Then the link "Donate" with the href "/donate" within the element "header[role='banner']" should exist
     When I go to "/donate"
      And I wait until the page is loaded
     Then I should see "Donate" in the "main" element
      And I should see "For over two decades"
