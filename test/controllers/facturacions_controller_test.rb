require "test_helper"

class FacturacionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @facturacion = facturacions(:one)
  end

  test "should get index" do
    get facturacions_url
    assert_response :success
  end

  test "should get new" do
    get new_facturacion_url
    assert_response :success
  end

  test "should create facturacion" do
    assert_difference("Facturacion.count") do
      post facturacions_url, params: { facturacion: {  } }
    end

    assert_redirected_to facturacion_url(Facturacion.last)
  end

  test "should show facturacion" do
    get facturacion_url(@facturacion)
    assert_response :success
  end

  test "should get edit" do
    get edit_facturacion_url(@facturacion)
    assert_response :success
  end

  test "should update facturacion" do
    patch facturacion_url(@facturacion), params: { facturacion: {  } }
    assert_redirected_to facturacion_url(@facturacion)
  end

  test "should destroy facturacion" do
    assert_difference("Facturacion.count", -1) do
      delete facturacion_url(@facturacion)
    end

    assert_redirected_to facturacions_url
  end
end
