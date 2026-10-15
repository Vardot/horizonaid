@any @regression @search
Feature: Search - The filter rail - Category, Content Type and Date Published
      As a site visitor
      I want to narrow a search by category, content type and publish date
      So that I can find the kind of item I am after without paging through every result.

  # Category combines the resource categories and the event categories. The
  # facets render only once there is a query, so every scenario searches first.
  # Totals are never pinned: the assertions are on what is offered and on the
  # filter reaching the URL and the results, not on a count.

  @check @acceptance @critical @local @development @staging @production @search
  Scenario: Check the rail offers the three filters for a query
    Given I am an anonymous user
     When I go to "/search?keywords=the"
      And I wait until the page is loaded
     Then I should see "Category"
      And I should see "Content Type"
      And I should see "Date Published"
      And ".block-facets[class*='search-category'] .facet-item" should be visible
      And ".block-facets[class*='search-content-type'] .facet-item" should be visible
      And "#views-exposed-form-search-date-block input[type='radio'][name='published']" should have a count of 5

  @check @acceptance @local @development @staging @production @search
  Scenario: Check a Content Type facet narrows the results to that type
    Given I am an anonymous user
     When I go to "/search?keywords=the&f[0]=content_type:event"
      And I wait until the page is loaded
     Then ".view-display-id-results_block .card-impressed" should be visible
      And ".view-display-id-results_block .card-impressed .badge:not([aria-label='Event'])" should have a count of 0
      And ".block-facets[class*='search-content-type'] .is-active" should be visible

  @check @acceptance @local @development @staging @production @search
  Scenario: Check a Category facet narrows the results and keeps the query
    Given I am an anonymous user
     When I go to "/search?keywords=the&f[0]=category:Webinar"
      And I wait until the page is loaded
     Then ".view-display-id-results_block .card-impressed" should be visible
      And ".block-facets[class*='search-category'] .is-active" should be visible
      And "#views-exposed-form-search-results-block input[name='keywords']" should have value "the"

  @check @regression @local @development @staging @production @search
  Scenario: Check a facet and the date filter combine with the keyword
    Given I am an anonymous user
     When I go to "/search?keywords=the&f[0]=content_type:event&published=4"
      And I wait until the page is loaded
     Then "main h1" should have a count of 1
      And "#views-exposed-form-search-date-block input[name='published'][value='4']:checked" should have a count of 1
      And "#views-exposed-form-search-results-block input[name='keywords']" should have value "the"
      And I should not see "Page not found"
