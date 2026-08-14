@any @regression @content @countries
Feature: Countries - Related countries - The See Other Countries block
      As a site visitor
      I want a country page to point me at the other countries we work in
      So that I can keep reading about our work instead of going back to the
      listing every time.

  # Every country page closes with a "See Other Countries" block fed by the
  # countries view. What that block looks like is under active design work - it is
  # rendered as a grid in one revision and as a slider in another - so nothing here
  # touches its layout, its controls, its trailing call to action or how many cards
  # it holds. What is asserted is the behaviour that has to hold either way: the
  # block is present, it is the countries view, it never offers the country the
  # visitor is already reading, and its cards reach a real country page.
  #
  # The self-exclusion is the assertion worth having: the view's node argument
  # excludes the current node, and a block that lists the current country back to
  # the visitor is a dead end that no layout change should be allowed to
  # introduce. It is paired with a positive - other countries ARE offered - so a
  # block that renders nothing at all cannot pass as "correctly excluded".

  @check @critical @acceptance @fast @local @development @staging @production @countries
  Scenario: Check a country page closes with the See Other Countries block
    Given I am an anonymous user
     When I go to "/countries/kenya"
      And I wait until the page is loaded
     Then I should see "See Other Countries"
      And "main .view-countries" should be visible within 10 seconds
      And "main .view-countries a[href^='/countries/']" should be visible within 10 seconds

  @check @regression @fast @local @development @countries
  Scenario Outline: Check the <name> page offers other countries and not itself
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then I should see "See Other Countries"
      And "main .view-countries a[href^='/countries/']" should be visible within 10 seconds
      And the link "View Country" with the href "<path>" within the element "main .view-countries" should not exist

    Examples: Countries across the alphabet
      | name        | path                   |
      | Afghanistan | /countries/afghanistan |
      | Kenya       | /countries/kenya       |
      | South Sudan | /countries/south-sudan |
      | Yemen       | /countries/yemen       |

  # Following the first card in the block has to land on a country page that is
  # not the one just left, with its own sections rendered. Which country is offered
  # first is not asserted: the block's order and its number of cards differ
  # between revisions, and the behaviour a visitor depends on is that the card
  # leads somewhere real.
  @check @acceptance @fast @local @development @countries
  Scenario: Check a related country card opens another country page
    Given I am an anonymous user
     When I go to "/countries/kenya"
      And I wait until the page is loaded
     Then I should see "See Other Countries"
     When I click on the element "main .view-countries a[href^='/countries/']"
      And I wait until the page is loaded
     Then the url should match "/countries/[a-z]"
      And the path should not be "/countries/kenya"
      And "h1" should be visible within 10 seconds
      And I should see "Our Role"
      And I should see "Key Country Partners"
