require "test_helper"

class LaddersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ladder = ladders(:one)
  end

  test "should get index" do
    get ladders_url
    assert_response :success
  end

  test "should get new" do
    get new_ladder_url
    assert_response :success
  end

  test "should create ladder" do
    assert_difference("Ladder.count") do
      post ladders_url, params: { ladder: { code: @ladder.code, level: @ladder.level, number: @ladder.number, point: @ladder.point, priority: @ladder.priority } }
    end

    assert_redirected_to ladder_url(Ladder.last)
  end

  test "should show ladder" do
    get ladder_url(@ladder)
    assert_response :success
  end

  test "should get edit" do
    get edit_ladder_url(@ladder)
    assert_response :success
  end

  test "should update ladder" do
    patch ladder_url(@ladder), params: { ladder: { code: @ladder.code, level: @ladder.level, number: @ladder.number, point: @ladder.point, priority: @ladder.priority } }
    assert_redirected_to ladder_url(@ladder)
  end

  test "should destroy ladder" do
    assert_difference("Ladder.count", -1) do
      delete ladder_url(@ladder)
    end

    assert_redirected_to ladders_url
  end
end
