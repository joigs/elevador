class Revision < ApplicationRecord



  belongs_to :item
  belongs_to :group
  belongs_to :inspection
  has_many :revision_photos, dependent: :destroy
  accepts_nested_attributes_for :revision_photos, allow_destroy: true

  def only_owner?
    inspection = Inspection.find_by(id: self.inspection_id)
    inspection.user_id == Current.user&.id or Current.user&.admin?
  end

  private
end