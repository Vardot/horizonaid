Feature: Drupal Canvas - Editor - Home and About open in the Canvas editor
      As a site builder taking over a Horizon Aid site
      I want the Home and About Canvas pages to open in the Canvas editor
      So that they can be edited, not just viewed.

  # See 10-01-canvas-pages-listed.feature for why the editor mounts are split per
  # page group: each mount is a full React SPA boot against a heavy component tree,
  # so two per file keeps a CI job inside its time budget.
  #
  # "Opens in the editor" is not a URL check. The varbase-e2e Canvas step navigates
  # to /canvas/editor/canvas_page/<id> and then waits for the editor's own left
  # toolbar "Library" button to mount, retrying the load up to three times, so a
  # tree that fails to hydrate fails the step. The assertions below add the two
  # things a reader of the report needs to see: that the URL really is the editor's,
  # and that the toolbar the builder works from is on screen.

  @check @acceptance @canvas @nightly @local @development @staging @production
  Scenario Outline: Check that the <name> Canvas page opens in the Canvas editor
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I open the "<name>" Canvas page in the editor
     Then the url should match "/canvas/editor/canvas_page/"
      And the "Library" button should be visible within 60 seconds

    Examples: Home and About
      | name  |
      | Home  |
      | About |

  # A Canvas page's rendered output and its editor must agree that the same page
  # works. Reading the page as a visitor and then opening that same page in the
  # editor proves both halves, which neither check does alone: a visitor never
  # notices a tree the editor cannot hydrate, and the editor never notices a
  # template that fails to render.
  #
  # The visitor assertion is deliberately on the page's own heading only. What the
  # About page's calls to action point at is under review in open merge requests, so
  # asserting it here would encode one side of an undecided question.
  @check @acceptance @canvas @nightly @local @development @staging @production
  Scenario: Check that the About Canvas page renders for a visitor and opens for a builder
    Given I am an anonymous user
     When I go to "/about"
      And I wait until the page is loaded
     Then the response status code should be 200
      And "h1" should have text "About Us" within 10 seconds
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I open the "About" Canvas page in the editor
     Then the url should match "/canvas/editor/canvas_page/"
      And the "Library" button should be visible within 60 seconds
