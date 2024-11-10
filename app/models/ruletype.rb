#Comprobaciones
class Ruletype < ApplicationRecord



  def self.ransackable_attributes(auth_object = nil)
    ["rtype", "gygatype", "gygatype_number", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["rules"]
  end

  #el texto de la comprobacion
  validates :rtype, presence: true
  #gigatype es el texto ese que son los puntos principales, los más generales que hay en el informe
  validates :gygatype, presence: true
  before_save :set_gygatype_number


  has_many :rules, dependent: :destroy
  has_many :anothers, dependent: :destroy


  scope :ordered_by_gygatype_number, -> {
    select("ruletypes.*")
      .order(Arel.sql("
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(gygatype_number, '.', 1), '.', -1) AS UNSIGNED),
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(gygatype_number, '.', 2), '.', -1) AS UNSIGNED),
    CAST(IF(SUBSTRING_INDEX(SUBSTRING_INDEX(gygatype_number, '.', 3), '.', -1) = '', '0', SUBSTRING_INDEX(SUBSTRING_INDEX(gygatype_number, '.', 3), '.', -1)) AS UNSIGNED)
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
