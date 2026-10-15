@any @regression @search
Feature: Search - Content types and combined filters - Every indexed type renders and the filters work together
      As a site visitor
      I want every kind of item to show as a proper result card and the filters to combine
      So that I can trust the results page whatever I search for and however I narrow it.

  @check @acceptance @critical @local @development @staging @production @search
  Scenario: Check the filter rail lists Category, then Content Type, then Date Published
    Given I am an anonymous user
     When I go to "/search?keywords=the"
      And I wait until the page is loaded
     Then the element "[data-drupal-facet-id='search_content_type']" should appear after the element "[data-drupal-facet-id='search_category']"
      And the element "#views-exposed-form-search-date-block" should appear after the element "[data-drupal-facet-id='search_content_type']"
      And "[data-drupal-facet-id='search_content_type'] .facets-checkbox" should have a count of 5

  @check @acceptance @critical @local @development @staging @production @search
  Scenario Outline: Check a <label> result renders as a card with a title link and its badge
    Given I am an anonymous user
     When I go to "/search?keywords=the&f[0]=content_type:<type>"
      And I wait until the page is loaded
     Then ".view-display-id-results_block .card-impressed" should be visible
      And ".view-display-id-results_block .card-impressed .badge[aria-label='<label>']" should be visible
      And ".view-display-id-results_block .card-impressed .badge:not([aria-label='<label>'])" should have a count of 0
      And ".view-display-id-results_block .card-impressed:not(:has(a.stretched-link[href^='/']))" should have a count of 0
      And ".view-display-id-results_block .card-impressed h2:empty" should have a count of 0
      And I should not see "LogicException"
      And I should not see "Requested delta"
      And I should not see "The website encountered an unexpected error"

    Examples:
      | type    | label        |
      | blog    | Blog post    |
      | country | Country      |
      | event   | Event        |
      | program | Program      |
      | page    | Utility page |

  @check @acceptance @local @development @staging @production @search
  Scenario: Check two Content Type boxes together list both types on one page
    Given I am an anonymous user
     When I go to "/search?keywords=the&f[0]=content_type:blog&f[1]=content_type:country"
      And I wait until the page is loaded
     Then ".view-display-id-results_block .badge[aria-label='Blog post']" should be visible
      And ".view-display-id-results_block .badge[aria-label='Country']" should be visible
      And ".view-display-id-results_block .badge:not([aria-label='Blog post']):not([aria-label='Country'])" should have a count of 0
      And "#content-type-blog:checked" should have a count of 1
      And "#content-type-country:checked" should have a count of 1

  @check @acceptance @local @development @staging @production @search
  Scenario: Check ticking a second Content Type box adds to the first and keeps the keyword
    Given I am an anonymous user
     When I go to "/search?keywords=the"
      And I wait until the page is loaded
      And I click on the element "#content-type-blog"
      And I wait until the URL contains "content_type"
      And I wait until the page is loaded
      And I click on the element "#content-type-event"
      And I wait until the page is loaded
     Then "#content-type-event:checked" should have a count of 1 within 10 seconds
      And "#content-type-blog:checked" should have a count of 1
      And the url should match "keywords=the"
      And "#views-exposed-form-search-results-block input[name='keywords']" should have value "the"

  @check @acceptance @local @development @staging @production @search
  Scenario: Check a Category box narrows the results and keeps the keyword
    Given I am an anonymous user
     When I go to "/search?keywords=the"
      And I wait until the page is loaded
      And I click on the element "#category-webinar"
      And I wait until the URL contains "category"
      And I wait until the page is loaded
     Then "#category-webinar:checked" should have a count of 1 within 10 seconds
      And the url should match "keywords=the"
      And ".view-display-id-results_block .card-impressed" should be visible

  @check @acceptance @local @development @staging @production @search
  Scenario: Check choosing a date keeps the keyword
    Given I am an anonymous user
     When I go to "/search?keywords=the"
      And I wait until the page is loaded
      And I select "Past Year" from "#views-exposed-form-search-date-block select[name='published']"
      And I wait until the URL contains "published=4"
      And I wait until the page is loaded
     Then the url should match "keywords=the"
      And "#views-exposed-form-search-date-block select[name='published']" should have value "4"

  @check @acceptance @local @development @staging @production @search
  Scenario: Check a new keyword keeps the chosen date
    Given I am an anonymous user
     When I go to "/search?keywords=the&published=4"
      And I wait until the page is loaded
      And I fill in the field "#views-exposed-form-search-results-block input[name='keywords']" with "water"
      And I click on the element "#views-exposed-form-search-results-block .form-submit"
      And I wait until the page is loaded
     Then the url should match "keywords=water"
      And the url should match "published=4"

  @wip @check @acceptance @local @development @staging @production @search
  Scenario: Check a new keyword keeps the ticked Content Type
    Given I am an anonymous user
     When I go to "/search?keywords=the&f[0]=content_type:event"
      And I wait until the page is loaded
      And I fill in the field "#views-exposed-form-search-results-block input[name='keywords']" with "water"
      And I click on the element "#views-exposed-form-search-results-block .form-submit"
      And I wait until the page is loaded
     Then the url should match "keywords=water"
      And the url should match "content_type"
      And "#content-type-event:checked" should have a count of 1

  @check @acceptance @local @development @staging @production @search
  Scenario Outline: Check the results page works at <width> pixels wide
    Given I am an anonymous user
     When I set the viewport to <width> by <height>
      And I go to "/search?keywords=the"
      And I wait until the page is loaded
     Then "#views-exposed-form-search-results-block input[name='keywords']" should be visible
      And "[data-drupal-facet-id='search_category'] .facets-checkbox" should be visible
      And "[data-drupal-facet-id='search_content_type'] .facets-checkbox" should be visible
      And "#views-exposed-form-search-date-block select[name='published']" should be visible
      And ".view-display-id-results_block .card-impressed" should be visible
      And I see visible pagination
      And JavaScript errors should not match "^(?!Failed to load resource)"

    Examples:
      | width | height |
      | 1440  | 900    |
      | 390   | 844    |

  @check @a11y @local @development @staging @production @search
  Scenario: Check the filtered results page is labelled and structured
    Given I am an anonymous user
     When I go to "/search?keywords=the&f[0]=content_type:event"
      And I wait until the page is loaded
     Then every form field should have an accessible label
      And the page should have exactly one h1
      And the heading hierarchy should be valid
      And the page should have no serious accessibility violations
