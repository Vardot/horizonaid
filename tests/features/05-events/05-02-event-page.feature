Feature: Events - Event page - Date, programme and registration
      As a site visitor
      I want an event page with its date, programme and registration action
      So that I know what the event is and how to join it.

  # An event full page has to answer three questions before anything else: what
  # it is, when it is, and how to register. The date comes from the event date
  # field and the action is a themed button, not a link, so it is asserted as a
  # button by its accessible name. An event page that regressed to an empty
  # content region still returns HTTP 200, which is why every assertion here is a
  # visible label rather than a response code.
  @check @acceptance @fast @local @development @events
  Scenario: Check an event page renders its type, date, programme and registration action
    Given I am an anonymous user
     When I go to "/events/winterisation-readiness-briefing"
      And I wait until the page is loaded
     Then the page should have a main landmark
      And the page should have exactly one h1
      And "h1" should have text "Winterisation readiness briefing"
      And I should see "Briefing"
      And I should see "24 September 2027"
      And the "Register Today" button should be visible
      And I should see "About this Event"
      And I should see "What You'll Learn"
      And I should see "Speakers"

  # The Webshare block is recipe configuration: each network is its own link with
  # its own accessible name, which is what an assistive-technology user hears. A
  # platform dropped from the recipe's social-platform settings fails on the
  # missing name.
  @check @regression @fast @local @development @staging @production @events
  Scenario: Check an event page offers the configured share actions
    Given I am an anonymous user
     When I go to "/events/winterisation-readiness-briefing"
      And I wait until the page is loaded
     Then I should see "Share"
      And the "Share on Facebook (opens in a new tab)" link should be visible
      And the "Share on LinkedIn (opens in a new tab)" link should be visible
      And the "Share on X (opens in a new tab)" link should be visible
      And the "Share on Instagram (opens in a new tab)" link should be visible

  # An event page must lead back to the Events section and on to the next event,
  # or a visitor arriving from search has nowhere to go. The breadcrumb comes from
  # the alias pattern, the related block from the Events view's related display.
  @check @regression @fast @local @development @staging @production @events
  Scenario: Verify an event page leads back to Events and on to more events
    Given I am an anonymous user
     When I go to "/events/winterisation-readiness-briefing"
      And I wait until the page is loaded
     Then "Home" should be in the breadcrumb
      And "Events" should be in the breadcrumb
      And the link "Events" with the href "/events" should exist
      And I should see "More Events"
      And I should see "Join Our Mission"

  # A related event is only useful if it reaches the event it names, so assert the
  # related card's anchor carries that event's own alias.
  @check @regression @fast @local @development @events
  Scenario: Verify a related event card points at another event
    Given I am an anonymous user
     When I go to "/events/winterisation-readiness-briefing"
      And I wait until the page is loaded
     Then I should see "Emergency shelter standards review"
      And "a[href='/events/emergency-shelter-standards-review']" should be attached within 10 seconds

  # One row per shipped event, so an event whose alias, title or render pipeline
  # breaks when the recipe is re-applied fails its own named row instead of hiding
  # behind a single sample. An event page is reached directly, so it renders
  # whatever its date - only the listing filters on the date.
  @check @smoke @fast @local @development @staging @production @events
  Scenario Outline: Check the <title> event page renders for an anonymous visitor
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then "h1" should have text "<title>"
      And I should see "About this Event"
      And I should see "Share"
      And I should not see "The website encountered an unexpected error"
      And I should not see "Page not found"

    Examples: Shipped events
      | path                                        | title                              |
      | /events/winterisation-readiness-briefing     | Winterisation readiness briefing   |
      | /events/water-access-crisis-zones            | Water access in crisis zones       |
      | /events/supply-chain-resilience-review       | Supply chain resilience review     |
      | /events/impact-reporting-transparency-talk   | Impact reporting transparency talk |
