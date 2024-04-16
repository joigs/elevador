class Ladder < ApplicationRecord
  has_many rulesets, dependent: :destroy
end
