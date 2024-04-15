class NonNegativeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.nil? || value >= 0
      record.errors.add(:base, 'No se permiten valores negativos')
    end
  end
end