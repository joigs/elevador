require "application_system_test_case"

class LaddersTest < ApplicationSystemTestCase
  setup do
    @ladder = ladders(:one)
  end

  test "visiting the index" do
    visit ladders_url
    assert_selector "h1", text: "Ladders"
  end

  test "should create ladder" do
    visit ladders_url
    click_on "New ladder"

    fill_in "Code", with: @ladder.code
    fill_in "Level", with: @ladder.level
    fill_in "Number", with: @ladder.number
    fill_in "Point", with: @ladder.point
    fill_in "Priority", with: @ladder.priority
    click_on "Create Ladder"

    assert_text "Ladder was successfully created"
    click_on "Back"
  end

  test "should update Ladder" do
    visit ladder_url(@ladder)
    click_on "Edit this ladder", match: :first

    fill_in "Code", with: @ladder.code
    fill_in "Level", with: @ladder.level
    fill_in "Number", with: @ladder.number
    fill_in "Point", with: @ladder.point
    fill_in "Priority", with: @ladder.priority
    click_on "Update Ladder"

    assert_text "Ladder was successfully updated"
    click_on "Back"
  end

  test "should destroy Ladder" do
    visit ladder_url(@ladder)
    click_on "Destroy this ladder", match: :first

    assert_text "Ladder was successfully destroyed"
  end
end
