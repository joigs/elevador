class Inspection < ApplicationRecord
  #para la busqueda
  include PgSearch::Model

  #valida que state solo tenga esos valores
  validates :state, inclusion: { in: ['Abierto', 'Cerrado'] }

  #valida que no se puedan agendar revisiones los fines de semana
  validate :weekend_error

  #calcula automaticamente el numero de inspeccion
  attribute :number, :integer, default: -> { calculate_new_number }

  #el como estan ordenados
  ORDER_BY = {
    newest: "created_at DESC",
  }

  belongs_to :user
  belongs_to :item
  accepts_nested_attributes_for :item



  #sirve para revisar si el usuario es el inspector encargado de la inspeccion, o si es admin
  def owner?
    user_id == Current.user&.id or Current.user&.admin?
  end




  private

#para calcular automaticamente el numero de inspeccion
  def self.calculate_new_number
    # Get the newest record
    newest_record = Inspection.order(ORDER_BY[:newest]).first

    newest_record ? newest_record.number.to_i + 1 : 1
  end

  #valida que no se puedan agendar revisiones los fines de semana
  def weekend_error
    if ins_date.present? && (ins_date.saturday? || ins_date.sunday?)
      errors.add(:ins_date, "No se hacen inspecciones los fines de semana")
    end
  end

end