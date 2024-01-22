require "application_system_test_case"

class InspectionsTest < ApplicationSystemTestCase
  setup do
    @inspection = inspections(:one)
  end

  test "visiting the index" do
    visit inspections_url
    assert_selector "h1", text: "Inspections"
  end

  test "should create inspection" do
    visit inspections_url
    click_on "New inspection"

    fill_in "Inf date", with: @inspection.inf_date
    fill_in "Ins date", with: @inspection.ins_date
    fill_in "Number", with: @inspection.number
    fill_in "Place", with: @inspection.place
    check "Result" if @inspection.result
    fill_in "Validation", with: @inspection.validation
    click_on "Create Inspection"

    assert_text "Inspection was successfully created"
    click_on "Back"
  end

  test "should update Inspection" do
    visit inspection_url(@inspection)
    click_on "Edit this inspection", match: :first

    fill_in "Inf date", with: @inspection.inf_date
    fill_in "Ins date", with: @inspection.ins_date
    fill_in "Number", with: @inspection.number
    fill_in "Place", with: @inspection.place
    check "Result" if @inspection.result
    fill_in "Validation", with: @inspection.validation
    click_on "Update Inspection"

    assert_text "Inspection was successfully updated"
    click_on "Back"
  end

  test "should destroy Inspection" do
    visit inspection_url(@inspection)
    click_on "Destroy this inspection", match: :first

    assert_text "Inspection was successfully destroyed"
  end
end
