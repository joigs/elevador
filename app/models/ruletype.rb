#Comprobaciones
class Ruletype < ApplicationRecord
  #el texto de la comprobacion
  validates :rtype, presence: true
  #gigatype es el texto ese que son los puntos principales, los más generales que hay en el informe
  validates :gygatype, presence: true
  before_save :set_gygatype_number


  has_many :rules, dependent: :destroy

  scope :ordered_by_gygatype_number, -> {
    select("ruletypes.*")
      .order(Arel.sql("
      CAST(split_part(gygatype_number, '.', 1) AS INTEGER),
      CAST(split_part(gygatype_number, '.', 2) AS INTEGER),
      CASE WHEN split_part(gygatype_number, '.', 3) = '' THEN 0 ELSE CAST(split_part(gygatype_number, '.', 3) AS INTEGER) END
    "))
  }

  private

  def set_gygatype_number
    base_number = self.gygatype.split('.').first
    if base_number == '9'
      base_number = self.gygatype.split('.').slice(0..-2).join('.')
      if base_number == '9'
        base_number = '9.0'
      end
    end

    suffix = Ruletype.where("gygatype_number LIKE ?", "#{base_number}.%").count + 1
    self.gygatype_number = "#{base_number}.#{suffix}"

  end



end
