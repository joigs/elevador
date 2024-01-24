class Group < ApplicationRecord
  validates :number, presence: true, uniqueness: true


  attribute :number, :integer, default: -> { calculate_new_number }

  ORDER_BY = {
    newest: "created_at DESC",
  }

  has_many :items, dependent: :restrict_with_exception
  has_many :rulesets, dependent: :destroy
  has_many :rules, through: :rulesets
  accepts_nested_attributes_for :rules


  private

  def self.calculate_new_number
    # Get the newest record
    newest_record = Group.order(ORDER_BY[:newest]).first

    newest_record ? newest_record.number.to_i + 1 : 1
  end
end
