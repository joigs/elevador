class Rule < ApplicationRecord
  validates :point, presence: true

  belongs_to :group
end
