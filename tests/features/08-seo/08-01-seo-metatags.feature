Feature: SEO - Metatags - Canonical URLs, titles and sharing previews
      As a communications team
      I want every page to declare its own title, canonical URL and share preview
      So that search engines index the right URL and a shared link presents the organisation properly.

  # Horizon Aid ships the Varbase SEO base: Metatag, one canonical URL per page,
  # Open Graph output, and the mobile-friendliness meta tags. None of it is
  # visible in a browser window, which is exactly why it rots quietly: a
  # canonical pointing at the front page or a noindex left on after a launch
  # rehearsal costs traffic for weeks before anyone notices.
  #
  # Two things to know about the assertions here.
  #
  # First, the core metatag data-table step matches every attribute exactly, so
  # it is used only for the fixed template values (viewport, robots, og:type).
  # Values that legitimately vary - og:url carries the real host, og:site_name
  # carries whatever the installer typed as the site name, the Twitter card type
  # differs between the home page and the inner pages by configuration -
  # are asserted with the element-attribute step on a fragment that survives a
  # rename, so this feature passes on a DDEV box, a staging host and production
  # without edits.
  #
  # Second, an open finding, not asserted: the Canvas pages (/, /about,
  # /countries, /programs, /resources, /events, /impact, /donate) emit
  # og:site_name and og:url but NO meta description, og:title, og:description or
  # og:image, and their canonical is emitted as a root-relative path while node
  # pages emit an absolute URL. A Donate link shared on WhatsApp or LinkedIn
  # therefore previews with no headline text and no image - a real cost on the
  # page that carries donations. That is a recipe-level metatag mapping to add
  # for the Canvas page type, not a test to write around, so it is reported
  # rather than gated. The node scenario below shows what the same tags look
  # like when the mapping IS in place.
  #
  # Every scenario here is tagged @no-javascript: each one reads markup Metatag
  # writes server-side into <head>, or a static file, so none of it depends on
  # page scripts. @javascript is deliberately absent from this suite - in
  # varbase-e2e it switches JS error capture into fail mode rather than labelling
  # anything, and drimage_improved's on-demand derivatives make console 404s
  # normal on a freshly installed site. See tests/TAGS.md.

  # The rows are split into two Examples blocks for one reason only: the speed
  # tag. /countries and /impact measure 12-15 seconds best-of-three on this box
  # while every other page answers in under three, and a tag that claimed
  # otherwise would be a guess. Same split, same reason, in the outlines below.
  @check @seo @acceptance @no-javascript @local @development @staging @production
  Scenario Outline: Check the <name> page declares its own canonical URL
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the element "link[rel='canonical']" with the attribute "href" and the value containing "<canonical>" should exist

    @fast
    Examples: Canvas pages
      | name      | path       | canonical  |
      | About     | /about     | /about     |
      | Programs  | /programs  | /programs  |
      | Resources | /resources | /resources |
      | Events    | /events    | /events    |
      | Donate    | /donate    | /donate    |

    Examples: Canvas pages that carry a listing or a counter set
      | name      | path       | canonical  |
      | Countries | /countries | /countries |
      | Impact    | /impact    | /impact    |

  # The front page is the one canonical worth its own scenario: "/" must not
  # canonicalise to itself, it must point at the real home page alias, or the
  # front page and /home compete for the same content in the index.
  @check @seo @smoke @fast @no-javascript @local @development @staging @production
  Scenario: Verify the front page canonicalises to the Horizon Aid home page
    Given I am an anonymous user
     When I go to "/"
      And I wait until the page is loaded
     Then the element "link[rel='canonical']" with the attribute "href" and the value containing "/home" should exist

  # Each page has to put its own name in the browser tab and the search result,
  # not just the site name. The title step polls, so a title written by the
  # render pipeline late is still caught correctly rather than flakily.
  @check @seo @acceptance @no-javascript @local @development @staging @production
  Scenario Outline: Check the <name> page titles itself
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page title contains "<title>"
     Then the page should have a title

    @fast
    Examples:
      | name      | path       | title        |
      | Home      | /          | Home         |
      | About     | /about     | About        |
      | Programs  | /programs  | Our Programs |
      | Resources | /resources | Resources    |
      | Events    | /events    | Events       |
      | Donate    | /donate    | Donate       |

    Examples: Pages that carry a listing or a counter set
      | name      | path       | title        |
      | Countries | /countries | Countries    |
      | Impact    | /impact    | Our Impact   |

  # Open Graph is what a shared link renders as. The template supplies the
  # organisation identity and the page URL on every page, and both are worth
  # gating: og:url pointing at the wrong page sends every share to the wrong
  # place, and a missing og:site_name drops the organisation's name off the card.
  #
  # The Twitter card type is asserted on a fragment rather than an exact value on
  # purpose: the home page is configured as summary_large_image and the inner
  # pages as summary, which is deliberate metatag configuration, so gating an
  # exact string per page would break the first time a communications lead
  # retunes one page.
  @check @seo @acceptance @no-javascript @local @development @staging @production
  Scenario Outline: Check the <name> page identifies itself for social sharing
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the element "meta[property='og:site_name']" with the attribute "content" and the value containing "Horizon Aid" should exist
      And the element "meta[property='og:url']" with the attribute "content" and the value containing "<og_url>" should exist
      And the element "meta[name='twitter:card']" with the attribute "content" and the value containing "summary" should exist

    @fast
    Examples:
      | name      | path       | og_url     |
      | Home      | /          | /home      |
      | About     | /about     | /about     |
      | Programs  | /programs  | /programs  |
      | Resources | /resources | /resources |
      | Events    | /events    | /events    |
      | Donate    | /donate    | /donate    |

    Examples: Pages that carry a listing or a counter set
      | name      | path       | og_url     |
      | Countries | /countries | /countries |
      | Impact    | /impact    | /impact    |

  # A node page shows the metatag mapping working end to end: the description
  # and the Open Graph title and description are built from the node's own
  # fields. Terms and Conditions is used because it is shipped by the recipe and
  # its text does not change as editors work.
  @check @seo @acceptance @fast @no-javascript @local @development @staging @production
  Scenario: Check a shipped node page carries a description and a complete share preview
    Given I am an anonymous user
     When I go to "/terms-and-conditions"
      And I wait until the page is loaded
     Then the element "meta[name='description']" with the attribute "content" and the value containing "terms that govern the use of this website" should exist
      And the element "meta[property='og:title']" with the attribute "content" and the value containing "Terms and Conditions" should exist
      And the element "meta[property='og:description']" with the attribute "content" and the value containing "terms that govern the use of this website" should exist
      And the element "meta[property='og:url']" with the attribute "content" and the value containing "/terms-and-conditions" should exist
      And the meta tag should exist with the following attributes:
        | property | og:type |
        | content  | article |
      And the "description" meta tag should not contain any HTML tags
      And the "og:description" meta tag should not contain any HTML tags

  # The public pages must NOT carry a noindex directive. A recipe or a launch
  # rehearsal that set one site-wide would be invisible in a browser and would
  # only show up as traffic that never arrives.
  @check @seo @regression @no-javascript @local @development @staging @production
  Scenario Outline: Verify the <name> page is not excluded from search engines
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the meta tag should not exist with the following attributes:
        | name    | robots  |
        | content | noindex |
      And the meta tag should not exist with the following attributes:
        | name    | robots            |
        | content | noindex, nofollow |

    @fast
    Examples:
      | name      | path       |
      | Home      | /          |
      | About     | /about     |
      | Programs  | /programs  |
      | Resources | /resources |
      | Events    | /events    |
      | Donate    | /donate    |

    Examples: Pages that carry a listing or a counter set
      | name      | path       |
      | Countries | /countries |
      | Impact    | /impact    |

  # Mobile-friendliness is a ranking input and an accessibility contract at the
  # same time: the viewport tag has to be present and it must not pin the scale,
  # or a visitor cannot zoom the page.
  @check @seo @a11y @acceptance @no-javascript @local @development @staging @production
  Scenario Outline: Check the <name> page declares a responsive viewport
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the meta tag should exist with the following attributes:
        | name    | viewport                              |
        | content | width=device-width, initial-scale=1.0 |
      And user zoom should be allowed

    @fast
    Examples:
      | name   | path     |
      | Home   | /        |
      | Donate | /donate  |

    Examples: The page that carries the counter set
      | name   | path     |
      | Impact | /impact  |

  # The XML sitemap is what a crawler reads first. It has to be published and
  # served as XML. Its body is not asserted: the browser applies the sitemap's
  # XSL stylesheet, so the DOM a browser test can read is the transformed
  # output, not the source URL list.
  # @api because it asserts only the response status and a response header: no
  # DOM is read, which is also why the XSL-transformed body is irrelevant here.
  @check @seo @acceptance @api @no-javascript @local @development @staging @production
  Scenario: Check the XML sitemap is published as XML
    Given I am an anonymous user
     When I go to "/sitemap.xml"
     Then the response status code should be 200
      And the response header "Content-Type" should contain the value "xml"

  # robots.txt has to be reachable and must not be disallowing the whole site.
  # A blanket "Disallow: /" left behind after a private launch is the cheapest
  # possible way to lose every ranking the site had.
  # Not @api: the last two assertions read the served document's text, not the
  # response metadata.
  @check @seo @smoke @fast @no-javascript @local @development @staging @production
  Scenario: Verify robots.txt is published and does not disallow the whole site
    Given I am an anonymous user
     When I go to "/robots.txt"
     Then the response status code should be 200
      And the response should contain "User-agent: *"
      And I should not see text matching "Disallow: /\s*$"
