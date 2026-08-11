Feature: Editorial - The webmaster reaches the editorial surfaces
      As a site builder
      I want the admin account to reach the content, media and page-creation surfaces
      So that the editorial toolchain the recipe wires up actually works after install.

  # These scenarios prove the editorial stack (admin UI, content listing, node
  # forms) survives a recipe re-apply. They create nothing: the CRUD depth lives
  # in the Varbase Project suites; a site template only has to prove its own
  # wiring reaches them.

  @check @local @development
  Scenario: The webmaster reaches the content listing
    Given I am a logged in user with the "webmaster" user
     When I go to "/admin/content"
      And I wait until the page is loaded
     Then I should see "Content"
      And I should not see "Access denied"
      And I should not see "The website encountered an unexpected error"

  @check @local @development
  Scenario: The webmaster reaches the media library
    Given I am a logged in user with the "webmaster" user
     When I go to "/admin/content/media"
      And I wait until the page is loaded
     Then I should not see "Access denied"
      And I should not see "The website encountered an unexpected error"

  @check @local @development
  Scenario: The webmaster can start a new page
    Given I am a logged in user with the "webmaster" user
     When I go to "/node/add/page"
      And I wait until the page is loaded
     Then I should see "Title"
      And I should not see "Access denied"
      And I should not see "The website encountered an unexpected error"
