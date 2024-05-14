class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present?
      min_year = options.fetch(:min_year, 1900)
      max_year = options.fetch(:max_year, 3000)
      if value.year < min_year || value.year > max_year
        record.errors.add(attribute, (options[:message] || "Fecha inválida. Debe estar entre #{min_year} y #{max_year}."))
      end
    end
  end
end
