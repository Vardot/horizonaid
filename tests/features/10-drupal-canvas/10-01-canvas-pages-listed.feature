@any @regression @canvas @content
Feature: Drupal Canvas - Pages - the shipped Horizon Aid Canvas pages are listed
      As a site builder taking over a Horizon Aid site
      I want every Canvas page the recipe ships to be listed for editing
      So that the pages can be maintained, not just viewed.

  # Horizon Aid's eight pages - Home, About, Countries, Our Programs, Resources,
  # Events, Our Impact and Donate - are canvas_page entities whose component trees
  # the recipe ships as configuration. A page can render perfectly for a visitor
  # and still be missing from the editing surface, or fail to open in the editor,
  # if a component the tree references is gone or its props no longer validate.
  # That failure is invisible from the front end and total for whoever has to edit
  # the page, which makes it the highest-value Canvas assertion for a site
  # template.
  #
  # The editor is a heavy React SPA, so opening it is slow by nature and each page
  # group gets its own 10-0N-*.feature and therefore its own CI job: a shared
  # runner under load can burn a whole job on two or three editor mounts before the
  # rest ever get a turn. This file only proves the pages are LISTED, which is fast;
  # the editor mounts are split out per page group.

  @check @smoke @canvas @local @development @staging @production
  Scenario: Check that every Canvas page the recipe ships is listed for a site builder
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content/pages"
      And I wait until the page is loaded
    # Asserted on the page's own heading and its rows, not on a response status: the
    # varbase-e2e status step re-fetches the URL without the browser session, so on an
    # authenticated screen it reports what an anonymous visitor gets (403).
     Then "h1" should have text "Pages" within 10 seconds
      And I should see "Home"
      And I should see "About"
      And I should see "Countries"
      And I should see "Our Programs"
      And I should see "Resources"
      And I should see "Events"
      And I should see "Our Impact"
      And I should see "Donate"

  # A listed page is only editable if its row offers the editor. The operation link
  # is asserted per page, keyed on the page title, so one page losing its editor
  # link fails on its own row instead of hiding behind the other seven. This stays
  # on the listing on purpose: mounting the editor is the expensive part and lives
  # in the 10-02 to 10-05 files.
  @check @smoke @canvas @local @development @staging @production
  Scenario Outline: Check that the "<title>" Canvas page row offers the editor
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content/pages"
      And I wait until the page is loaded
     Then I should see the "Edit" operation for the "<title>" content

    Examples: Horizon Aid Canvas pages
      | title        |
      | Home         |
      | About        |
      | Countries    |
      | Our Programs |
      | Resources    |
      | Events       |
      | Our Impact   |
      | Donate       |
