class Revision < ApplicationRecord

  has_many :flaws
  accepts_nested_attributes_for :flaws

  belongs_to :item
  belongs_to :group
  belongs_to :inspection

  def only_owner?
    inspection = Inspection.find_by(id: self.inspection_id)
    inspection.user_id == Current.user&.id or Current.user&.admin?
  end



  private





end