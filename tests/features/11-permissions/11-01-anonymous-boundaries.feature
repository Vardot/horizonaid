Feature: Permissions - Anonymous - the editorial back end is closed to visitors
      As a security-conscious site owner
      I want anonymous visitors kept out of every administrative surface
      So that a permission regression in the recipe cannot expose the back office.

  # Asserted on the response status, not on wording or a redirect: a theme can word
  # its 403 page however it likes and a security module may or may not bounce the
  # visitor to the login form, but a 200 on an administrative path is a permission
  # defect whatever the page shows. Each protected path is its own named row so a
  # single flipped permission fails precisely.
  #
  # Every refusal is paired with a positive: the same anonymous visitor must still
  # be able to read the public site and use the login form. A file that only ever
  # asserted refusals would pass on a site that was entirely broken.

  @check @regression @fast @security @permissions @local @development @staging @production
  Scenario Outline: Check that an anonymous visitor is refused <area>
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the response status code should be 403

    Examples: Protected administrative areas
      | area                  | path                      |
      | the administration    | /admin                    |
      | the content listing   | /admin/content            |
      | the media overview    | /admin/content/media      |
      | the Canvas pages      | /admin/content/pages      |
      | the people listing    | /admin/people             |
      | the permissions page  | /admin/people/permissions |
      | the modules page      | /admin/modules            |
      | the appearance page   | /admin/appearance         |
      | the configuration     | /admin/config             |
      | the status report     | /admin/reports/status     |
      | taxonomy admin        | /admin/structure/taxonomy |
      | content type admin    | /admin/structure/types    |

  # No Horizon Aid content type may be created by the public. Each bundle is its own
  # row: a create permission granted to anonymous by accident on one bundle would
  # otherwise hide behind the eleven that are still closed.
  @check @regression @fast @security @permissions @local @development @staging @production
  Scenario Outline: Check that an anonymous visitor cannot create <name> content
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the response status code should be 403

    Examples: Horizon Aid content types
      | name         | path              |
      | Country      | /node/add/country |
      | Program      | /node/add/program |
      | Event        | /node/add/event   |
      | Blog post    | /node/add/blog    |
      | Utility page | /node/add/page    |

  # The published demo content is public to READ. This is the positive half that
  # keeps every refusal in this file honest, and it is asserted on the rendered
  # heading rather than on the status alone, so a 200 that renders an error page
  # would still fail.
  #
  # These paths point at shipped demo nodes and nothing here writes to them.
  @check @smoke @fast @security @permissions @local @development @staging @production
  Scenario Outline: Check that an anonymous visitor can read the <name>
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the response status code should be 200
      And "h1" should have text "<title>" within 10 seconds

    Examples: Shipped demo content
      | name          | path                                      | title                              |
      | country page  | /countries/colombia                       | Colombia                           |
      | program page  | /programs/women                           | Women                              |
      | resource page | /resources/emergency-relief-flooded-states | Emergency relief in flooded states |
      | event page    | /events/supply-chain-resilience-review    | Supply chain resilience review     |

  # ... and closed to EDIT. The edit and delete routes of EXISTING content are
  # asserted on media rather than on nodes, and that is deliberate: an entity form
  # route is addressed by entity id, an alias only ever covers the canonical page
  # (so /countries/colombia/edit is a path that does not exist and proves nothing),
  # and a node id cannot be written here portably - this site answers a request for
  # content a visitor may not see with 404, so the id of a PUBLISHED node would have
  # to be hard-coded to get a permission answer at all. Media 1 is shipped by the
  # recipe on every install and is public, so its form routes give the honest
  # answer: the route refuses, 403.
  @check @regression @fast @security @permissions @local @development @staging @production
  Scenario Outline: Check that an anonymous visitor is refused the <name> route
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the response status code should be 403

    Examples: Entity form routes
      | name             | path              |
      | media edit       | /media/1/edit     |
      | media delete     | /media/1/delete   |
      | media creation   | /media/add/image  |
      | the media grid   | /admin/content/media-grid |

  # A Canvas page is public to read at its own path and closed to edit. The editor
  # route is asserted as well as the overview, because the overview being closed
  # would not stop a visitor who guessed the editor URL.
  @check @smoke @fast @security @permissions @local @development @staging @production
  Scenario: Check that an anonymous visitor can read a Canvas page but not edit it
    Given I am an anonymous user
     When I go to "/about"
      And I wait until the page is loaded
     Then the response status code should be 200
      And "h1" should have text "About Us" within 10 seconds
     When I go to "/admin/content/pages"
      And I wait until the page is loaded
     Then the response status code should be 403
     When I go to "/canvas/editor/canvas_page/1"
      And I wait until the page is loaded
     Then the response status code should be 403

  # The login form is the one administrative-looking screen the public must reach,
  # and it is the positive half of this whole file: the site is closed for editing,
  # not closed.
  @check @smoke @fast @security @permissions @local @development @staging @production
  Scenario: Check that the login page is reachable and presents the form
    Given I am an anonymous user
     When I go to "/user/login"
      And I wait until the page is loaded
     Then the response status code should be 200
    # Both fields are addressed by the labels the visitor reads, which is also what
    # keeps this honest if the theme rearranges the form.
      And I should see a "Username or email address" element
      And I should see a "Password" element
