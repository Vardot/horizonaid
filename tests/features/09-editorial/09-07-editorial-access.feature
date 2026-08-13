Feature: Editorial - Access - the webmaster reaches the editorial surfaces
      As a site builder
      I want the admin account to reach the content, media and page-creation surfaces
      So that the editorial toolchain the recipe wires up actually works after install.

  # These scenarios prove the editorial stack (admin UI, content listing, media
  # library, node forms) survives a recipe re-apply. They create nothing: the depth
  # is in 09-01 to 09-06, and a site template only has to prove its own wiring
  # reaches these screens.
  #
  # They are the cheapest early-warning in the folder. If the recipe leaves a view
  # or a form display broken, these fail in seconds, before a CRUD scenario spends
  # a minute discovering the same thing the slow way.
  #
  # These scenarios assert on the screen's own heading text, never on a response
  # status: the varbase-e2e "response status code" step re-fetches the current URL
  # WITHOUT the browser session, so on an authenticated page it would report what an
  # anonymous visitor gets (403) and fail an entirely healthy admin screen. Status
  # assertions belong in the anonymous scenarios in 11-01, where they are true.
  #
  # Each one asserts the screen's own content AND the absence of the two ways
  # Drupal fails silently on an admin page - "Access denied" and the generic
  # unexpected-error page - because both render with an ordinary layout and would
  # otherwise read as a page that simply lacks the expected text.

  @check @regression @slow @editorial @local @development
  Scenario: Check that the webmaster reaches the content listing
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content"
      And I wait until the page is loaded
     Then I should see "Content"
      And I should not see "Access denied"
      And I should not see "The website encountered an unexpected error"

  @check @regression @editorial @local @development
  Scenario: Check that the webmaster reaches the media library
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content/media"
      And I wait until the page is loaded
     Then I should see "Media"
      And I should not see "Access denied"
      And I should not see "The website encountered an unexpected error"

  @check @regression @slow @editorial @local @development
  Scenario: Check that the webmaster can start a new page
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/page"
      And I wait until the page is loaded
     Then I should see "Create Utility page"
      And I should see a "Title" element
      And I should not see "Access denied"
      And I should not see "The website encountered an unexpected error"

  # Every content type the recipe ships must offer its creation form, named as the
  # editor sees it. A bundle whose form display is broken by a recipe change fails
  # on its own row here rather than taking a whole CRUD scenario down with it.
  @check @regression @slow @editorial @local @development
  Scenario Outline: Check that the webmaster can start a new <name>
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "<path>"
      And I wait until the page is loaded
     Then I should see "Create <name>"
      And I should see a "Title" element
      And I should not see "The website encountered an unexpected error"

    Examples: Horizon Aid content types
      | name         | path              |
      | Country      | /node/add/country |
      | Program      | /node/add/program |
      | Event        | /node/add/event   |
      | Blog post    | /node/add/blog    |
      | Utility page | /node/add/page    |
