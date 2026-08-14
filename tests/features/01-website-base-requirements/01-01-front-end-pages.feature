@any @regression @smoke
Feature: Website Base Requirements - Front-end pages render
      As a site visitor
      I want every section the Horizon Aid template ships to load without errors
      So that the site is usable the moment the recipe is installed.

  # Every canvas page shipped in content/canvas_page is asserted by its path and
  # its visible title, plus the absence of the Drupal error page. A page whose
  # alias, title or render pipeline breaks when the recipe is re-applied fails
  # its own named row instead of a vague "something broke".

  @check @regression @local @development @staging @production @navigation
  Scenario Outline: The <name> page renders for an anonymous visitor
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then I should see "<title>"
      And I should not see "The website encountered an unexpected error"
      And I should not see "Page not found"

    Examples: Shipped canvas pages
      | name      | path        | title        |
      | home      | /home       | Education    |
      | about     | /about      | About        |
      | resources | /resources  | Resources    |
      | programs  | /programs   | Our Programs |
      | events    | /events     | Events       |
      | countries | /countries  | Countries    |
      | donate    | /donate     | Donate       |

  # The front page setting points "/" at /home; a regression in that config
  # action would leave the default Drupal front page in place.
  @check @smoke @fast @local @development @staging @production @navigation
  Scenario: The site front page is the Horizon Aid home page
    Given I am an anonymous user
     When I go to "/"
      And I wait until the page is loaded
     Then I should not see "The website encountered an unexpected error"
      And "header[role='banner']" should be visible
      And "footer" should be visible
