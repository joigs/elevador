require "application_system_test_case"

class LadderDetailsTest < ApplicationSystemTestCase
  setup do
    @ladder_detail = ladder_details(:one)
  end

  test "visiting the index" do
    visit ladder_details_url
    assert_selector "h1", text: "Ladder details"
  end

  test "should create ladder detail" do
    visit ladder_details_url
    click_on "New ladder detail"

    fill_in "Ancho", with: @ladder_detail.ancho
    fill_in "Capacidad", with: @ladder_detail.capacidad
    fill_in "Fabricacion", with: @ladder_detail.fabricacion
    fill_in "Inclinacion", with: @ladder_detail.inclinacion
    fill_in "Item", with: @ladder_detail.item_id
    fill_in "Longitud", with: @ladder_detail.longitud
    fill_in "Marca", with: @ladder_detail.marca
    fill_in "Mm marca", with: @ladder_detail.mm_marca
    fill_in "Mm nserie", with: @ladder_detail.mm_nserie
    fill_in "Modelo", with: @ladder_detail.modelo
    fill_in "Nserie", with: @ladder_detail.nserie
    fill_in "Peldaños", with: @ladder_detail.peldaños
    fill_in "Personas", with: @ladder_detail.personas
    fill_in "Potencia", with: @ladder_detail.potencia
    fill_in "Procedencia", with: @ladder_detail.procedencia
    fill_in "Velocidad", with: @ladder_detail.velocidad
    click_on "Create Ladder detail"

    assert_text "Ladder detail was successfully created"
    click_on "Back"
  end

  test "should update Ladder detail" do
    visit ladder_detail_url(@ladder_detail)
    click_on "Edit this ladder detail", match: :first

    fill_in "Ancho", with: @ladder_detail.ancho
    fill_in "Capacidad", with: @ladder_detail.capacidad
    fill_in "Fabricacion", with: @ladder_detail.fabricacion
    fill_in "Inclinacion", with: @ladder_detail.inclinacion
    fill_in "Item", with: @ladder_detail.item_id
    fill_in "Longitud", with: @ladder_detail.longitud
    fill_in "Marca", with: @ladder_detail.marca
    fill_in "Mm marca", with: @ladder_detail.mm_marca
    fill_in "Mm nserie", with: @ladder_detail.mm_nserie
    fill_in "Modelo", with: @ladder_detail.modelo
    fill_in "Nserie", with: @ladder_detail.nserie
    fill_in "Peldaños", with: @ladder_detail.peldaños
    fill_in "Personas", with: @ladder_detail.personas
    fill_in "Potencia", with: @ladder_detail.potencia
    fill_in "Procedencia", with: @ladder_detail.procedencia
    fill_in "Velocidad", with: @ladder_detail.velocidad
    click_on "Update Ladder detail"

    assert_text "Ladder detail was successfully updated"
    click_on "Back"
  end

  test "should destroy Ladder detail" do
    visit ladder_detail_url(@ladder_detail)
    click_on "Destroy this ladder detail", match: :first

    assert_text "Ladder detail was successfully destroyed"
  end
end
