require "application_system_test_case"

class DetailsTest < ApplicationSystemTestCase
  setup do
    @detail = details(:one)
  end

  test "visiting the index" do
    visit details_url
    assert_selector "h1", text: "Details"
  end

  test "should create detail" do
    visit details_url
    click_on "New detail"

    fill_in "Capacidad", with: @detail.capacidad
    fill_in "Ct cantidad", with: @detail.ct_cantidad
    fill_in "Ct diametro", with: @detail.ct_diametro
    fill_in "Ct marca", with: @detail.ct_marca
    fill_in "Detalle", with: @detail.detalle
    fill_in "Embarques", with: @detail.embarques
    fill_in "Item", with: @detail.item_id
    fill_in "Marca", with: @detail.marca
    fill_in "Medidas cintas", with: @detail.medidas_cintas
    fill_in "Mm marca", with: @detail.mm_marca
    fill_in "Mm n serie", with: @detail.mm_n_serie
    fill_in "Modelo", with: @detail.modelo
    fill_in "N serie", with: @detail.n_serie
    fill_in "Paradas", with: @detail.paradas
    fill_in "Personas", with: @detail.personas
    fill_in "Potencia", with: @detail.potencia
    fill_in "Rv marca", with: @detail.rv_marca
    fill_in "Rv n serie", with: @detail.rv_n_serie
    fill_in "Sala maquinas", with: @detail.sala_maquinas
    click_on "Create Detail"

    assert_text "Detail was successfully created"
    click_on "Back"
  end

  test "should update Detail" do
    visit detail_url(@detail)
    click_on "Edit this detail", match: :first

    fill_in "Capacidad", with: @detail.capacidad
    fill_in "Ct cantidad", with: @detail.ct_cantidad
    fill_in "Ct diametro", with: @detail.ct_diametro
    fill_in "Ct marca", with: @detail.ct_marca
    fill_in "Detalle", with: @detail.detalle
    fill_in "Embarques", with: @detail.embarques
    fill_in "Item", with: @detail.item_id
    fill_in "Marca", with: @detail.marca
    fill_in "Medidas cintas", with: @detail.medidas_cintas
    fill_in "Mm marca", with: @detail.mm_marca
    fill_in "Mm n serie", with: @detail.mm_n_serie
    fill_in "Modelo", with: @detail.modelo
    fill_in "N serie", with: @detail.n_serie
    fill_in "Paradas", with: @detail.paradas
    fill_in "Personas", with: @detail.personas
    fill_in "Potencia", with: @detail.potencia
    fill_in "Rv marca", with: @detail.rv_marca
    fill_in "Rv n serie", with: @detail.rv_n_serie
    fill_in "Sala maquinas", with: @detail.sala_maquinas
    click_on "Update Detail"

    assert_text "Detail was successfully updated"
    click_on "Back"
  end

  test "should destroy Detail" do
    visit detail_url(@detail)
    click_on "Destroy this detail", match: :first

    assert_text "Detail was successfully destroyed"
  end
end
