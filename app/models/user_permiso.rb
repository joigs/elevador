class UserPermiso < ApplicationRecord
  belongs_to :user
  belongs_to :permiso
end
