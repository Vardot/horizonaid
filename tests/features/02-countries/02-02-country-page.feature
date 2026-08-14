@any @regression @content @countries
Feature: Countries - Country page - Sections, aliases and breadcrumb
      As a site visitor
      I want a country page to set out our role, the work on the ground, the
      figures behind it and the partners doing it
      So that I can understand what Horizon Aid actually does in that country.

  # The country full page is one Canvas template shared by every country node, so
  # the five section headings are the template's contract: a section dropped from
  # the template breaks every country at once, and a country whose own fields are
  # empty breaks only its own row in the outline below.
  #
  # The hero's own presentation is deliberately not asserted anywhere - colours,
  # side insets, image ratio and description alignment are being reworked - so
  # these scenarios stay green whichever hero the template renders.

  @check @critical @acceptance @fast @local @development @staging @production @countries
  Scenario: Check a country page renders every section of the country template
    Given I am an anonymous user
     When I go to "/countries/kenya"
      And I wait until the page is loaded
     Then the page should have a main landmark
      And "h1" should have text "Kenya" within 10 seconds
      And I should see "Our Role"
      And I should see "On the Ground"
      And I should see "By the Numbers"
      And I should see "Key Country Partners"
      And "main img" should be visible within 10 seconds
      And I should not see "The website encountered an unexpected error"

  # Every shipped country is opened by its own alias and has to answer with its
  # own name as the page heading plus the first template section. This is the row
  # that fails when a country node loses its alias, its title or its body content,
  # and it names which country it was.
  @check @regression @fast @local @development @countries
  Scenario Outline: Check the <name> country page renders under its own alias
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then "h1" should have text "<name>" within 10 seconds
      And I should see "Our Role"
      And I should not see "The website encountered an unexpected error"
      And I should not see "Page not found"

    Examples: Shipped country pages
      | name        | path                   |
      | Afghanistan | /countries/afghanistan |
      | Bangladesh  | /countries/bangladesh  |
      | Colombia    | /countries/colombia    |
      | Ecuador     | /countries/ecuador     |
      | Kenya       | /countries/kenya       |
      | Lebanon     | /countries/lebanon     |
      | Myanmar     | /countries/myanmar     |
      | Somalia     | /countries/somalia     |
      | South Sudan | /countries/south-sudan |
      | Syria       | /countries/syria       |
      | Ukraine     | /countries/ukraine     |
      | Yemen       | /countries/yemen       |

  # A visitor who arrived on a country page from a search engine needs a way up
  # into the section. The crumb is asserted as a link to /countries, so a crumb
  # that renders the word without linking anywhere fails.
  @check @exploratory @fast @local @development @staging @production @countries
  Scenario: Verify a country page links back to the Countries section
    Given I am an anonymous user
     When I go to "/countries/kenya"
      And I wait until the page is loaded
     Then "nav[aria-label='breadcrumb']" should be visible within 10 seconds
      And "nav[aria-label='breadcrumb'] a[href='/countries']" should have a count of 1
