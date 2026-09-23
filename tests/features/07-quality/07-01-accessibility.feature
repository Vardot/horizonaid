@any @regression @a11y
Feature: Quality - Accessibility - Every page the Horizon Aid template ships
      As a visitor using assistive technology
      I want every Horizon Aid page to be perceivable and operable
      So that a disability never stands between me and the aid information I came for.

  # WCAG 2.2 AA, anonymous visitor, every public page in the severity gate.
  # Audited with axe-core 4.13 on 23 September 2026: 0 violations.
  # A new finding is fixed or asserted by name, never muted. Tags: tests/TAGS.md.

  @check @a11y @acceptance @local @development @staging @production
  Scenario Outline: Check the <name> page has no critical or serious accessibility violations
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the page should have no critical accessibility violations
      And the page should have no serious accessibility violations

    Examples: every public page, all clean as of the 23 September 2026 audit
      | name                 | path                  |
      | Home                 | /                     |
      | About                | /about                |
      | Programs             | /programs             |
      | Donate               | /donate               |
      | Impact               | /impact               |
      | Resources            | /resources            |
      | Events               | /events               |
      | Terms and Conditions | /terms-and-conditions |

    # 34.6s measured: the countries map page pays for the most audited nodes.
    @slow
    Examples:
      | name      | path       |
      | Countries | /countries |

  # Named so a contrast regression reads "color-contrast", not a total.
  @check @a11y @regression @slow @local @development @staging @production
  Scenario: Verify the Our Impact headline figures are readable against their background
    Given I am an anonymous user
     When I go to "/impact"
      And I wait until the page is loaded
     Then the page should have no critical accessibility violations
      And the page should pass the accessibility rules "image-alt, input-image-alt"
      And the page should pass the accessibility rules "label, form-field-multiple-labels"
      And the page should pass the accessibility rules "button-name, link-name"
      And the page should pass the accessibility rules "aria-valid-attr, aria-valid-attr-value, aria-roles"
      And the page should not violate the accessibility rule "color-contrast"

  # The brand palette (deep green, brand yellow, cream) is applied per component
  # by the theme, so contrast has to be checked per page rather than once. Naming
  # each rule means a designer who changes a colour token gets a failure that
  # says "color-contrast", not an opaque audit count.
  @check @a11y @acceptance @local @development @staging @production
  Scenario Outline: Check the <name> page keeps its text readable and its controls named
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the page should pass the accessibility rules "color-contrast"
      And the page should pass the accessibility rules "image-alt, input-image-alt"
      And the page should pass the accessibility rules "label, form-field-multiple-labels"
      And the page should pass the accessibility rules "button-name, link-name"
      And the page should pass the accessibility rules "aria-valid-attr, aria-valid-attr-value, aria-roles"

    Examples:
      | name      | path       |
      | Home      | /          |
      | About     | /about     |
      | Programs  | /programs  |
      | Resources | /resources |
      | Events    | /events    |
      | Donate    | /donate    |

    # 34.6s measured: the countries map page pays for the most audited nodes.
    @slow
    Examples:
      | name      | path       |
      | Countries | /countries |

  # The structural facts a screen-reader user navigates by. These are cheap to
  # assert and they are the first things a Canvas page loses when an editor
  # rebuilds a section out of raw components: one h1 per page, alt text on every
  # image, an accessible name on every control, resolvable ARIA, and a tab order
  # nobody has overridden with positive tabindex values.
  #
  # /donate and /terms-and-conditions once rendered no h1.
  @check @a11y @acceptance @local @development @staging @production
  Scenario Outline: Check the <name> page is navigable by assistive technology
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the page should have exactly one h1
      And every image should have an alt attribute
      And every form field should have an accessible label
      And every button should have an accessible name
      And every link should have an accessible name
      And every ARIA reference should resolve
      And every ARIA role should be valid
      And no element should have a positive tabindex
      And user zoom should be allowed

    @fast
    Examples:
      | name      | path       |
      | Home      | /          |
      | About     | /about     |
      | Programs  | /programs  |
      | Resources | /resources |
      | Events    | /events    |
      | Donate    | /donate    |
      | Terms     | /terms-and-conditions |

    # 27-30s measured: both pages render a listing or a counter set.
    Examples:
      | name      | path       |
      | Countries | /countries |
      | Impact    | /impact    |

  # Landmarks, a skip link, a title and a declared language are what an
  # assistive-technology user orients with before reading a word of content.
  # They come from the theme's page template, so they are asserted on the
  # sections most likely to be re-templated rather than on one page.
  @check @a11y @acceptance @local @development @staging @production
  Scenario Outline: Check the <name> page is oriented for assistive technology
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the page should have a title
      And the page should declare a language
      And the page should have a main landmark
      And the page should have a navigation landmark
      And the page should have a skip link
      And the heading hierarchy should be valid

    @fast
    Examples:
      | name      | path       |
      | Home      | /          |
      | About     | /about     |
      | Programs  | /programs  |
      | Resources | /resources |
      | Events    | /events    |
      | Donate    | /donate    |

    # 28s measured: both pages render a listing or a counter set.
    Examples:
      | name      | path       |
      | Countries | /countries |
      | Impact    | /impact    |

  # A keyboard user's first action on any page is Tab. If the skip link is not
  # what focus lands on, every keyboard visitor pays the whole header in tab
  # stops before reaching the content.
  @check @a11y @acceptance @local @development @staging @production
  Scenario Outline: Verify the skip link is the first thing a keyboard user reaches on the <name> page
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
      And I press the key "Tab"
     Then the focused element should match ".skip-link"

    @fast
    Examples:
      | name   | path     |
      | Home   | /        |
      | Donate | /donate  |

    # 13.6s measured: the counter set on Our Impact.
    Examples:
      | name   | path     |
      | Impact | /impact  |

  # At a phone width the accessibility contract does not change, but the markup
  # does: the navigation collapses behind a toggle and components restack. This
  # catches the mobile-only regressions, such as a burger toggle that renders as
  # an unnamed button.
  #
  # No speed tag: the rows measured 4.1s to 17.6s, so most of them straddle the
  # 5 second line too closely for @fast to be honest on a shared runner.
  @check @a11y @regression @local @development @staging @production
  Scenario Outline: Check the <name> page stays accessible on a phone
    Given I am an anonymous user
     When I set the viewport to the "xs" breakpoint
      And I go to "<path>"
      And I wait until the page is loaded
     Then the page should have no critical accessibility violations
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

  # Two rules a sibling template regressed on: footer social icons rendered a
  # link colour that failed AA against the section background, and a front page
  # whose title came out as an h2 so there was no h1 to jump to. Named here so a
  # regression on the home page reads as the rule that broke rather than as a
  # count.
  #
  # What color-contrast does and does not cover is worth stating. axe measures
  # rendered text. The footer social links carry an icon-font glyph on a label
  # sized to zero, so that rule never evaluates them; a contrast regression in
  # those icons would pass this scenario. Covering them needs an assertion on
  # the icon colour itself, not an axe rule.
  #
  # No speed tag: this scenario has not been measured on a shared runner.
  @check @a11y @regression @local @development @staging @production
  Scenario: Check the Home page holds the two rules a sibling template regressed on
    Given I am an anonymous user
     When I go to "/"
      And I wait until the page is loaded
     Then the page should not violate the accessibility rule "color-contrast"
      And the page should not violate the accessibility rule "page-has-heading-one"
      And the page should have exactly one h1
