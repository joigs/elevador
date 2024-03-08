class LadderRevision < ApplicationRecord
  belongs_to :inspection
  belongs_to :item

  has_many :revision_colors, as: :revision, dependent: :destroy
  has_many :revision_photos, as: :revision, dependent: :destroy
  has_many :revision_nulls, as: :revision, dependent: :destroy

  accepts_nested_attributes_for :revision_photos, allow_destroy: true
  accepts_nested_attributes_for :revision_nulls, allow_destroy: true
  accepts_nested_attributes_for :revision_colors, allow_destroy: true



  def only_owner?
    inspection = Inspection.find_by(id: self.inspection_id)
    inspection.user_id == Current.user&.id
  end
end
