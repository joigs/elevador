class Revision < ApplicationRecord




  belongs_to :item
  belongs_to :group
  belongs_to :inspection
  has_many :revision_photos, dependent: :destroy
  has_many :revision_nulls, dependent: :destroy
  has_many :revision_colors, dependent: :destroy
  accepts_nested_attributes_for :revision_photos, allow_destroy: true
  accepts_nested_attributes_for :revision_nulls, allow_destroy: true
  accepts_nested_attributes_for :revision_colors, allow_destroy: true



  def only_owner?
    inspection = Inspection.find_by(id: self.inspection_id)
    inspection.user_id == Current.user&.id
  end



end