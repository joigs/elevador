module RutProcessor
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_rut_columns
    before_validation :format_ruts
    validate :rut_validity
  end

  # Set multiple RUT columns; should be explicitly called from the model
  def set_rut_columns(*names)
    @rut_columns = names.map(&:to_s)
  end

  private

  def ensure_rut_columns
    @rut_columns ||= ['rut']  # Default to ['rut'] if nothing is set
  end

  def format_ruts
    @rut_columns.each do |column|
      clean_rut = send(column).delete('.-')
      rut_body = clean_rut[0...-1]
      verifier = clean_rut[-1].upcase
      formatted_rut = "#{rut_body.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse}-#{verifier}"
      send("#{column}=", formatted_rut)
    end
  end

  def rut_validity
    @rut_columns.each do |column|
      clean_rut = send(column).delete('.-')
      rut_body = clean_rut[0...-1]
      verifier = clean_rut[-1].upcase

      unless valid_rut?(rut_body, verifier)
        errors.add(column, 'is invalid')
      end
    end
  end

  def valid_rut?(rut_number, rut_dv)
    calculated_dv = calculate_rut_dv(rut_number)
    calculated_dv == rut_dv
  end

  def calculate_rut_dv(rut_number)
    sum = 0
    multiplier = 2

    rut_number.reverse.each_char do |char|
      sum += char.to_i * multiplier
      multiplier = multiplier < 7 ? multiplier + 1 : 2
    end

    remainder = sum % 11
    remainder == 0 ? '0' : remainder == 1 ? 'K' : (11 - remainder).to_s
  end
end
