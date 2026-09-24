@any @regression @a11y
Feature: Quality - Accessibility - Document structure on every page type
      As a keyboard and screen reader user
      I want every Horizon Aid page type to carry a sound document structure
      So that I can skip to the content, follow the headings and reach every control.

  @check @a11y @acceptance @local @development @staging @production
  Scenario Outline: Check the <name> page carries a sound document structure
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the page should have a title
      And the page should declare a language
      And the page should have exactly one h1
      And the heading hierarchy should be valid
      And the page should have a main landmark
      And the page should have a navigation landmark
      And the page should have a skip link
      And user zoom should be allowed

    @fast
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
      | Donate               | /donate                                     |
      | Newsletter           | /newsletter                                 |
      | Search               | /search                                     |
      | Terms and Conditions | /terms-and-conditions                       |

    Examples:
      | name      | path       |
      | Countries | /countries |
      | Impact    | /impact    |

  @check @a11y @acceptance @local @development @staging @production
  Scenario Outline: Check every control and image on the <name> page can be identified
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then every image should have an alt attribute
      And every link should have an accessible name
      And every button should have an accessible name
      And every ARIA reference should resolve
      And every ARIA role should be valid
      And no element should have a positive tabindex

    @fast
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
      | Donate               | /donate                                     |
      | Newsletter           | /newsletter                                 |
      | Search               | /search                                     |
      | Terms and Conditions | /terms-and-conditions                       |

    Examples:
      | name      | path       |
      | Countries | /countries |
      | Impact    | /impact    |

  @check @a11y @acceptance @local @development @staging @production
  Scenario Outline: Check every form field on the <name> page is labelled
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then every form field should have an accessible label

    @fast
    Examples:
      | name       | path        |
      | Home       | /           |
      | Resources  | /resources  |
      | Events     | /events     |
      | Donate     | /donate     |
      | Newsletter | /newsletter |
      | Search     | /search     |
      | Login      | /user/login |

  @check @a11y @acceptance @fast @local @development @staging @production
  Scenario: Check the login page carries a sound document structure
    Given I am an anonymous user
     When I go to "/user/login"
      And I wait until the page is loaded
     Then the page should have a title
      And the page should declare a language
      And the page should have exactly one h1
      And the heading hierarchy should be valid
      And the page should have a main landmark
      And the page should have a skip link
      And user zoom should be allowed

  @check @a11y @acceptance @fast @local @development @staging @production
  Scenario: Check the not found page carries a sound document structure
    Given I am an anonymous user
     When I go to "/this-page-does-not-exist"
      And I wait until the page is loaded
     Then the page should have a title
      And the page should declare a language
      And the page should have exactly one h1
      And the page should have a main landmark
      And the page should have a skip link
      And every link should have an accessible name
      And user zoom should be allowed

  @check @a11y @acceptance @local @development @staging @production
  Scenario Outline: Verify the skip link is the first thing a keyboard user reaches on the <name> page
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
      And I press the key "Tab"
     Then the focused element should match ".skip-link"

    @fast
    Examples:
      | name   | path    |
      | Home   | /       |
      | Donate | /donate |

    Examples:
      | name   | path    |
      | Impact | /impact |
