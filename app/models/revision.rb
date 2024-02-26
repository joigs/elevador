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

  attribute :number, :integer, default: -> { calculate_new_number }


  def only_owner?
    inspection = Inspection.find_by(id: self.inspection_id)
    inspection.user_id == Current.user&.id
  end

  private

  def self.calculate_new_number
    # Get the newest record
    newest_record = Revision.order(created_at: :desc).first

    newest_record ? newest_record.number.to_i + 1 : 1
  end


end