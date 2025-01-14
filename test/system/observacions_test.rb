require "application_system_test_case"

class ObservacionsTest < ApplicationSystemTestCase
  setup do
    @observacion = observacions(:one)
  end

  test "visiting the index" do
    visit observacions_url
    assert_selector "h1", text: "Observacions"
  end

  test "should create observacion" do
    visit observacions_url
    click_on "New observacion"

    click_on "Create Observacion"

    assert_text "Observacion was successfully created"
    click_on "Back"
  end

  test "should update Observacion" do
    visit observacion_url(@observacion)
    click_on "Edit this observacion", match: :first

    click_on "Update Observacion"

    assert_text "Observacion was successfully updated"
    click_on "Back"
  end

  test "should destroy Observacion" do
    visit observacion_url(@observacion)
    click_on "Destroy this observacion", match: :first

    assert_text "Observacion was successfully destroyed"
  end
end
