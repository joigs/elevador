class Inspection < ApplicationRecord
  #para la busqueda

  def self.ransackable_attributes(auth_object = nil)
    ["number", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["item", "principal"]
  end

  #el como estan ordenados
  ORDER_BY = {
    newest: "created_at DESC",
  }

  before_save :update_cambio_if_result_changed



  validates :ins_date, presence: { message: "Debes ingresar una fecha" }

  #valida que state solo tenga esos valores
  validates :state, inclusion: { in: ['Abierto', 'Cerrado', 'black'] }

  #valida que no se puedan agendar revisiones los fines de semana
  validate :weekend_error

  #calcula automaticamente el numero de inspeccion
  attribute :number, :integer, default: -> { calculate_new_number }
  validates :number, presence: true, uniqueness: true
  validates :ins_date, date: true
  validates :inf_date, date: true
  validates :rerun, inclusion: { in: [true, false] }
  validate :informe_format

  has_one_attached :informe

  has_many :inspection_users, dependent: :destroy
  has_many :users, through: :inspection_users
  belongs_to :item
  belongs_to :principal
  accepts_nested_attributes_for :item
  has_one :report, dependent: :destroy
  has_one :revision, dependent: :destroy
  has_one :ladder_revision, dependent: :destroy

  before_validation :set_principal_from_item

  #sirve para revisar si el usuario es el inspector encargado de la inspeccion, o si es admin
  def owner?
    users.exists?(id: Current.user&.id)
  end


  def self.human_attribute_name(attr, options = {})
    if attr == 'ins_date'
      'Fecha de inspección: '
    else
      super
    end
  end

  def check_and_update_state


    return unless report

    if Date.today > report.ending&
      self.result = 'Vencido'
    end
  end

  def self.check_all_expirations
    Inspection.all.find_each do |inspection|
      inspection.send(:check_and_update_state)
      inspection.save if inspection.changed?
    end
  end


  private

#para calcular automaticamente el numero de inspeccion
  def self.calculate_new_number
    # Get the newest record
    newest_record = Inspection.order(number: :desc).first

    newest_record ? newest_record.number.to_i + 1 : 1
  end

  #valida que no se puedan agendar revisiones los fines de semana
  def weekend_error
    if ins_date.present? && (ins_date.saturday? || ins_date.sunday?)
      errors.add(:ins_date, "No se pueden programar inspecciones los fines de semana.")
    end
  end


  def set_principal_from_item
    self.principal_id = self.item.principal_id if self.item
  end

  def informe_format
    return unless informe.attached?

    if informe.blob.content_type != "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      errors.add(:informe, "debe ser un archivo .docx")
    end
  end

  def update_cambio_if_result_changed
    if result_changed?
      self.cambio = Date.today
    end
  end

end