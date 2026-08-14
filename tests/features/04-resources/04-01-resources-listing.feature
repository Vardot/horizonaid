@any @regression @content @resources
Feature: Resources - Resources listing - Cards, pager and exposed filters
      As a site visitor
      I want a Resources listing at /resources with cards and filters
      So that I can browse the stories, reports and briefs Horizon Aid publishes.

  # The Horizon Aid recipe ships its long-form content as Blog nodes aliased
  # under /resources. The listing is a Canvas page: a "Latest Updates" section
  # heading, the Blog view's "all" display, and an exposed filter block above it.
  # Naming real resource titles is what proves the view rendered rows rather than
  # an empty container - the heading alone renders even with zero results.
  @check @acceptance @fast @local @development @resources
  Scenario: Check the resources listing shows resource cards under the Latest Updates heading
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
     Then "h1" should have text "Resources"
      And I should see "Latest Updates"
      And I should see "Clinic networks in dense settlements"
      And I should see "Community-led reconstruction"
      And I should see "Winterisation reaches frontline households"
      And I should not see "The website encountered an unexpected error"

  # Each card is a Bootstrap stretched-link: an empty anchor covering the card,
  # so it carries the alias but no visible text of its own. The href is the real
  # contract between the listing and the article, so assert the anchor is in the
  # DOM pointing at the article's own alias. 04-02 then opens those aliases and
  # proves the articles answer with the titles named here.
  @check @regression @fast @local @development @resources
  Scenario: Verify every resource card links to the article it names
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
     Then "a[href='/resources/clinic-networks-dense-settlements']" should be attached within 10 seconds
      And "a[href='/resources/community-led-reconstruction']" should be attached
      And "a[href='/resources/winterisation-reaches-frontline-households']" should be attached

  # The listing pages 12 at a time. The page RANGE is pager configuration, not
  # content, so "1-12" is stable while the total behind it is not - hence the
  # \d+ for the total. A listing that lost its pager, or one that stopped
  # limiting the page, fails here.
  @check @smoke @fast @local @development @staging @production @resources
  Scenario: Check the resources listing summarises the page it shows and offers a pager
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
     Then I should see text matching "Showing 1-12 of \d+"
      And I see visible pagination

  # The exposed block carries three filters. Assert the visitor-facing labels AND
  # the empty option each select opens on ("Search Program", "Select type"), so a
  # relabelled or dropped filter fails by name instead of leaving the listing
  # silently impossible to filter.
  @check @regression @fast @local @development @staging @production @resources
  Scenario: Check the resources listing exposes the keyword, Program and Type filters
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
     Then I see visible exposed filters form
      And I should see "Search Keyword"
      And I should see "Program"
      And I should see "Type"
      And I should see "Search Program"
      And I should see "Select type"
      And the "Apply Filters" button should be visible

  # The keyword field must be reachable by its own label and say what it wants,
  # since the label and the placeholder are all a visitor has to go on.
  @check @regression @fast @local @development @staging @production @resources
  Scenario: Verify the keyword field is labelled and prompts the visitor
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
     Then "input[name='search']" should be editable
      And "input[name='search']" should have attribute "placeholder" with value "Search keywords"

  # The listing carries its page landmarks and one first-level heading, which is what
  # screen-reader and search-engine navigation both rely on.
  @check @regression @fast @a11y @local @development @staging @production @resources
  Scenario: Check the resources listing carries its landmarks and a single first-level heading
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
     Then the page should have a main landmark
      And the page should have a navigation landmark
      And the page should have exactly one h1
      And the link "Resources" with the href "/resources" should exist
