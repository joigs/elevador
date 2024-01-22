class Inspection < ApplicationRecord

  include PgSearch::Model


  validates :state, inclusion: { in: ['Abierto', 'Cerrado'] }

  validate :weekend_error


  attribute :number, :integer, default: -> { calculate_new_number }

  ORDER_BY = {
    newest: "created_at DESC",
  }

  belongs_to :user, default: -> { Current.user }

  def owner?
    user_id == Current.user&.id or Current.user&.admin?
  end




  private

  def self.calculate_new_number
    # Get the newest record
    newest_record = Inspection.order(ORDER_BY[:newest]).first

    newest_record ? newest_record.number.to_i + 1 : 1  end

  def weekend_error
    if ins_date.present? && (ins_date.saturday? || ins_date.sunday?)
      errors.add(:ins_date, "No se hacen inspecciones los fines de semana")
    end
  end

end