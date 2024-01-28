#activos, ascensores, elevadores, etc.
class Item < ApplicationRecord
  validates :identificador, presence: true

  belongs_to :group
  #un ascensor pertenece a una empresa, y esa empresa tiene mandante, por lo que el ascensor tiene asignado una empresa y una mandante
  belongs_to :minor
  belongs_to :principal
  has_many :inspections, dependent: :destroy

end
