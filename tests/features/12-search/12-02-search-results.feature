@any @regression @search
Feature: Search - The results page - A heading, a keyword bar, a filter rail and result cards
      As a site visitor
      I want the search results page to name itself, keep its search box in reach and list each result as a card
      So that I can read what was found and refine the query without leaving the page.

  # /search is a Canvas page. It places the keyword bar and the results from
  # the search view's results block, and a filter rail with the Category and
  # Content Type facets and the Date Published group.
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

  @check @acceptance @critical @local @development @staging @production @search
  Scenario: Check the keyword bar sits above the results and carries the query
    Given I am an anonymous user
     When I go to "/search?keywords=water"
      And I wait until the page is loaded
     Then "#views-exposed-form-search-results-block" should have a count of 1
      And "#views-exposed-form-search-results-block" should have class "views-exposed-form--search"
      And "#views-exposed-form-search-results-block input[name='keywords']" should be visible
      And "#views-exposed-form-search-results-block input[name='keywords']" should have value "water"
      And "#views-exposed-form-search-results-block .form-submit" should be visible
      And the element "#views-exposed-form-search-results-block" should appear after the element "main h1"
      And the element ".view-display-id-results_block .view-content" should appear after the element "#views-exposed-form-search-results-block"

  # The keyword bar and the rail are two forms of one view. Each shows only its
  # own field and carries the other as a hidden input.
  @check @regression @local @development @staging @production @search
  Scenario: Check each search form shows only its own field
    Given I am an anonymous user
     When I go to "/search?keywords=water"
      And I wait until the page is loaded
     Then "#views-exposed-form-search-results-block select[name='published']" should have a count of 0
      And "#views-exposed-form-search-date-block input[name='keywords']" should not be visible
      And "#views-exposed-form-search-date-block select[name='published'] option" should have a count of 5

  @check @regression @local @development @staging @production @search
  Scenario: Check the result summary sits above the result cards
    Given I am an anonymous user
     When I go to "/search?keywords=water"
      And I wait until the page is loaded
     Then I should see text matching "Showing 1-\d+ of \d+"
      And the element ".view-display-id-results_block .view-content" should appear after the element ".view-display-id-results_block .view-header"

  # Each result is one card: one heading and one link, the card's own.
  @check @acceptance @critical @local @development @staging @production @search
  Scenario: Check every result card carries one heading and one link
    Given I am an anonymous user
     When I go to "/search?keywords=water"
      And I wait until the page is loaded
     Then ".view-display-id-results_block .card-impressed" should be visible
      And ".view-display-id-results_block .card-impressed:not(:has(h2))" should have a count of 0
      And ".view-display-id-results_block .card-impressed:has(h2:nth-of-type(2))" should have a count of 0
      And ".view-display-id-results_block .card-impressed h2:empty" should have a count of 0
      And ".view-display-id-results_block .card-impressed:not(:has(a.stretched-link))" should have a count of 0
      And ".view-display-id-results_block .card-impressed .badge" should be visible

  # A card is a stretched-link: an empty anchor over the card. Its href is the
  # contract, so assert it, then open that item.
  @check @acceptance @local @development @staging @production @search
  Scenario: Check a result card links to the item it names
    Given I am an anonymous user
     When I go to "/search?keywords=borehole"
      And I wait until the page is loaded
     Then ".view-display-id-results_block a.stretched-link[href='/resources/water-trucking-borehole-rehabilitation']" should be attached within 10 seconds
     When I go to "/resources/water-trucking-borehole-rehabilitation"
      And I wait until the page is loaded
     Then "main h1" should have a count of 1
      And I should not see "Page not found"

  @check @acceptance @local @development @staging @production @search
  Scenario: Check a new keyword typed on the results page re-runs the search
    Given I am an anonymous user
     When I go to "/search?keywords=water"
      And I wait until the page is loaded
      And I fill in the field "#views-exposed-form-search-results-block input[name='keywords']" with "education"
      And I click on the element "#views-exposed-form-search-results-block .form-submit"
      And I wait until the page is loaded
     Then the url should match "keywords=education"
      And "#views-exposed-form-search-results-block input[name='keywords']" should have value "education"
      And ".view-display-id-results_block .card-impressed" should be visible
