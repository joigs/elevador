class Item < ApplicationRecord
  validates :identificador, presence: true

  belongs_to :group
end
