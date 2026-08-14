@any @regression @content @countries
Feature: Countries - Countries listing - Cards, keyword filter and ordering
      As a site visitor
      I want the Countries page to name every country Horizon Aid works in and to
      reach each country's own page
      So that I can get to the country I care about without guessing at URLs.

  # /countries is a canvas page: a "Where We Work" hero, the global map, then a
  # "See All Countries" section holding the All countries display of the countries
  # view. The two headings are what a visitor navigates by, and the view's own
  # result summary proves the display rendered rows rather than an empty region
  # behind the headings.
  #
  # No total is asserted in this folder. A total is a count of shipped demo
  # content, and content on a test site comes and goes; the summary is matched as
  # a pattern instead, which still fails if the summary area or the pager
  # configuration disappears.

  @check @critical @acceptance @local @development @staging @production @countries
  Scenario: Check the countries listing renders its hero, its section and the countries view
    Given I am an anonymous user
     When I go to "/countries"
      And I wait until the page is loaded
     Then the page should have a main landmark
      And "h1" should have text "Where We Work" within 10 seconds
      And I should see "See All Countries"
      And "main .view-countries" should be visible within 10 seconds
      # No result-summary assertion here: the recipe ships exactly 12 countries and
      # the display pages at 12, so a fresh install has one page and no pager. The
      # summary is asserted on the resources listing, which ships 26 and does page.
      And I should see "Afghanistan"
      And I should see "Yemen"
      And the link "View Country" with the href "/countries/afghanistan" within the element "main .view-countries" should exist
      And I should not see "The website encountered an unexpected error"

  # Every country the recipe ships is asserted as a card link to its own alias,
  # not as page text: the map section above the listing prints country names too,
  # so text alone would pass even with the listing gone. A country lost when the
  # recipe is re-applied fails its own named row.
  #
  # Each row reaches the country through the listing's own keyword filter rather
  # than the unfiltered first page. The display pages at twelve, so a country
  # added to the site while the suite runs would push the last one alphabetically
  # onto page two and fail a row for a reason that has nothing to do with the
  # recipe. Filtering also earns the row a second assertion: the keyword has to
  # leave the country in and take the others out.
  @check @acceptance @slow @local @development @countries
  Scenario Outline: Check the countries listing finds and links to the <name> country page
    Given I am an anonymous user
     When I go to "/countries?search=<keyword>"
      And I wait until the page is loaded
     Then the link "View Country" with the href "<path>" within the element "main .view-countries" should exist
      And the link "View Country" with the href "<other>" within the element "main .view-countries" should not exist

    Examples: Shipped country pages
      | name        | keyword     | path                   | other                  |
      | Afghanistan | afghanistan | /countries/afghanistan | /countries/yemen       |
      | Bangladesh  | bangladesh  | /countries/bangladesh  | /countries/yemen       |
      | Colombia    | colombia    | /countries/colombia    | /countries/yemen       |
      | Ecuador     | ecuador     | /countries/ecuador     | /countries/yemen       |
      | Kenya       | kenya       | /countries/kenya       | /countries/yemen       |
      | Lebanon     | lebanon     | /countries/lebanon     | /countries/yemen       |
      | Myanmar     | myanmar     | /countries/myanmar     | /countries/yemen       |
      | Somalia     | somalia     | /countries/somalia     | /countries/yemen       |
      | South Sudan | south+sudan | /countries/south-sudan | /countries/yemen       |
      | Syria       | syria       | /countries/syria       | /countries/yemen       |
      | Ukraine     | ukraine     | /countries/ukraine     | /countries/yemen       |
      | Yemen       | yemen       | /countries/yemen       | /countries/afghanistan |

  # The "all" display sorts by title, so the order is a contract worth asserting.
  # Afghanistan (first alphabetically) is compared with Yemen (last of the twelve),
  # because at the default 1920px viewport the grid puts four cards per row and the
  # first four countries share row one, where "appears after" has no vertical
  # difference to measure. First row against last row always has one.
  @check @regression @local @development @countries
  Scenario: Verify the countries listing is ordered by country name
    Given I am an anonymous user
     When I go to "/countries"
      And I wait until the page is loaded
     Then the element "main .view-countries a[href='/countries/yemen']" should appear after the element "main .view-countries a[href='/countries/afghanistan']"

  # A card is only worth listing if it reaches its country. South Sudan is the one
  # alias that is not simply its lowercased name, so it is the card worth clicking
  # through.
  @check @acceptance @local @development @countries
  Scenario: Check a country card opens the country page it names
    Given I am an anonymous user
     When I go to "/countries?search=south+sudan"
      And I wait until the page is loaded
     When I click on the element "main .view-countries a[href='/countries/south-sudan']"
      And I wait until the page is loaded
     Then the path should be "/countries/south-sudan"
      And "h1" should have text "South Sudan" within 10 seconds
      And I should see "Our Role"
