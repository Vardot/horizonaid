@any @regression @content @editorial @acceptance
Feature: Editorial - Country - create, read, update and delete
      As a content editor
      I want to create, read, update and delete a Country through the admin UI
      So that the Country content type is usable end to end, not just installed.

  # Country is the bundle Horizon Aid is built around: the /countries listing, the
  # programme pages and every figure hang off it. The front-end folders only read
  # the shipped demo countries, so without this round trip a required field mapped
  # to the wrong widget, a rich text field that will not persist, or a Save that
  # never returns would ship unnoticed.
  #
  # RULES EVERY FEATURE IN THIS FOLDER FOLLOWS
  #   - It only ever touches nodes it created itself. The 12 shipped demo
  #     countries are what the front-end scenarios assert against and are never
  #     edited or deleted here.
  #   - Persistence is proved fill -> save -> re-read, and the re-read is done at
  #     the public URL as an anonymous visitor wherever the field renders there,
  #     so the assertion is on what a reader gets and not on the still-open form.
  #   - Each scenario deletes what it created, so the site is left as it was found
  #     and a re-run is not blocked by leftovers.
  #   - The varbase-e2e login step does not itself verify the credentials worked,
  #     so every scenario proves the session with "Log out" before asserting
  #     anything else. Without that, a failed login would read as a page that
  #     merely lacks the expected content, and the scenario would pass silently.
  #
  # Field set read from the running site: Title and Summary (required), Our role
  # (required, CKEditor 5), On the ground, three Figure number / Figure
  # description pairs, Featured image and Key partners. Country is NOT under the
  # editorial workflow, so it publishes through the Published checkbox rather than
  # a moderation state.
  #
  # ENVIRONMENT PREREQUISITE: the Autosave Form module must be uninstalled on the
  # site under test, the way the Varbase CI install step does it. It saves an open
  # form every 60 seconds, and the next visit to that form then opens with a
  # "resume editing or discard" dialog whose overlay swallows every click - so one
  # slow scenario silently breaks the next one. It is an environment fact, not
  # something a feature file can assert its way around.

  @check @acceptance @slow @crud @editorial @local @development
  Scenario: Check that a Country can be created and read at its public address
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"

    # CREATE - the three fields the form insists on, plus one figure pair so the
    # multi-value widget is exercised rather than assumed.
     When I go to "/node/add/country"
      And I wait until the page is loaded
     Then I should see "Create Country"
     When I fill in "Title" with "Functional testing suite country"
      And I fill in "Summary" with "A Country created by the Horizon Aid functional testing suite."
      And I fill in the rich text editor field "Our role" with "<p>What we do in the round-trip country.</p>"
      And I fill in "Figure number (value 1)" with "42"
      And I fill in "Figure description (value 1)" with "Round-trip figure"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "Country Functional testing suite country has been created."

    # READ - the node renders its own title, its rich text and its figure, and it
    # does so for the public at the pathauto alias /countries/[title], which is
    # the address the listing and the programme pages link to.
     Then "h1" should have text "Functional testing suite country" within 10 seconds
    Given I am an anonymous user
     When I go to "/countries/functional-testing-suite-country"
      And I wait until the page is loaded
     Then the response status code should be 200
      And "h1" should have text "Functional testing suite country" within 10 seconds
      And I should see "What we do in the round-trip country."
      And I should see "Round-trip figure"

    # DELETE - and confirm both the content overview and the public alias stop
    # offering it. A delete that only clears the listing is not a delete.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+country"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite country" row
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
      And I open the "Purge" link in the "Functional testing suite country" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite country" in the "table" element
    Given I am an anonymous user
     When I go to "/countries/functional-testing-suite-country"
      And I wait until the page is loaded
     Then the response status code should be 404

  # Editing is its own behaviour and gets its own scenario: an editor changes the
  # words on a live country far more often than they create one. The title is
  # deliberately left alone - renaming a Country moves its pathauto alias, and the
  # question here is whether an edit PERSISTS, not how aliases are regenerated.
  @check @acceptance @slow @crud @editorial @local @development
  Scenario: Verify that an edit to a Country persists to the public page
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/country"
      And I wait until the page is loaded
      And I fill in "Title" with "Functional testing suite edited country"
      And I fill in "Summary" with "A Country the suite is about to edit."
      And I fill in the rich text editor field "Our role" with "<p>The first version of our role.</p>"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been created"

    # The edit form is reached the way an editor reaches it, from the content
    # overview, keyed on the unique title. Its values are read back first: an edit
    # form that opens empty would otherwise wipe the node on save.
     When I go to "/admin/content?title=Functional+testing+suite+edited+country"
      And I wait until the page is loaded
     Then I should see "Functional testing suite edited country"
     When I open the "Edit" link in the "Functional testing suite edited country" row
      And I wait until the page is loaded
     Then I should see "Functional testing suite edited country" value in the "edit-title-0-value" input element
      And I should see "A Country the suite is about to edit." value in the "edit-field-description-0-value" input element
     When I fill in "Summary" with "The revised summary of the edited country."
      And I fill in the rich text editor field "Our role" with "<p>The revised version of our role.</p>"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "Country Functional testing suite edited country has been updated."

    # Reload the public page: the new rich text is there and the old text is gone.
    Given I am an anonymous user
     When I go to "/countries/functional-testing-suite-edited-country"
      And I wait until the page is loaded
     Then the response status code should be 200
      And I should see "The revised version of our role."
      And I should not see "The first version of our role."

    # Clean up the country this scenario created.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+edited+country"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite edited country" row
      And I wait until the page is loaded
      And I click the "Delete" button
      And I wait until the page is loaded
     Then I should see "has been deleted"
    # This site keeps deleted content in the trash, so the delete above is a SOFT
    # delete: the node and its URL alias both still exist. Purging finishes the job,
    # and it is what makes this folder re-runnable at all - a second run would
    # otherwise find the alias taken and be handed "...-0" instead.
     When I go to "/admin/content/trash"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite edited country" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite edited country" in the "table" element


  # A required field is only a required field if saving without it is refused.
  # Browser validation is switched off first so the assertion lands on Drupal's
  # server-side validation, which is the half that actually protects the data.
  @check @regression @slow @crud @editorial @local @development
  Scenario: Verify that a Country cannot be saved without its required fields
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/country"
      And I wait until the page is loaded
    Given browser validation for the form "#node-country-form" is disabled
     When I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "Title field is required"
      And I should see "Summary field is required"
      And I should see "Our role field is required"
      And I should not see "has been created"

  # An unpublished Country must not be readable by the public. Country is not
  # moderated, so this is the plain Published checkbox, and it is asserted from a
  # second, anonymous session rather than from the editor's own, which would see
  # unpublished content either way.
  #
  # The refusal is a 404, not a 403: this site answers a request for content the
  # visitor may not see with "not found", which is the stronger answer because it
  # does not confirm that the content exists. Administrative paths still answer
  # 403 - see 11-01-anonymous-boundaries.feature.
  @check @regression @slow @security @crud @editorial @local @development
  Scenario: Verify that an unpublished Country is not readable by a visitor
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/country"
      And I wait until the page is loaded
      And I fill in "Title" with "Functional testing suite unpublished country"
      And I fill in "Summary" with "This country must never be readable by an anonymous visitor."
      And I fill in the rich text editor field "Our role" with "<p>Unpublished round-trip country.</p>"
      And I uncheck "Published"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been created"
    Given I am an anonymous user
     When I go to "/countries/functional-testing-suite-unpublished-country"
      And I wait until the page is loaded
     Then the response status code should be 404
     When I go to "/countries"
      And I wait until the page is loaded
     Then I should not see "Functional testing suite unpublished country"

    # Clean up the unpublished country this scenario created.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+unpublished+country"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite unpublished country" row
      And I wait until the page is loaded
      And I click the "Delete" button
      And I wait until the page is loaded
     Then I should see "has been deleted"
    # This site keeps deleted content in the trash, so the delete above is a SOFT
    # delete: the node and its URL alias both still exist. Purging finishes the job,
    # and it is what makes this folder re-runnable at all - a second run would
    # otherwise find the alias taken and be handed "...-0" instead.
     When I go to "/admin/content/trash"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite unpublished country" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite unpublished country" in the "table" element

