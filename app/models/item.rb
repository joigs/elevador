#activos, ascensores, elevadores, etc.
class Item < ApplicationRecord
  validates :identificador, presence: true, uniqueness: true

  belongs_to :group
  #un ascensor pertenece a una empresa, y esa empresa tiene mandante, por lo que el ascensor tiene asignado una empresa y una mandante
  belongs_to :principal
  has_one :detail, dependent: :destroy
  has_many :inspections, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :revisions, dependent: :destroy

  def inspector?
    self.inspections.each do |inspection|
      if inspection.user_id == Current.user&.id
        return true
      end
    end
    return false
  end

end
