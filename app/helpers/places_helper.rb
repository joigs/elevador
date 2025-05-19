# app/helpers/places_helper.rb
module PlacesHelper
  require 'csv'

  def communes_by_region
    csv_path = Rails.root.join('app', 'templates', 'comunas.csv')

    regions_hash = Hash.new { |hash, key| hash[key] = [] }

    CSV.foreach(csv_path, headers: false) do |row|
      region = row[4]
      comuna = row[0]
      regions_hash[region] << comuna
    end

    regions_hash.each { |_, comunas| comunas.uniq! }

    regions_hash
  end
end
