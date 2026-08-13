Feature: Editorial - Resource - create, read, update and delete
      As a content editor
      I want to create, read, update and delete a Resource through the admin UI
      So that the Resources section works end to end, moderation state and all.

  # A Resource is a Blog post node published under /resources. It is the one
  # editorial bundle on this site under the Varbase editorial workflow, so it does
  # NOT save with a Published checkbox: it saves into a moderation state, and the
  # default state on a new node is Draft. That is the trap this feature exists for
  # - an editor who fills the form and presses Save gets an unpublished page and no
  # error, so a suite that only checked "has been created" would call that a pass.
  #
  # The 26 shipped demo resources are never edited or deleted here.
  #
  # ENVIRONMENT PREREQUISITE: the Autosave Form module must be uninstalled on the
  # site under test, the way the Varbase CI install step does it. It saves an open
  # form every 60 seconds, and the next visit to that form then opens with a
  # "resume editing or discard" dialog whose overlay swallows every click - so one
  # slow scenario silently breaks the next one. It is an environment fact, not
  # something a feature file can assert its way around.

  @check @acceptance @slow @crud @editorial @local @development
  Scenario: Check that a Resource can be created, published and read by a visitor
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"

    # CREATE - Title and Description are required; Content is the rich text body.
    # "Published" is chosen explicitly, because the workflow's default is Draft.
     When I go to "/node/add/blog"
      And I wait until the page is loaded
     Then I should see "Create Blog post"
     When I fill in "Title" with "Functional testing suite resource"
      And I fill in "Description" with "A Resource created by the Horizon Aid functional testing suite."
      And I fill in the rich text editor field "Content" with "<p>The body of the round-trip resource.</p>"
      And I select "Published" from "#edit-moderation-state-0-state"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "Blog post Functional testing suite resource has been created."

    # READ - the resource renders its title and body for the public at the pathauto
    # alias /resources/[title], and it reaches the Resources listing.
     Then "h1" should have text "Functional testing suite resource" within 10 seconds
    Given I am an anonymous user
     When I go to "/resources/functional-testing-suite-resource"
      And I wait until the page is loaded
     Then the response status code should be 200
      And "h1" should have text "Functional testing suite resource" within 10 seconds
      And I should see "The body of the round-trip resource."

    # DELETE - and confirm the public alias stops resolving.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+resource"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite resource" row
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
      And I open the "Purge" link in the "Functional testing suite resource" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite resource" in the "table" element
    Given I am an anonymous user
     When I go to "/resources/functional-testing-suite-resource"
      And I wait until the page is loaded
     Then the response status code should be 404

  # Editing a published Resource is the everyday act on this bundle, and under a
  # workflow a re-save has to be told which state to land in again. This scenario
  # proves the second save keeps the page public and carries the new words.
  @check @acceptance @slow @crud @editorial @local @development
  Scenario: Verify that an edit to a published Resource persists and stays public
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/blog"
      And I wait until the page is loaded
      And I fill in "Title" with "Functional testing suite edited resource"
      And I fill in "Description" with "A Resource the suite is about to edit."
      And I fill in the rich text editor field "Content" with "<p>The first version of the resource body.</p>"
      And I select "Published" from "#edit-moderation-state-0-state"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been created"
     When I go to "/admin/content?title=Functional+testing+suite+edited+resource"
      And I wait until the page is loaded
      And I open the "Edit" link in the "Functional testing suite edited resource" row
      And I wait until the page is loaded
     Then I should see "Functional testing suite edited resource" value in the "edit-title-0-value" input element
     When I fill in the rich text editor field "Content" with "<p>The revised version of the resource body.</p>"
      And I select "Published" from "#edit-moderation-state-0-state"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been updated"
    Given I am an anonymous user
     When I go to "/resources/functional-testing-suite-edited-resource"
      And I wait until the page is loaded
     Then the response status code should be 200
      And I should see "The revised version of the resource body."
      And I should not see "The first version of the resource body."

    # Clean up the resource this scenario created.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+edited+resource"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite edited resource" row
      And I wait until the page is loaded
      And I click the "Delete" button
      And I wait until the page is loaded
     Then I should see "has been deleted"
    # Purge it from the trash as well, so the site is left exactly as it was found.
     When I go to "/admin/content/trash"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite edited resource" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite edited resource" in the "table" element

  @check @regression @slow @crud @editorial @local @development
  Scenario: Verify that a Resource cannot be saved without its required fields
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/blog"
      And I wait until the page is loaded
    Given browser validation for the form "#node-blog-form" is disabled
     When I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "Title field is required"
      And I should see "Description field is required"
      And I should not see "has been created"

  # A Resource left in the workflow's default Draft state must not be readable by
  # the public, and it must not appear on the Resources listing. This is the state
  # machine, not the published flag, and it is the state an editor lands in by
  # simply pressing Save.
  @check @regression @slow @security @crud @editorial @local @development
  Scenario: Verify that a draft Resource is not readable by a visitor
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/blog"
      And I wait until the page is loaded
      And I fill in "Title" with "Functional testing suite draft resource"
      And I fill in "Description" with "This draft must never be readable by an anonymous visitor."
      And I select "Draft" from "#edit-moderation-state-0-state"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been created"
    Given I am an anonymous user
     When I go to "/resources/functional-testing-suite-draft-resource"
      And I wait until the page is loaded
     Then the response status code should be 404
     When I go to "/resources"
      And I wait until the page is loaded
     Then I should not see "Functional testing suite draft resource"

    # Clean up the draft this scenario created.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+draft+resource"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite draft resource" row
      And I wait until the page is loaded
      And I click the "Delete" button
      And I wait until the page is loaded
     Then I should see "has been deleted"
    # Purge it from the trash as well, so the site is left exactly as it was found.
     When I go to "/admin/content/trash"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite draft resource" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite draft resource" in the "table" element
