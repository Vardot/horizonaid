Feature: Impact and Donate - Our Impact page - Transparency statement and animated figures
      As a donor, partner or grant officer
      I want the Our Impact page to state what the organisation has achieved
      So that I can judge whether my money reaches people.

  # The Our Impact page is the accountability page of an aid template: a
  # transparency statement, three headline totals, and a per-programme
  # breakdown. Every number on it is an animated counter, so the figure a
  # visitor actually reads is written by JavaScript at runtime, not by the
  # render pipeline. That is the fragile part worth gating: the markup can ship
  # perfectly and the visitor can still be looking at a zero.
  #
  # The counters are asserted with the polling `eventually I should see` step
  # rather than a one-shot text check or a fixed wait. The count-up IS the
  # behaviour under test, and a fixed wait would be either a sleep tax on every
  # run or a race, both of which hide the one failure that matters: a counter
  # that never reaches its published total. The 10 second budget is a cap, not
  # a sleep; a healthy page satisfies it in well under a second.
  #
  # Every figure is asserted as a number-plus-label pair. A number without its
  # label is unreadable, and a label without its number is worse than nothing
  # on a page whose whole job is to be credible.

  @check @critical @acceptance @local @development @staging @production @impact
  Scenario: Check the Our Impact page states its title and its transparency promise
    Given I am an anonymous user
     When I go to "/impact"
      And I wait until the page is loaded
     Then "h1" should contain text "Our Impact" within 10 seconds
      And I should see "We believe in absolute transparency"
      And I should see "we track every dollar"
      And "nav[aria-label='breadcrumb']" should be visible within 10 seconds
      And I should not see "The website encountered an unexpected error"

  # The three headline totals are what a visitor takes away from the page. Each
  # row asserts the counter reaching its published total AND the label that
  # gives the number its meaning.
  @check @critical @acceptance @local @development @staging @production @impact
  Scenario Outline: Verify the headline counter for <label> counts up to its published total
    Given I am an anonymous user
     When I go to "/impact"
      And I wait until the page is loaded
     Then eventually I should see "<total>" within 10 seconds
      And I should see "<label>"

    Examples: Headline totals
      | total  | label               |
      | 20K+   | Lives Protected     |
      | 137K+  | Legal Aid Hours     |
      | 11K+   | Communities Served  |

  # The per-programme breakdown is what turns a headline total into something a
  # grant officer can check. Each programme's figure carries its own row so a
  # dropped or renamed programme figure fails by name.
  @check @acceptance @local @development @staging @production @impact
  Scenario Outline: Verify the Impact by Programme section reports <label>
    Given I am an anonymous user
     When I go to "/impact"
      And I wait until the page is loaded
     Then "h2" should contain text "Impact by Programme" within 10 seconds
      And eventually I should see "<total>" within 10 seconds
      And I should see "<label>"

    Examples: Per-programme figures
      | total | label                                        |
      | 12K   | Households farming independently             |
      | 8K+   | Children enrolled in safe learning spaces    |
      | 3.2K  | Women supported through legal defence        |
      | 58    | Clinics built or rehabilitated               |
      | 420   | Tonnes of medical supplies delivered          |

  # A structural gate on the figure components themselves. The rows above prove
  # each figure's content; this proves none of them lost its counter binding. A
  # figure rendered as static text would still read correctly above but would
  # never animate, and no content assertion would notice.
  #
  # This counts page components shipped by the recipe, not content entities, so
  # it stays stable while editors add and remove nodes elsewhere on the site.
  @check @regression @local @development @staging @production @impact
  Scenario: Check every impact figure on the page is a bound counter
    Given I am an anonymous user
     When I go to "/impact"
      And I wait until the page is loaded
     Then "[data-component-id='vartheme_bs5_horizonaid:figure']" should have a count of 8 within 10 seconds
      And "[data-component-id='vartheme_bs5_horizonaid:figure'] [data-count-target]" should have a count of 8 within 10 seconds

  # The page ends by sending the reader to the country work. A call to action
  # whose label renders but whose href is empty is a dead end that looks fine in
  # a screenshot, so the link is followed, not just read.
  @check @regression @local @development @staging @production @impact
  Scenario: Verify the Our Impact page sends the reader on to where the work happens
    Given I am an anonymous user
     When I go to "/impact"
      And I wait until the page is loaded
     Then the link "See Where We Work" with the href "/countries" should exist
     When I click the "See Where We Work" link
      And I wait until the page is loaded
     Then the path should be "/countries"

  # The counters are driven from the viewport on a phone as well as a desktop. A
  # count-up wired to a desktop-only trigger leaves a mobile visitor, the
  # majority of an aid campaign's traffic, reading zeros.
  @check @exploratory @local @development @staging @production @impact
  Scenario: Check the impact figures still count up on a phone
    Given I am an anonymous user
     When I set the viewport to the "xs" breakpoint
      And I go to "/impact"
      And I wait until the page is loaded
     Then "h1" should contain text "Our Impact" within 10 seconds
      And eventually I should see "20K+" within 10 seconds
      And I should see "Lives Protected"
