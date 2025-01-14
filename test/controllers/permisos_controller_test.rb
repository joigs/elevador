require "test_helper"

class PermisosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get permisos_index_url
    assert_response :success
  end

  test "should get show" do
    get permisos_show_url
    assert_response :success
  end

  test "should get new" do
    get permisos_new_url
    assert_response :success
  end

  test "should get create" do
    get permisos_create_url
    assert_response :success
  end

  test "should get edit" do
    get permisos_edit_url
    assert_response :success
  end

  test "should get update" do
    get permisos_update_url
    assert_response :success
  end

  test "should get destroy" do
    get permisos_destroy_url
    assert_response :success
  end
end
