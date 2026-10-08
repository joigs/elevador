class PrincipalUser < ApplicationRecord
  belongs_to :user
  belongs_to :principal

  validates :principal_id, uniqueness: { scope: :user_id }
end