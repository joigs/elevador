# app/helpers/places_helper.rb
module PlacesHelper
  require 'csv'

  def communes_by_region
    # Ajusta la ruta a tu CSV según dónde lo guardaste (app/templates/comunas.csv, etc.)
    csv_path = Rails.root.join('app', 'templates', 'comunas.csv')

    # Estructura: { "Atacama" => ["Copiapó", "Caldera", ...], "Antofagasta" => ["María Elena", ...], ... }
    regions_hash = Hash.new { |hash, key| hash[key] = [] }

    CSV.foreach(csv_path, headers: false) do |row|
      # row[0] = nombre comuna
      # row[4] = nombre región
      region = row[4]
      comuna = row[0]
      regions_hash[region] << comuna
    end

    # Opcional: asegurarnos de que no haya comunas repetidas
    regions_hash.each { |_, comunas| comunas.uniq! }

    regions_hash
  end
end
