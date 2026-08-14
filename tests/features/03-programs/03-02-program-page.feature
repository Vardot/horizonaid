@any @regression @content @programs
Feature: Programs - Programme page - Sections, country map and breadcrumb
      As a supporter deciding what to fund
      I want a programme page to explain the work, the figures behind it and where
      it runs
      So that I know what my donation pays for before I give.

  # The programme full page is one Canvas template shared by every programme node:
  # an "About This Program" opening, the programme's own story, a figures section, a
  # delivery section, a map of the countries the programme runs in and a closing
  # call to action. The shared parts are asserted once; the per-programme headings
  # are asserted row by row in the outline, where a programme whose own content is
  # empty fails under its own name.

  @check @critical @acceptance @fast @local @development @staging @production @programs
  Scenario: Check a programme page renders the sections of the programme template
    Given I am an anonymous user
     When I go to "/programs/education"
      And I wait until the page is loaded
     Then the page should have a main landmark
      And "h1" should have text "Education" within 10 seconds
      And I should see "About This Program"
      And I should see "Education by the Numbers"
      And I should see "How We Deliver Education"
      And I should see "Where Education Runs"
      And I should see "Join Our Mission"
      And "main img" should be visible within 10 seconds
      And I should not see "The website encountered an unexpected error"

  # Each programme is opened by its own alias and has to answer with its own name,
  # its own figures section and its own delivery section. The headings differ per
  # programme because they are written per programme, so they travel in the
  # Examples table rather than being guessed from the title.
  @check @regression @fast @local @development @programs
  Scenario Outline: Check the <name> programme page renders under its own alias
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then "h1" should have text "<name>" within 10 seconds
      And I should see "About This Program"
      And I should see "<numbers>"
      And I should see "<delivery>"
      And I should not see "The website encountered an unexpected error"
      And I should not see "Page not found"

    Examples: Shipped programmes
      | name        | path                  | numbers                    | delivery                   |
      | Education   | /programs/education   | Education by the Numbers   | How We Deliver Education   |
      | Health      | /programs/health      | Health by the Numbers      | How We Deliver Health      |
      | Women       | /programs/women       | Rights by the Numbers      | How We Deliver for Women   |
      | Agriculture | /programs/agriculture | Agriculture by the Numbers | How We Deliver Agriculture |
      | Medicine    | /programs/medicine    | Medicine by the Numbers    | How We Deliver Medicine    |

  # The "Where ... Runs" section is a world map: a country the programme works in
  # is a shape on that map, and its card is revealed when a visitor picks the
  # country. Two things are asserted per programme - the country's own shape is on
  # the map, and the card behind it carries a link into that country's page. The
  # cards start hidden by design, so their presence and their destination are
  # asserted, never their visibility.
  @check @regression @fast @local @development @programs
  Scenario Outline: Check the <name> programme page maps the countries it runs in
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then "main .map" should be visible within 10 seconds
      And "main .map svg path[data-iso-a2='<iso>']" should be visible within 10 seconds
      And the link "Learn More" with the href "<country>" within the element "main .map" should exist

    Examples: A country each programme runs in
      | name        | path                  | iso | country                |
      | Education   | /programs/education   | AF  | /countries/afghanistan |
      | Health      | /programs/health      | LB  | /countries/lebanon     |
      | Women       | /programs/women       | CO  | /countries/colombia    |
      | Agriculture | /programs/agriculture | SO  | /countries/somalia     |
      | Medicine    | /programs/medicine    | UA  | /countries/ukraine     |

  # The journey a supporter takes from "what do you do" to "where do you do it":
  # pick the country on the programme's map, read its card, follow it into the
  # country page. Asserting the card only after the map is used is what proves the
  # map is wired up rather than decorative.
  @check @acceptance @fast @local @development @programs
  Scenario: Check picking a country on the programme map opens that country page
    Given I am an anonymous user
     When I go to "/programs/education"
      And I wait until the page is loaded
     Then I should see "Where Education Runs"
     When I click on the element "main .map svg path[data-iso-a2='KE']"
     Then "main .map .map-info-card[data-country-code='KE']" should be visible within 10 seconds
      And "main .map .map-info-card[data-country-code='KE'] a[href='/countries/kenya']" should be visible within 10 seconds
     When I click on the element "main .map .map-info-card[data-country-code='KE'] a[href='/countries/kenya']"
      And I wait until the page is loaded
     Then the path should be "/countries/kenya"
      And "h1" should have text "Kenya" within 10 seconds
      And I should see "Our Role"

  # A visitor who arrived from a search engine needs a way up into the section. The
  # crumb is asserted as a link, so a crumb that prints the words without linking
  # anywhere fails.
  @check @exploratory @fast @local @development @staging @production @programs
  Scenario: Verify a programme page links back to the Programs section
    Given I am an anonymous user
     When I go to "/programs/education"
      And I wait until the page is loaded
     Then "nav[aria-label='breadcrumb']" should be visible within 10 seconds
      And "nav[aria-label='breadcrumb'] a[href='/programs']" should have a count of 1
