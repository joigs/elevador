class Revision < ApplicationRecord

  has_many :flaws, dependent: :destroy, inverse_of: :revision
  accepts_nested_attributes_for :flaws, allow_destroy: true, reject_if: :all_blank

  belongs_to :item
  belongs_to :group
  belongs_to :inspection

  def only_owner?
    inspection = Inspection.find_by(id: self.inspection_id)
    inspection.user_id == Current.user&.id or Current.user&.admin?
  end



  private





end