require "application_system_test_case"

class PrincipalsTest < ApplicationSystemTestCase
  setup do
    @principal = principals(:one)
  end

  test "visiting the index" do
    visit principals_url
    assert_selector "h1", text: "Principals"
  end

  test "should create principal" do
    visit principals_url
    click_on "New principal"

    fill_in "Business name", with: @principal.business_name
    fill_in "Cellphone", with: @principal.cellphone
    fill_in "Contact name", with: @principal.contact_name
    fill_in "Email", with: @principal.email
    fill_in "Name", with: @principal.name
    fill_in "Phone", with: @principal.phone
    fill_in "Rut", with: @principal.rut
    click_on "Create Principal"

    assert_text "Principal was successfully created"
    click_on "Back"
  end

  test "should update Principal" do
    visit principal_url(@principal)
    click_on "Edit this principal", match: :first

    fill_in "Business name", with: @principal.business_name
    fill_in "Cellphone", with: @principal.cellphone
    fill_in "Contact name", with: @principal.contact_name
    fill_in "Email", with: @principal.email
    fill_in "Name", with: @principal.name
    fill_in "Phone", with: @principal.phone
    fill_in "Rut", with: @principal.rut
    click_on "Update Principal"

    assert_text "Principal was successfully updated"
    click_on "Back"
  end

  test "should destroy Principal" do
    visit principal_url(@principal)
    click_on "Destroy this principal", match: :first

    assert_text "Principal was successfully destroyed"
  end
end
