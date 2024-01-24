class Rule < ApplicationRecord
  validates :point, presence: true

  belongs_to :ruletype
  has_many :rulesets, dependent: :destroy
  has_many :groups, through: :rulesets
  accepts_nested_attributes_for :rulesets
end
