require "test_helper"

class LadderDetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ladder_detail = ladder_details(:one)
  end

  test "should get index" do
    get ladder_details_url
    assert_response :success
  end

  test "should get new" do
    get new_ladder_detail_url
    assert_response :success
  end

  test "should create ladder_detail" do
    assert_difference("LadderDetail.count") do
      post ladder_details_url, params: { ladder_detail: { ancho: @ladder_detail.ancho, capacidad: @ladder_detail.capacidad, fabricacion: @ladder_detail.fabricacion, inclinacion: @ladder_detail.inclinacion, item_id: @ladder_detail.item_id, longitud: @ladder_detail.longitud, marca: @ladder_detail.marca, mm_marca: @ladder_detail.mm_marca, mm_nserie: @ladder_detail.mm_nserie, modelo: @ladder_detail.modelo, nserie: @ladder_detail.nserie, peldaños: @ladder_detail.peldaños, personas: @ladder_detail.personas, potencia: @ladder_detail.potencia, procedencia: @ladder_detail.procedencia, velocidad: @ladder_detail.velocidad } }
    end

    assert_redirected_to ladder_detail_url(LadderDetail.last)
  end

  test "should show ladder_detail" do
    get ladder_detail_url(@ladder_detail)
    assert_response :success
  end

  test "should get edit" do
    get edit_ladder_detail_url(@ladder_detail)
    assert_response :success
  end

  test "should update ladder_detail" do
    patch ladder_detail_url(@ladder_detail), params: { ladder_detail: { ancho: @ladder_detail.ancho, capacidad: @ladder_detail.capacidad, fabricacion: @ladder_detail.fabricacion, inclinacion: @ladder_detail.inclinacion, item_id: @ladder_detail.item_id, longitud: @ladder_detail.longitud, marca: @ladder_detail.marca, mm_marca: @ladder_detail.mm_marca, mm_nserie: @ladder_detail.mm_nserie, modelo: @ladder_detail.modelo, nserie: @ladder_detail.nserie, peldaños: @ladder_detail.peldaños, personas: @ladder_detail.personas, potencia: @ladder_detail.potencia, procedencia: @ladder_detail.procedencia, velocidad: @ladder_detail.velocidad } }
    assert_redirected_to ladder_detail_url(@ladder_detail)
  end

  test "should destroy ladder_detail" do
    assert_difference("LadderDetail.count", -1) do
      delete ladder_detail_url(@ladder_detail)
    end

    assert_redirected_to ladder_details_url
  end
end
