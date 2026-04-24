class UserPreferencia < ApplicationRecord
  belongs_to :user
  belongs_to :preferencia
end