#activos, ascensores, elevadores, etc.
class Item < ApplicationRecord





  validates :identificador, presence: true, uniqueness: true

  belongs_to :group
  belongs_to :principal
  has_one :detail, dependent: :destroy
  has_many :inspections, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :revisions, dependent: :destroy
  has_one :ladder_detail, dependent: :destroy
  has_many :ladder_revisions, dependent: :destroy
  def inspector?
    self.inspections.each do |inspection|
      if inspection.user_id == Current.user&.id
        return true
      end
    end
    return false
  end

end
