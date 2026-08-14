@any @regression @content @events
Feature: Events - Events listing - Cards, pager and exposed filters
      As a site visitor
      I want an Events listing at /events with cards, a summary and filters
      So that I can see what Horizon Aid is running and narrow it down.

  # The Events listing is a Canvas page carrying the Events view's block_1
  # display under an "Upcoming Events" heading, with an exposed filter block.
  # Naming real events is what proves rows rendered: the section heading and the
  # filter form both render over an empty view.
  @check @acceptance @fast @local @development @events
  Scenario: Check the events listing shows event cards under the Upcoming Events heading
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
     Then "h1" should have text "Events"
      And I should see "Upcoming Events"
      And I should see "Water access in crisis zones"
      And I should see "Impact reporting transparency talk"
      And I should not see "The website encountered an unexpected error"

  # Each card is a Bootstrap stretched-link: an empty anchor covering the card, so
  # it carries the alias but no visible text of its own. The href is the contract
  # between the listing and the event page, and 05-02 opens those aliases and
  # proves the pages answer with the titles named here.
  @check @regression @fast @local @development @events
  Scenario: Verify every event card links to the event it names
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
     Then "a[href='/events/water-access-crisis-zones']" should be attached within 10 seconds
      And "a[href='/events/impact-reporting-transparency-talk']" should be attached
      And "a[href='/events/annual-fundraising-gala']" should be attached

  # The listing shows 9 events per page and summarises the range it is on. The
  # range is pager configuration, not content, so "1-9" holds whatever the total
  # behind it is - hence \d+ for the total, which other work on the same site
  # changes underneath us.
  @check @smoke @fast @local @development @staging @production @events
  Scenario: Check the events listing summarises the page it shows and offers a pager
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
     Then I should see text matching "Showing 1-9 of \d+"
      And I see visible pagination

  # The events exposed block carries a keyword filter plus the two event
  # taxonomies. Assert the visitor-facing labels AND the empty option each select
  # opens on, so a filter dropped from the view fails by name rather than leaving
  # the listing quietly impossible to filter.
  @check @regression @fast @local @development @staging @production @events
  Scenario: Check the events listing exposes the keyword, Type and Topic filters
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
     Then I see visible exposed filters form
      And I should see "Search Keyword"
      And I should see "Type"
      And I should see "Topic"
      And I should see "Select Type"
      And I should see "Search Topic"
      And the "Apply Filters" button should be visible
      And the "Reset" button should be visible

  @check @regression @fast @local @development @staging @production @events
  Scenario: Verify the keyword field is labelled and prompts the visitor
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
     Then "input[name='search']" should be editable
      And "input[name='search']" should have attribute "placeholder" with value "Search Keyword"

  @check @regression @fast @a11y @local @development @staging @production @events
  Scenario: Check the events listing carries its landmarks and a single first-level heading
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
     Then the page should have a main landmark
      And the page should have a navigation landmark
      And the page should have exactly one h1
      And the link "Events" with the href "/events" should exist
