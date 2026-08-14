@any @regression @auth @security @acceptance
Feature: Permissions - Roles - what each Horizon Aid role may and may not do
      As the owner of a Horizon Aid site
      I want each role held to the permissions the recipe grants it
      So that a permission added or lost when the recipe changes is caught.

  # THE ACCOUNTS THESE SCENARIOS NEED
  #
  # The six testing users cucumber.js lists in worldParameters.users - Normal user,
  # Content editor, Content admin, SEO admin, Site admin, Super admin - are the ones
  # scripts/add-testing-users.sh in the Horizon Aid recipe creates, with the role
  # display names as usernames. Run that script (or the equivalent drush
  # user:create / user:role:add pair) before this file runs. Without the accounts the
  # login simply does not happen, which is why every scenario asserts "Log out"
  # first: a missing account then fails the scenario instead of quietly turning the
  # role assertions into assertions about an anonymous visitor.
  #
  # WHY THESE ASSERT ON THE PAGE AND NOT ON A STATUS CODE
  #
  # The varbase-e2e "response status code" step re-fetches the current URL WITHOUT
  # the browser session, so inside a logged-in scenario it always reports what an
  # anonymous visitor would get. Every assertion here therefore reads the rendered
  # page: an allowed screen is proved by its own heading, and a refusal by the wording
  # of Drupal's own access-denied page. The refusal is asserted on that WORDING rather
  # than on a heading because the page a refused user gets depends on which theme they
  # may see: a role with admin-theme access gets an "Access denied" heading, while a
  # plain authenticated account gets the front-end 403 page, which on this theme has
  # no heading at all. The sentence is on both. 11-01 keeps the status-code
  # assertions, where the session-free request is exactly the right one.
  #
  # WHAT THESE ASSERT, AND WHY
  #
  # The expectations were read off the running site, one path at a time, with one
  # account per role. They encode the grants the recipe actually makes:
  #
  #   Content editor, Content admin and SEO admin author the editorial bundles -
  #   Blog post, Event and Utility page - and reach the content and media overviews.
  #
  #   SEO admin is the sharpest boundary in the template: it authors and tunes
  #   content and has no business in Drupal Canvas. It holds neither the Canvas pages
  #   overview nor the Canvas editor.
  #
  #   Site admin administers people and taxonomy and may open the Canvas pages, but
  #   it is not a superuser: modules, appearance and the status report are refused.
  #
  #   Normal user gets nothing editorial at all. That is the boundary a site with
  #   open registration depends on.
  #
  # WHAT IS DELIBERATELY NOT ASSERTED HERE
  #
  # Country and Program authoring by the shipped roles. On this build no role except
  # the administrator ones can create or edit either bundle, which reads as a gap in
  # the recipe's permission grants rather than an intended boundary, since Country and
  # Program are the two bundles the whole template is about. It is reported to the
  # maintainers instead of being frozen into a passing test: encoding it here would
  # make the eventual fix look like a regression.
  #
  # Every role gets its refusals AND one thing it must still be able to do. A role
  # locked out of everything would otherwise pass every refusal in the file.

  @check @regression @slow @security @permissions @local @development
  Scenario: Check that a Content editor may author the editorial content types
    Given I am a logged in user with the "Content editor" user
     Then I should see "Log out"
     When I go to "/node/add/blog"
      And I wait until the page is loaded
     Then "h1" should have text "Create Blog post" within 10 seconds
     When I go to "/node/add/event"
      And I wait until the page is loaded
     Then "h1" should have text "Create Event" within 10 seconds
     When I go to "/node/add/page"
      And I wait until the page is loaded
     Then "h1" should have text "Create Utility page" within 10 seconds
     When I go to "/admin/content"
      And I wait until the page is loaded
     Then "h1" should have text "Content" within 10 seconds
     When I go to "/admin/content/media"
      And I wait until the page is loaded
     Then "h1" should have text "Media" within 10 seconds

  @check @regression @security @permissions @local @development
  Scenario Outline: Check that a Content editor is refused <area>
    Given I am a logged in user with the "Content editor" user
     Then I should see "Log out"
     When I go to "<path>"
      And I wait until the page is loaded
     Then I should see "You are not authorized to access this page."

    Examples: Beyond a Content editor's remit
      | area                | path                   |
      | the people listing  | /admin/people          |
      | the modules page    | /admin/modules         |
      | the appearance page | /admin/appearance      |
      | content type admin  | /admin/structure/types |
      | the status report   | /admin/reports/status  |

  # SEO admin authors and tunes content and must not reach Drupal Canvas at all. Both
  # halves are in one scenario so the pair cannot drift apart.
  @check @regression @slow @security @permissions @local @development
  Scenario: Check that an SEO admin authors content but cannot reach Drupal Canvas
    Given I am a logged in user with the "SEO admin" user
     Then I should see "Log out"
     When I go to "/node/add/blog"
      And I wait until the page is loaded
     Then "h1" should have text "Create Blog post" within 10 seconds
     When I go to "/admin/content"
      And I wait until the page is loaded
     Then "h1" should have text "Content" within 10 seconds
     When I go to "/admin/content/pages"
      And I wait until the page is loaded
     Then I should see "You are not authorized to access this page."
     When I go to "/canvas/editor/canvas_page/1"
      And I wait until the page is loaded
     Then I should see "You are not authorized to access this page."

  # Site admin is the role that administers the site's people and its Canvas pages,
  # and it is NOT a superuser: the modules, appearance and status screens stay shut.
  @check @regression @security @permissions @local @development
  Scenario: Check that a Site admin administers people and the Canvas pages
    Given I am a logged in user with the "Site admin" user
     Then I should see "Log out"
     When I go to "/admin/people"
      And I wait until the page is loaded
     Then "h1" should have text "People" within 10 seconds
     When I go to "/admin/structure/taxonomy"
      And I wait until the page is loaded
     Then "h1" should have text "Taxonomy" within 10 seconds
     When I go to "/admin/content/pages"
      And I wait until the page is loaded
     Then "h1" should have text "Pages" within 10 seconds
      And I should see "Home"

  @check @regression @fast @security @permissions @local @development
  Scenario Outline: Check that a Site admin is refused <area>
    Given I am a logged in user with the "Site admin" user
     Then I should see "Log out"
     When I go to "<path>"
      And I wait until the page is loaded
     Then I should see "You are not authorized to access this page."

    Examples: Beyond a Site admin's remit
      | area                | path                   |
      | the modules page    | /admin/modules         |
      | the appearance page | /admin/appearance      |
      | content type admin  | /admin/structure/types |
      | the status report   | /admin/reports/status  |

  # Content admin owns the vocabularies the listings filter on, and stops short of
  # user administration and the module list.
  @check @regression @slow @security @permissions @local @development
  Scenario: Check that a Content admin administers taxonomy but not users or modules
    Given I am a logged in user with the "Content admin" user
     Then I should see "Log out"
     When I go to "/admin/structure/taxonomy"
      And I wait until the page is loaded
     Then "h1" should have text "Taxonomy" within 10 seconds
     When I go to "/node/add/blog"
      And I wait until the page is loaded
     Then "h1" should have text "Create Blog post" within 10 seconds
     When I go to "/admin/people"
      And I wait until the page is loaded
     Then I should see "You are not authorized to access this page."
     When I go to "/admin/modules"
      And I wait until the page is loaded
     Then I should see "You are not authorized to access this page."

  # A plain authenticated account may read the public site and nothing more. The read
  # half is asserted first: an account that could not even see the country listing
  # would pass every refusal below for the wrong reason.
  @check @regression @slow @security @permissions @local @development
  Scenario: Check that a Normal user may read the site and nothing more
    Given I am a logged in user with the "Normal user" user
     Then I should see "Log out"
     When I go to "/countries"
      And I wait until the page is loaded
     Then I should see "Colombia"
     When I go to "/programs"
      And I wait until the page is loaded
     Then I should see "Women"

  @check @regression @security @permissions @local @development
  Scenario Outline: Check that a Normal user is refused <area>
    Given I am a logged in user with the "Normal user" user
     Then I should see "Log out"
     When I go to "<path>"
      And I wait until the page is loaded
     Then I should see "You are not authorized to access this page."

    Examples: The whole editorial back end
      | area                | path                 |
      | the administration  | /admin               |
      | the content listing | /admin/content       |
      | the media overview  | /admin/content/media |
      | the Canvas pages    | /admin/content/pages |
      | the Blog post form  | /node/add/blog       |
      | the Country form    | /node/add/country    |
      | the people listing  | /admin/people        |

  # Super admin is the account that must be able to do everything, including the two
  # bundles no other role can author. It is the positive counterweight to every
  # refusal above: if these were refused too, the site would be broken rather than
  # locked down.
  @check @regression @slow @security @permissions @local @development
  Scenario Outline: Check that a Super admin reaches <area>
    Given I am a logged in user with the "Super admin" user
     Then I should see "Log out"
     When I go to "<path>"
      And I wait until the page is loaded
     Then "h1" should have text "<heading>" within 10 seconds
      And I should not see "You are not authorized to access this page."

    Examples: The whole administration
      | area                | path                 | heading         |
      | the content listing  | /admin/content      | Content         |
      | the Canvas pages     | /admin/content/pages | Pages          |
      | the Country form     | /node/add/country   | Create Country  |
      | the Program form     | /node/add/program   | Create Program  |
      | the people listing   | /admin/people       | People          |
      | the modules page     | /admin/modules      | Extend          |
