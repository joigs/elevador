require 'roo'

class RulesPlatsImporter
  def self.import(file_path)
    xlsx = Roo::Spreadsheet.open(file_path)
    rules_data = []

    xlsx.sheet(0).each_row_streaming(offset: 0) do |row|


      level = []
      level << 'L'
      level << 'G'

      code = row[0].cell_value

      break unless code
      point = row[1].cell_value
      ref = row[2].cell_value

      rules_data << RulesPlat.new(
        point: point,
        code: code,
        ref: ref,
        level: level,
      )


    end


    RulesPlat.import rules_data unless rules_data.empty?
  end
end