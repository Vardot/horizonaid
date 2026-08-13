Feature: Drupal Canvas - Editor - Countries and Our Programs open in the Canvas editor
      As a site builder taking over a Horizon Aid site
      I want the Countries and Our Programs Canvas pages to open in the Canvas editor
      So that they can be edited, not just viewed.

  # See 10-01-canvas-pages-listed.feature for why the editor mounts are split per
  # page group, and 10-02 for what "opens in the editor" actually proves: the
  # varbase-e2e Canvas step waits for the editor's own "Library" toolbar button to
  # mount, so a component tree that fails to hydrate fails the step rather than
  # passing on a URL that merely looks right.

  @check @acceptance @canvas @nightly @local @development @staging @production
  Scenario Outline: Check that the <name> Canvas page opens in the Canvas editor
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I open the "<name>" Canvas page in the editor
     Then the url should match "/canvas/editor/canvas_page/"
      And the "Library" button should be visible within 60 seconds

    Examples: Countries and Our Programs
      | name |
      | Countries |
      | Our Programs |
