require "application_system_test_case"

class RuleTypesTest < ApplicationSystemTestCase
  setup do
    @ruletype = rule_types(:one)
  end

  test "visiting the index" do
    visit rule_types_url
    assert_selector "h1", text: "Rule types"
  end

  test "should create rule type" do
    visit rule_types_url
    click_on "New rule type"

    fill_in "Rtype", with: @ruletype.rtype
    click_on "Create Rule type"

    assert_text "Rule type was successfully created"
    click_on "Back"
  end

  test "should update Rule type" do
    visit rule_type_url(@ruletype)
    click_on "Edit this rule type", match: :first

    fill_in "Rtype", with: @ruletype.rtype
    click_on "Update Rule type"

    assert_text "Rule type was successfully updated"
    click_on "Back"
  end

  test "should destroy Rule type" do
    visit rule_type_url(@ruletype)
    click_on "Destroy this rule type", match: :first

    assert_text "Rule type was successfully destroyed"
  end
end
