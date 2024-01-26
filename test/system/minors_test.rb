require "application_system_test_case"

class MinorsTest < ApplicationSystemTestCase
  setup do
    @minor = minors(:one)
  end

  test "visiting the index" do
    visit minors_url
    assert_selector "h1", text: "Minors"
  end

  test "should create minor" do
    visit minors_url
    click_on "New minor"

    fill_in "Business name", with: @minor.business_name
    fill_in "Cellphone", with: @minor.cellphone
    fill_in "Contact name", with: @minor.contact_name
    fill_in "Email", with: @minor.email
    fill_in "Name", with: @minor.name
    fill_in "Phone", with: @minor.phone
    fill_in "Rut", with: @minor.rut
    click_on "Create Minor"

    assert_text "Minor was successfully created"
    click_on "Back"
  end

  test "should update Minor" do
    visit minor_url(@minor)
    click_on "Edit this minor", match: :first

    fill_in "Business name", with: @minor.business_name
    fill_in "Cellphone", with: @minor.cellphone
    fill_in "Contact name", with: @minor.contact_name
    fill_in "Email", with: @minor.email
    fill_in "Name", with: @minor.name
    fill_in "Phone", with: @minor.phone
    fill_in "Rut", with: @minor.rut
    click_on "Update Minor"

    assert_text "Minor was successfully updated"
    click_on "Back"
  end

  test "should destroy Minor" do
    visit minor_url(@minor)
    click_on "Destroy this minor", match: :first

    assert_text "Minor was successfully destroyed"
  end
end
