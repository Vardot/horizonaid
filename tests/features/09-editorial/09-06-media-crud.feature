Feature: Editorial - Media - upload, read, rename and delete
      As a content editor
      I want to upload, read, rename and delete media through the admin UI
      So that the media types Horizon Aid's content actually uses work end to end.

  # Every Horizon Aid bundle references media through a Featured image, and a
  # Resource can offer a document to download. Those two types - Image and
  # Document - are the ones the template uses, so they are the ones covered here.
  # The site also ships Audio, Video, Remote video and SVG Image; nothing in the
  # template references them, so they are not asserted (volume is not the goal).
  #
  # The fixtures are deliberately tiny and synthetic: a 74-byte 8x8 PNG and a
  # one-line text file, both under tests/assets/. They carry no real content and no
  # personal data. The PNG has to be a REAL png - Drupal validates the image and
  # rejects a byte string that merely has the extension, and the upload then fails
  # with a form error instead of an alt-text field.
  #
  # Media is trash-enabled on this site too, so deleting an item only moves it to
  # /admin/content/trash/media. Each scenario purges it from there as well, which is
  # what leaves the media library exactly as it was found.
  #
  # The Image form requires alt text, and Drupal fires the upload AJAX by itself the
  # moment a file is chosen. The scenario therefore waits for the alt-text field to
  # appear rather than clicking the upload button as well: clicking it races Drupal's
  # own auto-upload, which swaps the widget out from under the click. The field is
  # addressed by its visible label ("Alternative text") because Drupal suffixes its
  # id with a random string on every render.
  #
  # Every media item created here is deleted again at the end. The media the recipe
  # ships is never edited or deleted here.
  #
  # ENVIRONMENT PREREQUISITE: the Autosave Form module must be uninstalled on the
  # site under test, the way the Varbase CI install step does it. It saves an open
  # form every 60 seconds, and the next visit to that form then opens with a
  # "resume editing or discard" dialog whose overlay swallows every click - so one
  # slow scenario silently breaks the next one. It is an environment fact, not
  # something a feature file can assert its way around.

  @check @acceptance @slow @crud @editorial @local @development
  Scenario: Check that an Image media item can be uploaded, read, renamed and deleted
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"

    # CREATE - attach the file, let Drupal's own AJAX upload it, then name it and
    # describe it. Alt text is required on this field, so a save without it fails.
     When I go to "/media/add/image"
      And I wait until the page is loaded
     Then I should see "Add Image"
     When I attach the file "horizonaid-test-image.png" to "#edit-field-media-image-0-upload"
      And I wait for AJAX to finish
    # Drupal fires the upload AJAX itself and appends the alt-text field when it
    # returns; waiting for that field's own label is the event to wait for.
     When I wait for the text "Alternative text" to appear
     When I fill in "Name" with "Functional testing suite image"
      And I fill in "Alternative text" with "A four by four test image"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "Image Functional testing suite image has been created."

    # READ - the item is listed in the media overview an editor works from.
     When I go to "/admin/content/media?name=Functional+testing+suite+image"
      And I wait until the page is loaded
     Then I should see "Functional testing suite image"

    # UPDATE - rename it, then prove the new name replaced the old in the overview.
     When I open the "Edit" link in the "Functional testing suite image" row
      And I wait until the page is loaded
     Then I should see "Functional testing suite image" value in the "edit-name-0-value" input element
     When I fill in "Name" with "Functional testing suite renamed image"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     When I go to "/admin/content/media?name=Functional+testing+suite"
      And I wait until the page is loaded
     Then I should see "Functional testing suite renamed image"
      And I should not see "Functional testing suite image"

    # DELETE
     When I open the "Delete" link in the "Functional testing suite renamed image" row
      And I wait until the page is loaded
     Then I should see "Are you sure you want to delete"
     When I click the "Delete" button
      And I wait until the page is loaded
     When I go to "/admin/content/media?name=Functional+testing+suite"
      And I wait until the page is loaded
     Then I should not see "Functional testing suite renamed image"
    # Purge it from the media trash as well: a delete here is a soft delete.
     When I go to "/admin/content/trash/media"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite renamed image" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite renamed image" in the "table" element

  @check @acceptance @slow @crud @editorial @local @development
  Scenario: Check that a Document media item can be uploaded, read, renamed and deleted
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/media/add/document"
      And I wait until the page is loaded
     Then I should see "Add Document"
     When I attach the file "horizonaid-test-document.txt" to "#edit-field-media-document-0-upload"
      And I wait for AJAX to finish
    # Drupal suffixes the remove button's id with a random string, so the selector
    # matches on the id PREFIX. Its presence is the proof the upload finished.
      And I should see "horizonaid-test-document"
     When I fill in "Name" with "Functional testing suite document"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "Document Functional testing suite document has been created."
     When I go to "/admin/content/media?name=Functional+testing+suite+document"
      And I wait until the page is loaded
     Then I should see "Functional testing suite document"
     When I open the "Edit" link in the "Functional testing suite document" row
      And I wait until the page is loaded
      And I fill in "Name" with "Functional testing suite renamed document"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     When I go to "/admin/content/media?name=Functional+testing+suite"
      And I wait until the page is loaded
     Then I should see "Functional testing suite renamed document"
     When I open the "Delete" link in the "Functional testing suite renamed document" row
      And I wait until the page is loaded
      And I click the "Delete" button
      And I wait until the page is loaded
     When I go to "/admin/content/media?name=Functional+testing+suite"
      And I wait until the page is loaded
     Then I should not see "Functional testing suite renamed document"
    # Purge it from the media trash as well: a delete here is a soft delete.
     When I go to "/admin/content/trash/media"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite renamed document" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite renamed document" in the "table" element


  # An uploaded image is only useful if an editor can put it on a page. This is the
  # Featured image field every Horizon Aid bundle ships, driven through the media
  # library dialog the editor actually uses, and the proof is that the image
  # element reaches the public page - not merely that the node saved.
  @check @acceptance @crud @editorial @local @development
  Scenario: Verify that an uploaded image can be set as a Resource's featured image
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/media/add/image"
      And I wait until the page is loaded
      And I attach the file "horizonaid-test-image.png" to "#edit-field-media-image-0-upload"
      And I wait for AJAX to finish
    # Drupal fires the upload AJAX itself and appends the alt-text field when it
    # returns; waiting for that field's own label is the event to wait for.
     When I wait for the text "Alternative text" to appear
     When I fill in "Name" with "Functional testing suite featured image"
      And I fill in "Alternative text" with "A four by four test image"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been created"

     When I go to "/node/add/blog"
      And I wait until the page is loaded
      And I fill in "Title" with "Functional testing suite media carrier"
      And I fill in "Description" with "A Resource carrying an uploaded featured image."
      And I open the "field_featured_image" media library
      And I wait for the modal to appear
     Then I should see "Add or select media" in the modal
     When I select the media "Functional testing suite featured image"
      And I submit the media library dialog
      And I wait for the modal to disappear
      And I select "Published" from "#edit-moderation-state-0-state"
      And I submit by id "edit-submit"
      And I wait until the page is loaded
     Then I should see "has been created"
    Given I am an anonymous user
     When I go to "/resources/functional-testing-suite-media-carrier"
      And I wait until the page is loaded
     Then the response status code should be 200
      And I should see image with the "A four by four test image" alt text

    # Clean up the node first, then the media item it referenced.
    Given I am a logged in user with the "webmaster" user
     Then I should see "Log out"
     When I go to "/admin/content?title=Functional+testing+suite+media+carrier"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite media carrier" row
      And I wait until the page is loaded
      And I click the "Delete" button
      And I wait until the page is loaded
     When I go to "/admin/content/media?name=Functional+testing+suite+featured+image"
      And I wait until the page is loaded
      And I open the "Delete" link in the "Functional testing suite featured image" row
      And I wait until the page is loaded
      And I click the "Delete" button
      And I wait until the page is loaded
     When I go to "/admin/content/media?name=Functional+testing+suite"
      And I wait until the page is loaded
     Then I should not see "Functional testing suite featured image"

    # Both soft deletes are finished off in their own trash listings.
     When I go to "/admin/content/trash"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite media carrier" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite media carrier" in the "table" element
    # Purge it from the media trash as well: a delete here is a soft delete.
     When I go to "/admin/content/trash/media"
      And I wait until the page is loaded
      And I open the "Purge" link in the "Functional testing suite featured image" row
      And I wait until the page is loaded
      # Gin renders the purge confirmation as the page title, while the h1 carries
      # the node label, so the question is asserted on the title rather than the body.
      And I wait until the page title contains "Are you sure you want to permanently delete"
     When I submit by id "edit-submit"
      And I wait until the page is loaded
      # The purge confirmation message repeats the label, so the absence is
      # asserted on the trash listing itself rather than page-wide.
     Then I should see "has been permanently deleted"
      And I should not see "Functional testing suite featured image" in the "table" element

