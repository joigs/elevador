class Revision < ApplicationRecord




  belongs_to :item
  belongs_to :group
  belongs_to :inspection
  has_many :revision_photos, dependent: :destroy
  has_many :bags, dependent: :destroy
  accepts_nested_attributes_for :revision_photos, allow_destroy: true
  accepts_nested_attributes_for :bags, allow_destroy: true

  def only_owner?
    inspection = Inspection.find_by(id: self.inspection_id)
    inspection.user_id == Current.user&.id
  end

  private

  def self.calculate_new_number
    # Get the newest record
    newest_record = revision.order(ORDER_BY[:newest]).first

    newest_record ? newest_record.number.to_i + 1 : 1
  end


end