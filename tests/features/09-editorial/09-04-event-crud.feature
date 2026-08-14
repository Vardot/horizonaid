@any @regression @content @editorial @acceptance
Feature: Editorial - Event - create, read, update and delete
      As a content editor
      I want to create, read, update and delete an Event through the admin UI
      So that the Event content type and its date range are usable end to end.

  # Event is the only Horizon Aid bundle with a date range: a Smart Date "When"
  # field that the Events listing sorts and filters on. A broken date widget means
  # an event nobody can find, which is why the date is not merely filled here but
  # read back off the reopened form AND asserted on the rendered page, where it
  # appears in the site's own long-date format.
  #
  # The venue (Location) is filled and read back off the form but never asserted on
  # the rendered page: the Event content template does not output it at all on this
  # build. That is reported to the maintainers rather than asserted either way here.
  #
  # Every event created here is scheduled far in the future so it never collides
  # with the 24 shipped demo events (latest is December 2027), and it is deleted
  # again at the end. Event is NOT under the editorial workflow, so it publishes
  # through the Published checkbox.
  #
  # The Events listing itself is asserted by the public-page folders, not here: it
  # pages nine at a time in date order, so a 2030 event legitimately sits on the
  # last page and a first-page assertion would be testing the pager.
  #
  # ENVIRONMENT PREREQUISITE: the Autosave Form module must be uninstalled on the
  # site under test, the way the Varbase CI install step does it. It saves an open
  # form every 60 seconds, and the next visit to that form then opens with a
  # "resume editing or discard" dialog whose overlay swallows every click - so one
  # slow scenario silently breaks the next one. It is an environment fact, not
  # something a feature file can assert its way around.

  @check @acceptance @slow @crud @editorial @local @development
  Scenario: Check that an Event can be created with a date range and read by a visitor
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"

    # CREATE - title, description, venue, a future date range and a rich text body.
     When I go to "/node/add/event"
      And I wait until the page is loaded
     Then I should see "Create Event"
     When I fill in "Title" with "Functional testing suite event"
      And I fill in "Description" with "An Event created by the Horizon Aid functional testing suite."
      And I fill in "Location" with "Test Hall, Ground Floor"
      And I fill in "edit-field-when-0-time-wrapper-value-date" with "2030-05-14" by its "id" attribute
      And I fill in "edit-field-when-0-time-wrapper-value-time" with "09:00" by its "id" attribute
    # The end of the range is left to the widget. Smart Date keeps its duration
    # select out of reach (it renders zero-sized) and computes the finish from the
    # start plus the default one-hour duration, so an editor who sets the start has
    # set the range. Driving the hidden select would be testing the widget's
    # internals rather than the Event content type.
      And I fill in the rich text editor field "Body" with "<p>The body of the round-trip event.</p>"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "Event Functional testing suite event has been created."

    # READ - the event renders its title, its summary, its body and its date for the
    # public at the pathauto alias /events/[title]. The date is the assertion that
    # matters: it proves the Smart Date value survived the save and reached the
    # template in the format a reader sees.
     Then "h1" should have text "Functional testing suite event" within 10 seconds
    Given I am an anonymous user
     When I go to "/events/functional-testing-suite-event"
      And I wait until the page is loaded
     Then the response status code should be 200
      And "h1" should have text "Functional testing suite event" within 10 seconds
      And I should see "An Event created by the Horizon Aid functional testing suite."
      And I should see "The body of the round-trip event."
      And I should see "14 May 2030"

    # DELETE - and confirm the public alias stops resolving.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+event"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite event" row
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
      And I open the "Purge" link in the "Functional testing suite event" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite event" in the "table" element
    Given I am an anonymous user
     When I go to "/events/functional-testing-suite-event"
      And I wait until the page is loaded
     Then the response status code should be 404

  # Moving an event is the commonest edit there is, and the one an audience notices
  # immediately. The stored dates and the venue are read back off the reopened form,
  # because the Canvas content template for an Event does not surface the venue at
  # all - so a rendered-text assertion would be testing the template rather than
  # whether the edit persisted.
  @check @acceptance @crud @editorial @local @development
  Scenario: Verify that moving an Event to another date persists
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/event"
      And I wait until the page is loaded
      And I fill in "Title" with "Functional testing suite moved event"
      And I fill in "Description" with "An Event the suite is about to move."
      And I fill in "Location" with "Test Hall, Ground Floor"
      And I fill in "edit-field-when-0-time-wrapper-value-date" with "2030-05-14" by its "id" attribute
      And I fill in "edit-field-when-0-time-wrapper-value-time" with "09:00" by its "id" attribute
    # The end of the range is left to the widget. Smart Date keeps its duration
    # select out of reach (it renders zero-sized) and computes the finish from the
    # start plus the default one-hour duration, so an editor who sets the start has
    # set the range. Driving the hidden select would be testing the widget's
    # internals rather than the Event content type.
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been created"

    # Reopen the form and confirm what was stored before changing it.
     When I go to "/admin/content?title=Functional+testing+suite+moved+event"
      And I wait until the page is loaded
      And I open the "Edit" link in the "Functional testing suite moved event" row
      And I wait until the page is loaded
     Then I should see "2030-05-14" value in the "edit-field-when-0-time-wrapper-value-date" input element
      And I should see "09:00" value in the "edit-field-when-0-time-wrapper-value-time" input element
      And I should see "Test Hall, Ground Floor" value in the "edit-field-location-0-value" input element

    # Move it, then read the new dates back and check the public page shows them.
     When I fill in "edit-field-when-0-time-wrapper-value-date" with "2030-06-20" by its "id" attribute
      And I fill in "Location" with "Main Auditorium, First Floor"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been updated"
     When I go to "/admin/content?title=Functional+testing+suite+moved+event"
      And I wait until the page is loaded
      And I open the "Edit" link in the "Functional testing suite moved event" row
      And I wait until the page is loaded
     Then I should see "2030-06-20" value in the "edit-field-when-0-time-wrapper-value-date" input element
      And I should see "Main Auditorium, First Floor" value in the "edit-field-location-0-value" input element
    Given I am an anonymous user
     When I go to "/events/functional-testing-suite-moved-event"
      And I wait until the page is loaded
     Then I should see "20 June 2030"
      And I should not see "14 May 2030"

    # Clean up the event this scenario created.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+moved+event"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite moved event" row
      And I wait until the page is loaded
      And I click the "Delete" button
      And I wait until the page is loaded
     Then I should see "has been deleted"
    # Purge it from the trash as well, so the site is left exactly as it was found.
     When I go to "/admin/content/trash"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite moved event" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite moved event" in the "table" element

  @check @regression @slow @crud @editorial @local @development
  Scenario: Verify that an Event cannot be saved without a title
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/event"
      And I wait until the page is loaded
    Given browser validation for the form "#node-event-form" is disabled
     When I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "Title field is required"
      And I should not see "has been created"

  # An unpublished Event must not be readable by the public.
  @check @regression @security @crud @editorial @local @development
  Scenario: Verify that an unpublished Event is not readable by a visitor
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/node/add/event"
      And I wait until the page is loaded
      And I fill in "Title" with "Functional testing suite unpublished event"
      And I fill in "Description" with "This event must never be readable by an anonymous visitor."
      And I fill in "edit-field-when-0-time-wrapper-value-date" with "2030-07-01" by its "id" attribute
      And I fill in "edit-field-when-0-time-wrapper-value-time" with "09:00" by its "id" attribute
      And I uncheck "Published"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been created"
    Given I am an anonymous user
     When I go to "/events/functional-testing-suite-unpublished-event"
      And I wait until the page is loaded
     Then the response status code should be 404

    # Clean up the unpublished event this scenario created.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+unpublished+event"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite unpublished event" row
      And I wait until the page is loaded
      And I click the "Delete" button
      And I wait until the page is loaded
     Then I should see "has been deleted"
    # Purge it from the trash as well, so the site is left exactly as it was found.
     When I go to "/admin/content/trash"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite unpublished event" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite unpublished event" in the "table" element
