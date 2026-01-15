#La clasificación de los ascensores, de esto depende que defectos se evaluan
class Group < ApplicationRecord
  validates :number, presence: true, uniqueness: true, non_negative: true
  validates :name, presence: true, uniqueness: true
  validates :type_of, inclusion: { in: %w[ascensor escala libre plat], message: "%{value} no es un tipo válido" }


  attribute :number, :integer, default: -> { calculate_new_number }

  ORDER_BY = {
    newest: "created_at DESC",
  }

  has_many :items, dependent: :restrict_with_error
  has_many :rulesets, dependent: :destroy
  has_many :revisions
  has_many :rules, through: :rulesets
  has_many :rules_plats
  has_many :plat_revisions
  accepts_nested_attributes_for :rules

  TYPE_TO_ASSOC = {
    "escala"   => :ladder_revision,
    "ascensor" => :revision,
    "plat"     => :plat_revision
  }.freeze

  def revision_for(object)
    method = TYPE_TO_ASSOC[type_of]
    return nil unless method

    object.public_send(method)
  end

  def revision_for!(object)
    method = TYPE_TO_ASSOC.fetch(type_of) do
      raise ArgumentError, "type_of no soportado: #{type_of.inspect}"
    end
    object.public_send(method)
  end
  private

  #para calcular automaticamente el numero de grupo
  def self.calculate_new_number
    records = Group.order(number: :asc)



    records.each_with_index do |record, index|
      return record.number + 1 if index == (records.size - 1)
      return record.number + 1 if record.number != (records[index+1].number - 1)
    end

    return 1


  end



end