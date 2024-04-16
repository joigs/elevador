#tabla join para relacionar rules con groups, pues rules tiene muechos groups y groups tienen muchas rules
class Ruleset < ApplicationRecord
  belongs_to :group
  belongs_to :rule
  belongs_to :ladder
end
