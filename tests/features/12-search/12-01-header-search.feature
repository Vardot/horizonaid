@any @regression @navigation @search
Feature: Search - The header search toggle - Reaching the results page from any page
      As a site visitor
      I want a search control in the header of every page
      So that I can look something up without first finding a search page.

  # The header carries a single icon button. The search box itself lives in a
  # panel that button reveals, so the header stays a logo and a menu until a
  # visitor asks for search.
  #
  # Two inputs on this site are named "keywords": the one in this header panel
  # and the one in the filter bar on the results page. Every step here scopes to
  # the header panel, because an unscoped selector matches the header's hidden
  # input first and would assert against a zero-sized element.

  @check @smoke @acceptance @critical @local @development @staging @production @navigation @search
  Scenario: Check the header carries a search toggle on the home page
    Given I am an anonymous user
     When I go to "/home"
      And I wait until the page is loaded
     Then "header[role='banner'] .icon-toggle__button" should have a count of 1
      And "header[role='banner'] .icon-toggle__button" should be visible
      And "header[role='banner'] .icon-toggle__button" should have attribute "aria-expanded" with value "false"

  # Collapsed at rest is the whole point of a toggle: the search box must not be
  # occupying header space, or reachable by tab, before it is asked for.
  @check @regression @local @development @staging @production @navigation @search
  Scenario: Check the header search box is hidden until the toggle is used
    Given I am an anonymous user
     When I go to "/home"
      And I wait until the page is loaded
     Then "header[role='banner'] .icon-toggle__panel" should be hidden
      And "header[role='banner'] .icon-toggle__panel input[name='keywords']" should not be visible

  @check @acceptance @critical @local @development @staging @production @navigation @search
  Scenario: Check the toggle opens the panel and reveals the search box
    Given I am an anonymous user
     When I go to "/home"
      And I wait until the page is loaded
      And I click on the element "header[role='banner'] .icon-toggle__button"
     Then "header[role='banner'] .icon-toggle__panel" should be visible within 10 seconds
      And "header[role='banner'] .icon-toggle__panel input[name='keywords']" should be visible
      And "header[role='banner'] .icon-toggle__button" should have attribute "aria-expanded" with value "true"

  # Opening and closing again must leave the header as it was found, so the
  # control is usable more than once per page load.
  @check @exploratory @local @development @staging @production @navigation @search
  Scenario: Verify the toggle closes the panel again
    Given I am an anonymous user
     When I go to "/home"
      And I wait until the page is loaded
      And I click on the element "header[role='banner'] .icon-toggle__button"
     Then "header[role='banner'] .icon-toggle__panel" should be visible within 10 seconds
     When I click on the element "header[role='banner'] .icon-toggle__button"
     Then "header[role='banner'] .icon-toggle__panel" should be hidden within 10 seconds
      And "header[role='banner'] .icon-toggle__button" should have attribute "aria-expanded" with value "false"

  # The point of the header box: what is typed there has to arrive on the
  # results page, in the URL and back in the results page's own field, not just
  # land the visitor on an empty /search.
  @check @acceptance @critical @local @development @staging @production @navigation @search
  Scenario: Check searching from the header lands on the results page carrying the query
    Given I am an anonymous user
     When I go to "/home"
      And I wait until the page is loaded
      And I click on the element "header[role='banner'] .icon-toggle__button"
     Then "header[role='banner'] .icon-toggle__panel input[name='keywords']" should be visible within 10 seconds
     When I fill in the field "header[role='banner'] .icon-toggle__panel input[name='keywords']" with "water"
      And I click on the element "header[role='banner'] .icon-toggle__panel .form-submit"
      And I wait until the page is loaded
     Then the url should match "/search"
      And the url should match "keywords=water"
      And ".view-search-results" should be visible
      And ".view-search-results input[name='keywords']" should have value "water"

  # The toggle is part of the global header region, so it has to be on an
  # interior page too, not only on the front page where it was first placed.
  @check @regression @local @development @staging @production @navigation @search
  Scenario Outline: Check the header search toggle is present on <page>
    Given I am an anonymous user
     When I go to "<page>"
      And I wait until the page is loaded
     Then "header[role='banner'] .icon-toggle__button" should have a count of 1
      And "header[role='banner'] .icon-toggle__button" should be visible

    Examples:
      | page       |
      | /countries |
      | /programs  |
      | /resources |
      | /events    |
