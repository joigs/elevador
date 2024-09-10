#La clasificación de los ascensores, de esto depende que defectos se evaluan
class Group < ApplicationRecord
  validates :number, presence: true, uniqueness: true, non_negative: true
  validates :name, presence: true, uniqueness: true
  validates :type_of, inclusion: { in: %w[ascensor escala libre], message: "%{value} no es un tipo válido" }


  attribute :number, :integer, default: -> { calculate_new_number }

  ORDER_BY = {
    newest: "created_at DESC",
  }

  has_many :items, dependent: :restrict_with_error
  has_many :rulesets, dependent: :destroy
  has_many :revisions
  has_many :rules, through: :rulesets
  accepts_nested_attributes_for :rules


  private

  #para calcular automaticamente el numero de grupo
  def self.calculate_new_number
    records = Group.order(number: :asc)



    records.each_with_index do |record, index|
      return record.number + 1 if index == (records.size - 1)
      return record.number + 1 if record.number != (records[index+1].number - 1)
    end

    if !records
      return 1
    end

  end



end