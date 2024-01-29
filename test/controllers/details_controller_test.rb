require "test_helper"

class DetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @detail = details(:one)
  end

  test "should get index" do
    get details_url
    assert_response :success
  end

  test "should get new" do
    get new_detail_url
    assert_response :success
  end

  test "should create detail" do
    assert_difference("Detail.count") do
      post details_url, params: { detail: { capacidad: @detail.capacidad, ct_cantidad: @detail.ct_cantidad, ct_diametro: @detail.ct_diametro, ct_marca: @detail.ct_marca, detalle: @detail.detalle, embarques: @detail.embarques, item_id: @detail.item_id, marca: @detail.marca, medidas_cintas: @detail.medidas_cintas, mm_marca: @detail.mm_marca, mm_n_serie: @detail.mm_n_serie, modelo: @detail.modelo, n_serie: @detail.n_serie, paradas: @detail.paradas, personas: @detail.personas, potencia: @detail.potencia, rv_marca: @detail.rv_marca, rv_n_serie: @detail.rv_n_serie, sala_maquinas: @detail.sala_maquinas } }
    end

    assert_redirected_to detail_url(Detail.last)
  end

  test "should show detail" do
    get detail_url(@detail)
    assert_response :success
  end

  test "should get edit" do
    get edit_detail_url(@detail)
    assert_response :success
  end

  test "should update detail" do
    patch detail_url(@detail), params: { detail: { capacidad: @detail.capacidad, ct_cantidad: @detail.ct_cantidad, ct_diametro: @detail.ct_diametro, ct_marca: @detail.ct_marca, detalle: @detail.detalle, embarques: @detail.embarques, item_id: @detail.item_id, marca: @detail.marca, medidas_cintas: @detail.medidas_cintas, mm_marca: @detail.mm_marca, mm_n_serie: @detail.mm_n_serie, modelo: @detail.modelo, n_serie: @detail.n_serie, paradas: @detail.paradas, personas: @detail.personas, potencia: @detail.potencia, rv_marca: @detail.rv_marca, rv_n_serie: @detail.rv_n_serie, sala_maquinas: @detail.sala_maquinas } }
    assert_redirected_to detail_url(@detail)
  end

  test "should destroy detail" do
    assert_difference("Detail.count", -1) do
      delete detail_url(@detail)
    end

    assert_redirected_to details_url
  end
end
