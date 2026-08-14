@any @regression @content @editorial @acceptance
Feature: Editorial - Program - create, read, update and delete
      As a content editor
      I want to create, read, update and delete a Program through the admin UI
      So that the Program content type and its country references work end to end.

  # Program is what a donor decides on, and it is the bundle that REFERENCES the
  # rest of the template: a Sector term and the Countries the work runs in. A
  # Program saved without those references is a page that says nothing about where
  # the money goes, which is exactly the failure a shipped template must not have.
  #
  # The Countries reference is filled by country title, not by node id, so the
  # scenario stays portable across installs. It points at Colombia, one of the 12
  # shipped demo countries, and never edits it.
  #
  # The 5 shipped demo programs are never edited or deleted here. Program is NOT
  # under the editorial workflow, so it publishes through the Published checkbox.
  #
  # ENVIRONMENT PREREQUISITE: the Autosave Form module must be uninstalled on the
  # site under test, the way the Varbase CI install step does it. It saves an open
  # form every 60 seconds, and the next visit to that form then opens with a
  # "resume editing or discard" dialog whose overlay swallows every click - so one
  # slow scenario silently breaks the next one. It is an environment fact, not
  # something a feature file can assert its way around.

  @check @acceptance @slow @crud @editorial @local @development
  Scenario: Check that a Program can be created and read at its public address
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"

    # CREATE - title, summary, rich text, a Sector term and a Country reference.
     When I go to "/node/add/program"
      And I wait until the page is loaded
     Then I should see "Create Program"
     When I fill in "Title" with "Functional testing suite program"
      And I fill in "Summary" with "A Program created by the Horizon Aid functional testing suite."
      And I fill in the rich text editor field "Content" with "<p>What the round-trip program does.</p>"
      And I select "Education" from "field_program_type"
      And I fill in "field_countries[0][target_id]" with "Colombia"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "Program Functional testing suite program has been created."

    # READ - the program renders its title and its rich text for the public at the
    # pathauto alias /programs/[title].
     Then "h1" should have text "Functional testing suite program" within 10 seconds
    Given I am an anonymous user
     When I go to "/programs/functional-testing-suite-program"
      And I wait until the page is loaded
     Then the response status code should be 200
      And "h1" should have text "Functional testing suite program" within 10 seconds
      And I should see "What the round-trip program does."

    # DELETE - and confirm the public alias stops resolving.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+program"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite program" row
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
      And I open the "Purge" link in the "Functional testing suite program" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite program" in the "table" element
    Given I am an anonymous user
     When I go to "/programs/functional-testing-suite-program"
      And I wait until the page is loaded
     Then the response status code should be 404

  # The Sector term and the Countries reference are the two values an editor is
  # most likely to get wrong and least likely to notice, because a wrong reference
  # still saves. They are read back off the reopened edit form, which is where the
  # stored value is visible regardless of what the Canvas content template chooses
  # to render.
  @check @acceptance @slow @crud @editorial @local @development
  Scenario: Verify that a Program keeps its Sector and its country reference
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/program"
      And I wait until the page is loaded
      And I fill in "Title" with "Functional testing suite referenced program"
      And I fill in "Summary" with "A Program whose references the suite reads back."
      And I select "Agriculture" from "field_program_type"
      And I fill in "field_countries[0][target_id]" with "Colombia"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been created"

    # Reopen the form the way an editor does and read the stored values back.
     When I go to "/admin/content?title=Functional+testing+suite+referenced+program"
      And I wait until the page is loaded
      And I open the "Edit" link in the "Functional testing suite referenced program" row
      And I wait until the page is loaded
     Then the option "Agriculture" should be selected within the select element "[name='field_program_type']"
    # The autocomplete stores "Colombia (nid)", and the nid differs per install, so
    # the assertion is on the country NAME inside the stored value.
      And I should see "Colombia" value in the "edit-field-countries-0-target-id" input element

    # Changing the Sector must persist too, otherwise the sector filter on the
    # programmes listing is decoration.
     When I select "Health" from "field_program_type"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been updated"
     When I go to "/admin/content?title=Functional+testing+suite+referenced+program"
      And I wait until the page is loaded
      And I open the "Edit" link in the "Functional testing suite referenced program" row
      And I wait until the page is loaded
     Then the option "Health" should be selected within the select element "[name='field_program_type']"
      And the option "Agriculture" should not be selected within the select element "[name='field_program_type']"

    # Clean up the program this scenario created.
     When I go to "/admin/content?title=Functional+testing+suite+referenced+program"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite referenced program" row
      And I wait until the page is loaded
      And I click the "Delete" button
      And I wait until the page is loaded
     Then I should see "has been deleted"
    # Purge it from the trash as well, so the site is left exactly as it was found.
     When I go to "/admin/content/trash"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite referenced program" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite referenced program" in the "table" element

  @check @regression @crud @editorial @local @development
  Scenario: Verify that a Program cannot be saved without a title
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/program"
      And I wait until the page is loaded
    Given browser validation for the form "#node-program-form" is disabled
     When I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "Title field is required"
      And I should not see "has been created"

  # An unpublished Program must not reach the public listing or its own address.
  @check @regression @slow @security @crud @editorial @local @development
  Scenario: Verify that an unpublished Program is not readable by a visitor
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/program"
      And I wait until the page is loaded
      And I fill in "Title" with "Functional testing suite unpublished program"
      And I fill in "Summary" with "This program must never be readable by an anonymous visitor."
      And I uncheck "Published"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been created"
    Given I am an anonymous user
     When I go to "/programs/functional-testing-suite-unpublished-program"
      And I wait until the page is loaded
     Then the response status code should be 404
     When I go to "/programs"
      And I wait until the page is loaded
     Then I should not see "Functional testing suite unpublished program"

    # Clean up the unpublished program this scenario created.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+unpublished+program"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite unpublished program" row
      And I wait until the page is loaded
      And I click the "Delete" button
      And I wait until the page is loaded
     Then I should see "has been deleted"
    # Purge it from the trash as well, so the site is left exactly as it was found.
     When I go to "/admin/content/trash"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite unpublished program" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite unpublished program" in the "table" element
