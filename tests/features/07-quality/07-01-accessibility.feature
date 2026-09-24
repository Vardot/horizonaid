@any @regression @a11y
Feature: Quality - Accessibility - Every page the Horizon Aid template ships
      As a visitor using assistive technology
      I want every Horizon Aid page to be free of serious accessibility issues
      So that a disability never stands between me and the aid information I came for.

  @check @a11y @acceptance @local @development @staging @production
  Scenario Outline: Check the <name> page has no serious accessibility violations
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the page should have no serious accessibility violations

    Examples:
      | name                 | path                                        |
      | Home                 | /                                           |
      | About                | /about                                      |
      | Kenya country        | /countries/kenya                            |
      | Programs             | /programs                                   |
      | Health program       | /programs/health                            |
      | Resources            | /resources                                  |
      | Resource article     | /resources/2026-regional-human-rights-index |
      | Events               | /events                                     |
      | Event                | /events/annual-fundraising-gala             |
      | Impact               | /impact                                     |
      | Donate               | /donate                                     |
      | Newsletter           | /newsletter                                 |
      | Search               | /search                                     |
      | Terms and Conditions | /terms-and-conditions                       |
      | Login                | /user/login                                 |
      | Not found            | /this-page-does-not-exist                   |

    @slow
    Examples:
      | name      | path       |
      | Countries | /countries |

  @check @a11y @acceptance @local @development @staging @production
  Scenario Outline: Check the <name> page passes the full accessibility check
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the page should pass the full accessibility check

    Examples:
      | name             | path                                        |
      | Home             | /                                           |
      | Kenya country    | /countries/kenya                            |
      | Health program   | /programs/health                            |
      | Resources        | /resources                                  |
      | Resource article | /resources/2026-regional-human-rights-index |
      | Events           | /events                                     |
      | Event            | /events/annual-fundraising-gala             |
      | Donate           | /donate                                     |
      | Search           | /search                                     |

  @check @a11y @regression @local @development @staging @production
  Scenario Outline: Check the <name> page satisfies the accessibility rule "<rule>"
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the page should not violate the accessibility rule "<rule>"

    Examples:
      | name             | path                                        | rule                 |
      | Home             | /                                           | color-contrast       |
      | Home             | /                                           | image-alt            |
      | Home             | /                                           | html-has-lang        |
      | Home             | /                                           | page-has-heading-one |
      | Home             | /                                           | link-name            |
      | Home             | /                                           | button-name          |
      | Home             | /                                           | duplicate-id-aria    |
      | About            | /about                                      | color-contrast       |
      | Kenya country    | /countries/kenya                            | image-alt            |
      | Countries        | /countries                                  | color-contrast       |
      | Programs         | /programs                                   | color-contrast       |
      | Health program   | /programs/health                            | color-contrast       |
      | Resources        | /resources                                  | color-contrast       |
      | Resources        | /resources                                  | label                |
      | Resource article | /resources/2026-regional-human-rights-index | image-alt            |
      | Events           | /events                                     | color-contrast       |
      | Events           | /events                                     | label                |
      | Donate           | /donate                                     | color-contrast       |
      | Newsletter       | /newsletter                                 | label                |
      | Search           | /search                                     | label                |
      | Login            | /user/login                                 | label                |

  @check @a11y @regression @local @development @staging @production
  Scenario: Check the Home page links and buttons meet the minimum target size
    Given I am an anonymous user
     When I go to "/"
      And I wait until the page is loaded
     Then the page should not violate the accessibility rule "target-size"

  @check @a11y @regression @local @development @staging @production
  Scenario: Check each navigation landmark on the Home page is distinguishable
    Given I am an anonymous user
     When I go to "/"
      And I wait until the page is loaded
     Then the page should not violate the accessibility rule "landmark-unique"

  @check @a11y @regression @local @development @staging @production
  Scenario: Check the Home page has a single main landmark
    Given I am an anonymous user
     When I go to "/"
      And I wait until the page is loaded
     Then the page should not violate the accessibility rule "landmark-one-main"

  @check @a11y @regression @local @development @staging @production
  Scenario: Check the Home page headings descend without skipping a level
    Given I am an anonymous user
     When I go to "/"
      And I wait until the page is loaded
     Then the page should not violate the accessibility rule "heading-order"

  @check @a11y @regression @slow @local @development @staging @production
  Scenario: Verify the Our Impact headline figures are readable against their background
    Given I am an anonymous user
     When I go to "/impact"
      And I wait until the page is loaded
     Then the page should have no serious accessibility violations
      And the page should pass the accessibility rules "image-alt, input-image-alt"
      And the page should pass the accessibility rules "label, form-field-multiple-labels"
      And the page should pass the accessibility rules "button-name, link-name"
      And the page should pass the accessibility rules "aria-valid-attr, aria-valid-attr-value, aria-roles"
      And the page should not violate the accessibility rule "color-contrast"

  @check @a11y @regression @local @development @staging @production
  Scenario Outline: Check the <name> page stays accessible on a phone
    Given I am an anonymous user
     When I set the viewport to the "xs" breakpoint
      And I go to "<path>"
      And I wait until the page is loaded
     Then the page should have no serious accessibility violations
      And every button should have an accessible name
      And every link should have an accessible name
      And every image should have an alt attribute
      And user zoom should be allowed

    Examples:
      | name      | path       |
      | Home      | /          |
      | About     | /about     |
      | Countries | /countries |
      | Programs  | /programs  |
      | Resources | /resources |
      | Events    | /events    |
      | Impact    | /impact    |
      | Donate    | /donate    |
