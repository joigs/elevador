require "test_helper"

class LadderRevisionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ladder_revision = ladder_revisions(:one)
  end

  test "should get index" do
    get ladder_revisions_url
    assert_response :success
  end

  test "should get new" do
    get new_ladder_revision_url
    assert_response :success
  end

  test "should create ladder_revision" do
    assert_difference("LadderRevision.count") do
      post ladder_revisions_url, params: { ladder_revision: { codes: @ladder_revision.codes, comment: @ladder_revision.comment, fail: @ladder_revision.fail, inspection_id: @ladder_revision.inspection_id, item_id: @ladder_revision.item_id, levels: @ladder_revision.levels, number: @ladder_revision.number, points: @ladder_revision.points, priority: @ladder_revision.priority } }
    end

    assert_redirected_to ladder_revision_url(LadderRevision.last)
  end

  test "should show ladder_revision" do
    get ladder_revision_url(@ladder_revision)
    assert_response :success
  end

  test "should get edit" do
    get edit_ladder_revision_url(@ladder_revision)
    assert_response :success
  end

  test "should update ladder_revision" do
    patch ladder_revision_url(@ladder_revision), params: { ladder_revision: { codes: @ladder_revision.codes, comment: @ladder_revision.comment, fail: @ladder_revision.fail, inspection_id: @ladder_revision.inspection_id, item_id: @ladder_revision.item_id, levels: @ladder_revision.levels, number: @ladder_revision.number, points: @ladder_revision.points, priority: @ladder_revision.priority } }
    assert_redirected_to ladder_revision_url(@ladder_revision)
  end

  test "should destroy ladder_revision" do
    assert_difference("LadderRevision.count", -1) do
      delete ladder_revision_url(@ladder_revision)
    end

    assert_redirected_to ladder_revisions_url
  end
end
