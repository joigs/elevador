class Ruleset < ApplicationRecord
  belongs_to :group
  belongs_to :rule
end
