class Ruletype < ApplicationRecord
  validates :rtype, presence: true
  validates :gygatype, presence: true
  before_save :set_gygatype_number


  has_many :rules, dependent: :destroy

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
