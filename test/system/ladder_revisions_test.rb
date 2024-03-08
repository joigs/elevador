require "application_system_test_case"

class LadderRevisionsTest < ApplicationSystemTestCase
  setup do
    @ladder_revision = ladder_revisions(:one)
  end

  test "visiting the index" do
    visit ladder_revisions_url
    assert_selector "h1", text: "Ladder revisions"
  end

  test "should create ladder revision" do
    visit ladder_revisions_url
    click_on "New ladder revision"

    fill_in "Codes", with: @ladder_revision.codes
    fill_in "Comment", with: @ladder_revision.comment
    fill_in "Fail", with: @ladder_revision.fail
    fill_in "Inspection", with: @ladder_revision.inspection_id
    fill_in "Item", with: @ladder_revision.item_id
    fill_in "Levels", with: @ladder_revision.levels
    fill_in "Number", with: @ladder_revision.number
    fill_in "Points", with: @ladder_revision.points
    fill_in "Priority", with: @ladder_revision.priority
    click_on "Create Ladder revision"

    assert_text "Ladder revision was successfully created"
    click_on "Back"
  end

  test "should update Ladder revision" do
    visit ladder_revision_url(@ladder_revision)
    click_on "Edit this ladder revision", match: :first

    fill_in "Codes", with: @ladder_revision.codes
    fill_in "Comment", with: @ladder_revision.comment
    fill_in "Fail", with: @ladder_revision.fail
    fill_in "Inspection", with: @ladder_revision.inspection_id
    fill_in "Item", with: @ladder_revision.item_id
    fill_in "Levels", with: @ladder_revision.levels
    fill_in "Number", with: @ladder_revision.number
    fill_in "Points", with: @ladder_revision.points
    fill_in "Priority", with: @ladder_revision.priority
    click_on "Update Ladder revision"

    assert_text "Ladder revision was successfully updated"
    click_on "Back"
  end

  test "should destroy Ladder revision" do
    visit ladder_revision_url(@ladder_revision)
    click_on "Destroy this ladder revision", match: :first

    assert_text "Ladder revision was successfully destroyed"
  end
end
