require "test_helper"

class RuletypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ruletype = ruletypes(:one)
  end

  test "should get index" do
    get ruletypes_url
    assert_response :success
  end

  test "should get new" do
    get new_ruletype_url
    assert_response :success
  end

  test "should create ruletype" do
    assert_difference("Ruletype.count") do
      post ruletypes_url, params: { ruletype: { rtype: @ruletype.rtype } }
    end

    assert_redirected_to ruletype_url(Ruletype.last)
  end

  test "should show ruletype" do
    get ruletype_url(@ruletype)
    assert_response :success
  end

  test "should get edit" do
    get edit_ruletype_url(@ruletype)
    assert_response :success
  end

  test "should update ruletype" do
    patch ruletype_url(@ruletype), params: { ruletype: { rtype: @ruletype.rtype } }
    assert_redirected_to ruletype_url(@ruletype)
  end

  test "should destroy ruletype" do
    assert_difference("Ruletype.count", -1) do
      delete ruletype_url(@ruletype)
    end

    assert_redirected_to ruletypes_url
  end
end
