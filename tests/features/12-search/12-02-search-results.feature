@any @regression @search
Feature: Search - The results page - One heading, one link and one filter bar per result page
      As a site visitor
      I want the search results page to name itself, keep its search box in reach and list one result per row
      So that I can read what was found and refine the query without leaving the page.

  # The search index holds nodes and Canvas pages, and the view carries a title
  # field for each entity type while only ever filling one of them. Left alone
  # that renders an empty heading beside every real one and links each row
  # twice. These scenarios pin the shape of a row: one heading element, one
  # link on it, and the excerpt under it.
  #
  # The row assertions are written as "no row is wrong" rather than "there are N
  # headings", because a page total would move with the demo content while the
  # defect being guarded is per row. `:has()` and `:not()` are evaluated by the
  # browser, so a single count of 0 covers every row on the page.
  #
  # No result total is asserted anywhere. The index is rebuilt on every install
  # and a pinned total would go red on a content change rather than on a defect.

  @check @acceptance @critical @local @development @staging @production @search
  Scenario: Check the results page names itself with a single top-level heading
    Given I am an anonymous user
     When I go to "/search?keywords=water"
      And I wait until the page is loaded
     Then "main h1" should have a count of 1
      And "main h1" should have text "Search"

  # The filter bar is the search box on the results page. It has to be part of
  # the page, above the results, not hidden behind the header toggle.
  @check @acceptance @critical @local @development @staging @production @search
  Scenario: Check the results page shows its search box inline above the results
    Given I am an anonymous user
     When I go to "/search?keywords=water"
      And I wait until the page is loaded
     Then ".view-search-results .views-exposed-form" should have a count of 1
      And ".view-search-results .views-exposed-form" should be visible
      And ".view-search-results .views-exposed-form" should have class "views-exposed-form--search"
      And ".view-search-results input[name='keywords']" should be visible
      And ".view-search-results .views-exposed-form .form-submit" should be visible
      And the element ".view-search-results .views-exposed-form" should appear after the element "main h1"
      And the element ".view-search-results .view-content" should appear after the element ".view-search-results .views-exposed-form"

  # DELIBERATELY NOT ASSERTED HERE: that the field and the Search button share
  # one line. The suite has an "appears after" step but no negation of it, and
  # two boxes on one line differ by neither vertical order nor any attribute a
  # step can read. The layout is carried by the `views-exposed-form--search`
  # modifier asserted above, which is what makes the single-field form opt out
  # of the listing card's own-line action row; the geometry itself is checked in
  # a real browser at review time rather than approximated here.

  # The result summary belongs under the search box, not above it: a visitor
  # reads the box first and the count second.
  @check @regression @local @development @staging @production @search
  Scenario: Check the result summary sits under the search box
    Given I am an anonymous user
     When I go to "/search?keywords=water"
      And I wait until the page is loaded
     Then I should see text matching "Showing 1-\d+ of \d+"
      And the element ".view-search-results .view-header" should appear after the element ".view-search-results .views-exposed-form"

  # One heading per row is the regression this page keeps failing on, so it is
  # asserted as "no row carries a second heading, and none carries none".
  @check @acceptance @critical @local @development @staging @production @search
  Scenario: Check no result row carries a second or an empty heading
    Given I am an anonymous user
     When I go to "/search?keywords=water"
      And I wait until the page is loaded
     Then ".view-search-results .views-row" should be visible
      And ".view-search-results .views-row:has(h2:nth-of-type(2))" should have a count of 0
      And ".view-search-results .views-row:not(:has(h2))" should have a count of 0
      And ".view-search-results .views-row h2:empty" should have a count of 0

  # Every heading is the row's one link. A row with an unlinked heading is a
  # result a visitor cannot open; a row with a second link is the duplicate the
  # two title sources used to produce.
  @check @acceptance @critical @local @development @staging @production @search
  Scenario: Check every result row carries exactly one link, on its heading
    Given I am an anonymous user
     When I go to "/search?keywords=water"
      And I wait until the page is loaded
     Then ".view-search-results .views-row:not(:has(h2 a))" should have a count of 0
      And ".view-search-results .views-row:has(a:nth-of-type(2))" should have a count of 0

  # The heading has to resolve to the item it names, not to the search page or a
  # dead path.
  @check @acceptance @local @development @staging @production @search
  Scenario: Check a result heading opens the item it names
    Given I am an anonymous user
     When I go to "/search?keywords=water"
      And I wait until the page is loaded
     Then ".view-search-results .views-row:first-child h2 a" should be visible
     When I click on the element ".view-search-results .views-row:first-child h2 a"
      And I wait until the page is loaded
     Then the url should not match "/search"
      And "main h1" should have a count of 1
      And I should not see "Page not found"
      And I should not see "Access denied"

  # Rows have to be separated. A results list where every row butts against the
  # next reads as one block of text.
  @check @regression @local @development @staging @production @search
  Scenario: Check every result row carries the same spacing
    Given I am an anonymous user
     When I go to "/search?keywords=water"
      And I wait until the page is loaded
     Then ".view-search-results .views-row" should be visible
      And ".view-search-results .views-row:not(.mb-5)" should have a count of 0

  # Refining from the results page must re-run the search from that page, which
  # is the second half of the search box being inline at all.
  @check @acceptance @local @development @staging @production @search
  Scenario: Check a new keyword typed on the results page re-runs the search
    Given I am an anonymous user
     When I go to "/search?keywords=water"
      And I wait until the page is loaded
      And I fill in the field ".view-search-results input[name='keywords']" with "education"
      And I click on the element ".view-search-results .views-exposed-form .form-submit"
      And I wait until the page is loaded
     Then the url should match "keywords=education"
      And ".view-search-results input[name='keywords']" should have value "education"
      And ".view-search-results .views-row" should be visible
