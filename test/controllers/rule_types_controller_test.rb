require "test_helper"

class RuleTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ruletype = rule_types(:one)
  end

  test "should get index" do
    get rule_types_url
    assert_response :success
  end

  test "should get new" do
    get new_rule_type_url
    assert_response :success
  end

  test "should create ruletype" do
    assert_difference("Ruletype.count") do
      post rule_types_url, params: { ruletype: { rtype: @ruletype.rtype } }
    end

    assert_redirected_to rule_type_url(Ruletype.last)
  end

  test "should show ruletype" do
    get rule_type_url(@ruletype)
    assert_response :success
  end

  test "should get edit" do
    get edit_rule_type_url(@ruletype)
    assert_response :success
  end

  test "should update ruletype" do
    patch rule_type_url(@ruletype), params: { ruletype: { rtype: @ruletype.rtype } }
    assert_redirected_to rule_type_url(@ruletype)
  end

  test "should destroy ruletype" do
    assert_difference("Ruletype.count", -1) do
      delete rule_type_url(@ruletype)
    end

    assert_redirected_to rule_types_url
  end
end
