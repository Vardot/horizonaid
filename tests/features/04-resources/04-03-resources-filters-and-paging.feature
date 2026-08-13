Feature: Resources - Filtering and paging - Keyword, Program and Type over the listing
      As a site visitor
      I want to narrow the Resources listing with its filters and page through the rest
      So that I can find one brief instead of reading through everything published.

  # 04-01 proves the filters are on the page. These scenarios prove they filter,
  # driven through the form a visitor actually uses: fill or select, press Apply
  # Filters, then check what the listing kept AND what it dropped. A filter that
  # silently stopped filtering returns everything, which passes a positive-only
  # assertion, so every scenario here pairs the two.
  #
  # No result total and no page count is asserted anywhere. Blog content on a
  # shared test site is created and removed while the suite runs, so a pinned
  # total goes red on someone else's edit rather than on a defect. Page RANGES
  # ("1-12", "13-...") are pager configuration and stay true whatever the total.
  #
  # The filters are targeted by their view identifiers (search, program, type)
  # rather than their labels: a single-word target resolves through the name
  # attribute, and the identifiers are recipe configuration, so they hold across
  # a relabelled or restyled form.

  @check @acceptance @local @development @resources
  Scenario: Check a keyword typed into the form narrows the resources listing
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
     Then I should see "School feeding and attendance"
     When I fill in "Search Keyword" with "clinic networks"
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then the url should match "search=clinic"
      And I should see "Clinic networks in dense settlements"
      And I should not see "School feeding and attendance"
      And I should not see "Winter learning continuity"

  # A keyword nobody wrote about must empty the listing and say so, not fall back
  # to showing everything.
  @check @exploratory @local @development @resources
  # "telescope" is a real word that no shipped resource contains, checked against the
  # live listing rather than assumed: a keyboard-mash term would read as a typo and
  # every spell checker in CI would flag it.
  Scenario: Check a keyword that matches nothing empties the resources listing
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
     When I fill in "Search Keyword" with "telescope"
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then I should see "There are no blog posts yet."
      And I should not see "Clinic networks in dense settlements"
      And I should not see "School feeding and attendance"
      And I don't see pagination

  # The Program filter is the taxonomy that ties a resource to the programme it
  # reports on. Choosing Healthcare & Medicine must keep its own resources and
  # drop the education and food-security ones.
  @check @acceptance @local @development @resources
  Scenario: Check choosing a Program narrows the resources listing to that programme
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
     Then I should see "Winter learning continuity"
     When I select "Healthcare & Medicine" from "program"
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then the url should match "program=\d+"
      And I should see "Clinic networks in dense settlements"
      And I should not see "Winter learning continuity"
      And I should not see "School feeding and attendance"

  # The Type filter separates the editorial formats the template ships (News,
  # Report, Policy brief). Choosing Policy brief must leave the briefs and drop a
  # resource that is a Report.
  @check @acceptance @local @development @resources
  Scenario: Check choosing a Type narrows the resources listing to that format
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
     Then I should see "Clinic networks in dense settlements"
     When I select "Policy brief" from "type"
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then I should see "Legal aid hours and where they go"
      And I should not see "Clinic networks in dense settlements"

  # Two filters at once must intersect, not replace one another - the common
  # regression when an exposed filter is rebuilt.
  @check @acceptance @local @development @resources
  Scenario: Verify a keyword and a Program filter apply together
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
      And I fill in "Search Keyword" with "clinic"
      And I select "Healthcare & Medicine" from "program"
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then the url should match "search=clinic"
      And I should see "Clinic networks in dense settlements"
      And I should not see "Winterisation reaches frontline households"

  # Leaving the form untouched must not filter anything away: a listing that
  # narrows on an empty Apply is as broken as one that never narrows.
  @check @exploratory @local @development @resources
  Scenario: Verify applying an empty form leaves the resources listing whole
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then I should see text matching "Showing 1-12 of \d+"
      And I should see "Clinic networks in dense settlements"
      And I should see "School feeding and attendance"

  # Paging is proved by the range moving on and by the pager's own state, never by
  # which item sits on which page. Every node the recipe ships carries the same
  # created timestamp and this listing sorts on sticky then created with no
  # tiebreaker, so the database is free to order tied rows differently per request
  # and a row can appear on two pages across two requests. Naming an item on a page
  # would make this a coin toss rather than a test; the defect is reported on its
  # own rather than encoded here.
  @check @acceptance @local @development @resources
  Scenario: Check paging the resources listing moves the range on
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
     Then I see visible pagination
      And I should see text matching "Showing 1-12 of \d+"
     When I click on the link with the title "Go to page 2"
      And I wait until the page is loaded
     Then the url should match "page=1"
      And I should see text matching "Showing 13-\d+ of \d+"
      And I should not see text matching "Showing 1-12 of"
     When I click on the link with the title "Go to last page"
      And I wait until the page is loaded
     Then I should see text matching "Showing \d+-\d+ of \d+"
      And I should not see text matching "Showing 1-12 of"
      And "a[href='/resources/cultivating-independence-rural-farms']" should be attached within 10 seconds

  # Navigating back to /resources must serve the unfiltered listing again, which
  # is how a visitor recovers from a search that found nothing.
  #
  # DELIBERATELY NOT COVERED: the Reset button on this listing. The exposed block
  # posts Reset to the Blog view's feed path (/blog/feed), so the visitor lands on
  # a 404 instead of the cleared listing. That is a defect in the recipe's exposed
  # filter block, not a behaviour to enshrine in a passing test, and it is
  # reported separately. The Events listing's Reset works and is covered in
  # 05-03.
  @check @exploratory @local @development @resources
  Scenario: Verify returning to the resources listing clears an applied keyword
    Given I am an anonymous user
     When I go to "/resources"
      And I wait until the page is loaded
      And I fill in "Search Keyword" with "clinic networks"
      And I click the "Apply Filters" button
      And I wait until the page is loaded
     Then I should not see "School feeding and attendance"
     When I go to "/resources"
      And I wait until the page is loaded
     Then "input[name='search']" should have value ""
      And I should see "School feeding and attendance"
      And I should see "Clinic networks in dense settlements"
