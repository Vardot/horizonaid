@any @regression @content @programs
Feature: Programs - Programs listing - Rows, keyword filter and donation FAQ
      As a supporter deciding what to fund
      I want the Our Programs page to name every programme with a way into it
      So that I can read up on the work before I give.

  # /programs is a canvas page: the "Our Programs" hero, the All programs display
  # of the programs view, then the donation FAQ. The listing's own heading is
  # visually hidden for screen readers, so the view block itself is asserted rather
  # than that heading, and each programme is asserted as a "Learn More" link to its
  # own alias - programme names such as Education and Health appear in body copy
  # elsewhere on the page, so text alone would pass with the listing gone.
  #
  # No programme total is asserted: a total is a count of shipped demo content.

  @check @critical @acceptance @fast @local @development @staging @production @programs
  Scenario: Check the programs listing renders its hero and the programs view
    Given I am an anonymous user
     When I go to "/programs"
      And I wait until the page is loaded
     Then the page should have a main landmark
      And "h1" should have text "Our Programs" within 10 seconds
      And "main .view-programs" should be visible within 10 seconds
      And "main .view-programs a[href^='/programs/']" should be visible within 10 seconds
      And I should not see "The website encountered an unexpected error"

  # Each programme is asserted on the listing by its name AND by its own row link,
  # so a row that lost its link, or a link pointing at the wrong programme, fails
  # under the programme's own name.
  @check @regression @fast @local @development @programs
  Scenario Outline: Check the programs listing links to the <name> programme
    Given I am an anonymous user
     When I go to "/programs"
      And I wait until the page is loaded
     Then I should see "<name>"
      And the link "Learn More" with the href "<path>" within the element "main .view-programs" should exist

    Examples: Shipped programmes
      | name        | path                  |
      | Education   | /programs/education   |
      | Health      | /programs/health      |
      | Women       | /programs/women       |
      | Agriculture | /programs/agriculture |
      | Medicine    | /programs/medicine    |

  # The listing carries an exposed title filter, and the Canvas block renders the
  # results without the form, so the keyword arrives in the query string - which is
  # what a shared or bookmarked filtered link looks like. Positive and negative are
  # paired: a filter that stopped filtering would return every programme and fail
  # on the negative.
  @check @acceptance @fast @local @development @programs
  Scenario: Check a keyword narrows the programs listing to the matching programme
    Given I am an anonymous user
     When I go to "/programs?search=health"
      And I wait until the page is loaded
     Then the link "Learn More" with the href "/programs/health" within the element "main .view-programs" should exist
      And the link "Learn More" with the href "/programs/education" within the element "main .view-programs" should not exist

  # The page answers the questions a first-time donor asks before giving, so the
  # FAQ belongs to the listing's job rather than to decoration.
  @check @regression @fast @local @development @programs
  Scenario: Check the programs listing answers the donation questions
    Given I am an anonymous user
     When I go to "/programs"
      And I wait until the page is loaded
     Then I should see "FAQ"
      And I should see "How is my donation used?"
      And I should see "Where does Horizon Aid operate?"

  # A row is only worth listing if it reaches its programme page.
  @check @acceptance @fast @local @development @programs
  Scenario: Check a programme row opens the programme page it names
    Given I am an anonymous user
     When I go to "/programs"
      And I wait until the page is loaded
     When I click on the element "main .view-programs a[href='/programs/agriculture']"
      And I wait until the page is loaded
     Then the path should be "/programs/agriculture"
      And "h1" should have text "Agriculture" within 10 seconds
      And I should see "About This Program"
