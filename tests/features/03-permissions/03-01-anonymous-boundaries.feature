Feature: Permissions - Anonymous visitors stay outside the administration
      As a security-conscious site owner
      I want anonymous visitors kept out of every administrative surface
      So that a permission regression in the recipe cannot expose the back office.

  # Asserted on the response status, not on wording or a redirect: a theme can
  # word its 403 page however it likes and a security module may or may not
  # bounce the visitor to the login form, but a 200 on an administrative path
  # is a permission defect whatever the page shows. Each protected path is its
  # own named row so a single flipped permission fails precisely. The public
  # site staying open is proven by the front-end suite.

  @check @security @local @development @staging @production
  Scenario Outline: An anonymous visitor is refused <area>
    Given I am an anonymous user
     When I go to "<path>"
      And I wait until the page is loaded
     Then the response status code should be 403

    Examples: Protected administrative areas
      | area                  | path                      |
      | the administration    | /admin                    |
      | the content listing   | /admin/content            |
      | the people listing    | /admin/people             |
      | the permissions page  | /admin/people/permissions |
      | the modules page      | /admin/modules            |
      | the status report     | /admin/reports/status     |
      | the page form         | /node/add/page            |

  @check @local @development @staging @production
  Scenario: The login page is reachable and presents the form
    Given I am an anonymous user
     When I go to "/user/login"
      And I wait until the page is loaded
     Then "#edit-name" should be visible
      And "#edit-pass" should be visible
