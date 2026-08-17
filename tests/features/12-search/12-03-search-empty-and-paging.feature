@any @regression @search
Feature: Search - Empty results and paging - What the results page does at its two edges
      As a site visitor
      I want a search that found nothing to say so, and a search that found a lot to page
      So that neither outcome leaves me looking at a page that seems broken.

  # The two edges of a results page. A query that matches nothing must produce a
  # readable notice rather than a bare page, and a query that matches more than
  # one page must page without losing the query.
  #
  # Paging is proved by the range moving on and by the pager's own state, never
  # by which result sits on which page: the index sorts on relevance and ties
  # are free to order differently per request.

  @check @exploratory @critical @local @development @staging @production @search
  Scenario: Check a query that matches nothing says so instead of showing an empty page
    Given I am an anonymous user
     When I go to "/search?keywords=telescope"
      And I wait until the page is loaded
     Then "main h1" should have a count of 1
      And ".view-search-results .view-empty" should be visible
      And I should see "There are no results for your search, please try another query."
      And ".view-search-results .views-row" should have a count of 0
      And I don't see pagination

  # The empty notice is a panel, not loose text, and it has to keep the body
  # colour readable on whatever surface it is given.
  @check @regression @a11y @local @development @staging @production @search
  Scenario: Check the empty notice renders as a readable panel
    Given I am an anonymous user
     When I go to "/search?keywords=telescope"
      And I wait until the page is loaded
     Then ".view-search-results .view-empty--notice" should have a count of 1
      And ".view-search-results .view-empty--notice" should be visible

  # A failed search must leave the box usable, with the query still in it, so
  # the visitor can correct a typo rather than start again.
  @check @acceptance @local @development @staging @production @search
  Scenario: Check the search box stays usable after a query that found nothing
    Given I am an anonymous user
     When I go to "/search?keywords=telescope"
      And I wait until the page is loaded
     Then ".view-search-results input[name='keywords']" should be visible
      And ".view-search-results input[name='keywords']" should have value "telescope"
     When I fill in the field ".view-search-results input[name='keywords']" with "water"
      And I click on the element ".view-search-results .views-exposed-form .form-submit"
      And I wait until the page is loaded
     Then ".view-search-results .views-row" should be visible
      And I should not see "There are no results for your search, please try another query."

  # Arriving at /search with no query at all is the state the header toggle
  # produces on an empty submit. It must render the page and ask for a keyword,
  # rather than an empty panel with nothing in it.
  @check @exploratory @local @development @staging @production @search
  Scenario: Check the results page with no query asks for a keyword
    Given I am an anonymous user
     When I go to "/search"
      And I wait until the page is loaded
     Then "main h1" should have a count of 1
      And I should not see "Page not found"
      And ".view-search-results input[name='keywords']" should be visible
      And ".view-search-results input[name='keywords']" should have value ""
      And I should see "Enter a keyword to search Horizon Aid."
      And ".view-search-results .views-row" should have a count of 0

  # The pager is the view's own, so what is asserted is that it appears when the
  # results outrun one page, moves the range on, and carries the query with it.
  @check @acceptance @local @development @staging @production @search
  Scenario: Check paging the results moves the range on and keeps the query
    Given I am an anonymous user
     When I go to "/search?keywords=the"
      And I wait until the page is loaded
     Then I see visible pagination
      And I should see text matching "Showing 1-10 of \d+"
     When I click on the link with the title "Go to page 2"
      And I wait until the page is loaded
     Then the url should match "page=1"
      And the url should match "keywords=the"
      And I should see text matching "Showing 11-\d+ of \d+"
      And I should not see text matching "Showing 1-10 of"
      And ".view-search-results input[name='keywords']" should have value "the"
