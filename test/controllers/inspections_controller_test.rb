require "test_helper"

class InspectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @inspection = inspections(:one)
  end

  test "should get index" do
    get inspections_url
    assert_response :success
  end

  test "should get new" do
    get new_inspection_url
    assert_response :success
  end

  test "should create inspection" do
    assert_difference("Inspection.count") do
      post inspections_url, params: { inspection: { inf_date: @inspection.inf_date, ins_date: @inspection.ins_date, number: @inspection.number, place: @inspection.place, result: @inspection.result, validation: @inspection.validation } }
    end

    assert_redirected_to inspection_url(Inspection.last)
  end

  test "should show inspection" do
    get inspection_url(@inspection)
    assert_response :success
  end

  test "should get edit" do
    get edit_inspection_url(@inspection)
    assert_response :success
  end

  test "should update inspection" do
    patch inspection_url(@inspection), params: { inspection: { inf_date: @inspection.inf_date, ins_date: @inspection.ins_date, number: @inspection.number, place: @inspection.place, result: @inspection.result, validation: @inspection.validation } }
    assert_redirected_to inspection_url(@inspection)
  end

  test "should destroy inspection" do
    assert_difference("Inspection.count", -1) do
      delete inspection_url(@inspection)
    end

    assert_redirected_to inspections_url
  end
end
