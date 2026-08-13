Feature: Editorial - Utility page - create, read, update and delete
      As a content editor
      I want to create, read, update and delete a Utility page through the admin UI
      So that standalone pages such as Privacy or Terms work end to end.

  # Utility page is the bundle Horizon Aid uses for the standalone pages a site
  # needs but nobody browses to: Privacy policy, Terms and conditions. It carries
  # the Varbase editorial workflow, so it saves into a moderation state (default
  # Draft), and its pathauto pattern is the bare /[title], which means the page
  # sits at the site root and collides with anything else that wants that address.
  # Both of those are asserted here.
  #
  # The 3 shipped demo utility pages are never edited or deleted here.
  #
  # The Description field is addressed by its id, not by its label: the Utility page
  # form is the only one that also offers a menu link, whose own "Description" field
  # carries the same label, so a label lookup matches two fields and fails.
  #
  # NOTE ON THE READ ASSERTIONS: a Utility page does not render its own title
  # anywhere in the page body on this build - no h1, no h2, only the browser tab
  # title - so the read is asserted on the body text the editor typed, which does
  # render. The shipped Terms and conditions page looks like it has a heading only
  # because its own body content starts with one. That missing heading is reported
  # to the maintainers; asserting a title that is not there would just paint the gap
  # green, and asserting its absence would freeze the gap in place.
  #
  # ENVIRONMENT PREREQUISITE: the Autosave Form module must be uninstalled on the
  # site under test, the way the Varbase CI install step does it. It saves an open
  # form every 60 seconds, and the next visit to that form then opens with a
  # "resume editing or discard" dialog whose overlay swallows every click - so one
  # slow scenario silently breaks the next one. It is an environment fact, not
  # something a feature file can assert its way around.

  @check @acceptance @crud @editorial @local @development
  Scenario: Check that a Utility page can be created, published and read by a visitor
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"

    # CREATE - Title and Description are required; Content is the rich text body;
    # "Published" is chosen explicitly because the workflow's default is Draft.
     When I go to "/node/add/page"
      And I wait until the page is loaded
     Then I should see "Create Utility page"
     When I fill in "Title" with "Functional testing suite utility page"
      And I fill in "edit-field-description-0-value" with "A Utility page created by the Horizon Aid functional testing suite." by its "id" attribute
      And I fill in the rich text editor field "Content" with "<p>The body of the round-trip utility page.</p>"
      And I select "Published" from "#edit-moderation-state-0-state"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "Utility page Functional testing suite utility page has been created."

    # READ - re-read the page at its root-level alias as an anonymous visitor, so
    # the assertion is on what the public gets.
    Given I am an anonymous user
     When I go to "/functional-testing-suite-utility-page"
      And I wait until the page is loaded
     Then the response status code should be 200
      And I should see "The body of the round-trip utility page."

    # DELETE - and confirm the alias stops resolving for the public.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+utility+page"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite utility page" row
      And I wait until the page is loaded
     Then I should see "Are you sure you want to delete"
     When I click the "Delete" button
      And I wait until the page is loaded
     Then I should see "has been deleted"
    # This site keeps deleted content in the trash, so the delete above is a SOFT
    # delete: the node and its URL alias both still exist. Purging finishes the job,
    # and it is what makes this folder re-runnable at all - a second run would
    # otherwise find the alias taken and be handed "...-0" instead.
     When I go to "/admin/content/trash"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite utility page" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite utility page" in the "table" element
    Given I am an anonymous user
     When I go to "/functional-testing-suite-utility-page"
      And I wait until the page is loaded
     Then the response status code should be 404

  # Editing the body of a policy page is the one edit these pages ever get, and it
  # is the one that has legal weight, so it is proved on the public page after a
  # re-read rather than on the form that submitted it.
  @check @acceptance @slow @crud @editorial @local @development
  Scenario: Verify that an edit to a Utility page persists to the public page
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/page"
      And I wait until the page is loaded
      And I fill in "Title" with "Functional testing suite edited utility page"
      And I fill in "edit-field-description-0-value" with "A Utility page the suite is about to edit." by its "id" attribute
      And I fill in the rich text editor field "Content" with "<p>The first version of the page body.</p>"
      And I select "Published" from "#edit-moderation-state-0-state"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been created"
     When I go to "/admin/content?title=Functional+testing+suite+edited+utility+page"
      And I wait until the page is loaded
      And I open the "Edit" link in the "Functional testing suite edited utility page" row
      And I wait until the page is loaded
     Then I should see "Functional testing suite edited utility page" value in the "edit-title-0-value" input element
      And I should see "A Utility page the suite is about to edit." value in the "edit-field-description-0-value" input element
     When I fill in the rich text editor field "Content" with "<p>The revised version of the page body.</p>"
      And I select "Published" from "#edit-moderation-state-0-state"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been updated"
    Given I am an anonymous user
     When I go to "/functional-testing-suite-edited-utility-page"
      And I wait until the page is loaded
     Then the response status code should be 200
      And I should see "The revised version of the page body."
      And I should not see "The first version of the page body."

    # Clean up the page this scenario created.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+edited+utility+page"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite edited utility page" row
      And I wait until the page is loaded
      And I click the "Delete" button
      And I wait until the page is loaded
     Then I should see "has been deleted"
    # Purge it from the trash as well, so the site is left exactly as it was found.
     When I go to "/admin/content/trash"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite edited utility page" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite edited utility page" in the "table" element

  @check @regression @slow @crud @editorial @local @development
  Scenario: Verify that a Utility page cannot be saved without its required fields
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/page"
      And I wait until the page is loaded
    Given browser validation for the form "#node-page-form" is disabled
     When I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "Title field is required"
      And I should see "Description field is required"
      And I should not see "has been created"

  # A Utility page left in the workflow's default Draft state must not be readable
  # by the public. On a Privacy or Terms page that boundary is the difference
  # between a policy being in force and a policy being a rough note.
  @check @regression @slow @security @crud @editorial @local @development
  Scenario: Verify that a draft Utility page is not readable by a visitor
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/page"
      And I wait until the page is loaded
      And I fill in "Title" with "Functional testing suite draft utility page"
      And I fill in "edit-field-description-0-value" with "This draft must never be readable by an anonymous visitor." by its "id" attribute
      And I select "Draft" from "#edit-moderation-state-0-state"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been created"
    Given I am an anonymous user
     When I go to "/functional-testing-suite-draft-utility-page"
      And I wait until the page is loaded
     Then the response status code should be 404

    # Clean up the draft this scenario created.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+draft+utility+page"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite draft utility page" row
      And I wait until the page is loaded
      And I click the "Delete" button
      And I wait until the page is loaded
     Then I should see "has been deleted"
    # Purge it from the trash as well, so the site is left exactly as it was found.
     When I go to "/admin/content/trash"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite draft utility page" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite draft utility page" in the "table" element
