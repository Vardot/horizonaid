@any @regression @content @events @exploratory
Feature: Events - Filtering and paging - Keyword, Type and Topic over the listing
      As a site visitor
      I want to narrow the Events listing with its filters and page through the rest
      So that I can find the event I would actually attend.

  # 05-01 proves the filters are on the page. These scenarios prove they filter,
  # driven through the form a visitor uses: fill or select, press Apply Filters,
  # then check what the listing kept AND what it dropped. A filter that stopped
  # filtering returns everything and would pass a positive-only assertion, so
  # every scenario here pairs the two.
  #
  # No result total and no page count is asserted anywhere: content on a shared
  # test site changes while the suite runs, and a pinned total goes red on someone
  # else's edit rather than on a defect. Page RANGES ("1-9", "10-...") are pager
  # configuration and stay true whatever the total is.
  #
  # The taxonomy filters are targeted by their view identifiers
  # (event_categories, event_topics) rather than their labels: a single-word
  # target resolves through the name attribute, and the identifiers are recipe
  # configuration, so they hold across a relabelled or restyled form.

  @check @acceptance @fast @local @development @events
  Scenario: Check a keyword typed into the form narrows the events listing
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
     Then I should see "Digital security for advocacy groups"
     When I fill in "Search Keyword" with "winterisation"
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then the url should match "search=winterisation"
      And I should see "Winterisation readiness briefing"
      And I should not see "Digital security for advocacy groups"
      And I should not see "Annual fundraising gala"

  # A keyword nobody scheduled must empty the listing rather than fall back to
  # showing everything - and with nothing to page, the pager must go too.
  @check @exploratory @fast @local @development @events
  Scenario: Check a keyword that matches nothing empties the events listing
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
     When I fill in "Search Keyword" with "telescope"
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then I should not see "Digital security for advocacy groups"
      And I should not see "Winterisation readiness briefing"
      And I don't see pagination

  # The Type filter is the Event Categories taxonomy: the format of the event.
  # Choosing Briefing must keep the briefings and drop a summit.
  @check @acceptance @fast @local @development @events
  Scenario: Check choosing a Type narrows the events listing to that format
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
     Then I should see "Grassroots leadership summit"
     When I select "Briefing" from "event_categories"
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then the url should match "event_categories=\d+"
      And I should see "Winterisation readiness briefing"
      And I should not see "Grassroots leadership summit"

  # The Topic filter is the Event Topics taxonomy: the sector the event is about.
  # Health must keep the health events and drop the shelter one.
  @check @acceptance @fast @local @development @events
  Scenario: Check choosing a Topic narrows the events listing to that sector
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
     When I select "Health" from "event_topics"
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then the url should match "event_topics=\d+"
      And I should see "Mobile health outreach clinic day"
      And I should not see "Winterisation readiness briefing"
      And I should not see "Grassroots leadership summit"

  # Two filters at once must intersect rather than replace one another - the usual
  # regression when an exposed filter is rebuilt.
  @check @acceptance @fast @local @development @events
  Scenario: Verify a Type and a Topic filter apply together
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
      And I select "Briefing" from "event_categories"
      And I select "Shelter" from "event_topics"
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then I should see "Winterisation readiness briefing"
      And I should see "Emergency shelter standards review"
      And I should not see "Food security outlook roundtable"

  # Reset has to put the visitor back on the whole listing, otherwise anyone who
  # mis-filters is stranded on an empty page. This is the recovery path the
  # Resources listing currently lacks (see 04-03).
  @check @exploratory @fast @local @development @events
  Scenario: Check Reset clears an applied filter and restores the full events listing
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
      And I fill in "Search Keyword" with "telescope"
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then I should not see "Digital security for advocacy groups"
     When I click the "Reset" button
      And I wait until the page is loaded
     Then "input[name='search']" should have value ""
      And I should see "Digital security for advocacy groups"
      And I should see text matching "Showing 1-9 of \d+"

  # Leaving the form untouched must not filter anything away: a listing that
  # narrows on an empty Apply is as broken as one that never narrows.
  @check @exploratory @fast @local @development @events
  Scenario: Verify applying an empty form leaves the events listing whole
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then I should see text matching "Showing 1-9 of \d+"
      And I should see "Digital security for advocacy groups"
      And I should see "Water access in crisis zones"

  # Paging is proved by what changes, not by how many pages exist. The second page
  # moves the range on and carries events the first page does not, so a pager that
  # renders but always serves page one fails here.
  @check @acceptance @fast @local @development @events
  Scenario: Check paging the events listing serves different events on the second page
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
     Then I see visible pagination
      And I should not see "Winterisation readiness briefing"
     When I click on the link with the title "Go to page 2"
      And I wait until the page is loaded
     Then the url should match "page=1"
      And I should see text matching "Showing 10-\d+ of \d+"
      And I should see "Winterisation readiness briefing"
      And "a[href='/events/winterisation-readiness-briefing']" should be attached within 10 seconds
      And I should not see "Digital security for advocacy groups"

  # Paging back has to work as well as paging forward, and the first page must
  # come back as it was.
  @check @exploratory @fast @local @development @events
  Scenario: Verify paging back returns to the first page of events
    Given I am an anonymous user
     When I go to "/events"
      And I wait until the page is loaded
      And I click on the link with the title "Go to page 2"
      And I wait until the page is loaded
     Then I should see "Winterisation readiness briefing"
     When I click on the link with the title "Go to previous page"
      And I wait until the page is loaded
     Then I should see text matching "Showing 1-9 of \d+"
      And I should see "Digital security for advocacy groups"
      And I should not see "Winterisation readiness briefing"
