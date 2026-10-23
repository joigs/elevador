class SucursalUser < ApplicationRecord
  belongs_to :user
  belongs_to :sucursal

  validates :sucursal_id, uniqueness: { scope: :user_id }
end
