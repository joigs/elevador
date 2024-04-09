require 'roo'

class RuletypesImporter
  def self.import(file_path)
    xlsx = Roo::Spreadsheet.open(file_path)
    ruletypes_data = []

    xlsx.sheet(0).each_row_streaming(offset: 1) do |row|
      rtype = row[0].cell_value
      gygatype = row[1].cell_value
      gygatype_number = row[2].cell_value
      unless Ruletype.exists?(rtype: rtype)
        ruletypes_data << Ruletype.new(
          rtype: rtype,
          gygatype: gygatype,
          gygatype_number: gygatype_number
        )
      end
    end

    Ruletype.import ruletypes_data unless ruletypes_data.empty?
  end
end
