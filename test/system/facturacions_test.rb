require "application_system_test_case"

class FacturacionsTest < ApplicationSystemTestCase
  setup do
    @facturacion = facturacions(:one)
  end

  test "visiting the index" do
    visit facturacions_url
    assert_selector "h1", text: "Facturacions"
  end

  test "should create facturacion" do
    visit facturacions_url
    click_on "New facturacion"

    click_on "Create Facturacion"

    assert_text "Facturacion was successfully created"
    click_on "Back"
  end

  test "should update Facturacion" do
    visit facturacion_url(@facturacion)
    click_on "Edit this facturacion", match: :first

    click_on "Update Facturacion"

    assert_text "Facturacion was successfully updated"
    click_on "Back"
  end

  test "should destroy Facturacion" do
    visit facturacion_url(@facturacion)
    click_on "Destroy this facturacion", match: :first

    assert_text "Facturacion was successfully destroyed"
  end
end
