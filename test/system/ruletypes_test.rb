require "application_system_test_case"

class RuletypesTest < ApplicationSystemTestCase
  setup do
    @ruletype = ruletypes(:one)
  end

  test "visiting the index" do
    visit ruletypes_url
    assert_selector "h1", text: "Ruletypes"
  end

  test "should create ruletype" do
    visit ruletypes_url
    click_on "New ruletype"

    fill_in "Rtype", with: @ruletype.rtype
    click_on "Create Ruletype"

    assert_text "Ruletype was successfully created"
    click_on "Back"
  end

  test "should update Ruletype" do
    visit ruletype_url(@ruletype)
    click_on "Edit this ruletype", match: :first

    fill_in "Rtype", with: @ruletype.rtype
    click_on "Update Ruletype"

    assert_text "Ruletype was successfully updated"
    click_on "Back"
  end

  test "should destroy Ruletype" do
    visit ruletype_url(@ruletype)
    click_on "Destroy this ruletype", match: :first

    assert_text "Ruletype was successfully destroyed"
  end
end
