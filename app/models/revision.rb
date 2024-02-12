class Revision < ApplicationRecord


  attribute :number, :integer, default: -> { calculate_new_number }


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

  def self.calculate_new_number
    # Get the newest record
    newest_record = revision.order(ORDER_BY[:newest]).first

    newest_record ? newest_record.number.to_i + 1 : 1
  end

  #valida que no se puedan agendar revisiones los fines de semana
  def weekend_error
    if ins_date.present? && (ins_date.saturday? || ins_date.sunday?)
      errors.add(:ins_date, "No se hacen inspecciones los fines de semana")
    end
  end
end