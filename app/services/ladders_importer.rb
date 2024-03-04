require 'roo'

class LaddersImporter
  def self.import(file_path)
    xlsx = Roo::Spreadsheet.open(file_path)
    ladders_data = []

    xlsx.sheet(0).each_row_streaming(offset: 0) do |row|


      level = []
      level << 'L'
      level << 'G'

      number = row[0].cell_value
      next unless number
      point = row[1].cell_value
      code = row[2].cell_value
      priority = row[3].cell_value

      ladders_data << Ladder.new(
        point: point,
        code: code,
        number: number,
        level: level,
        priority: priority
      )


    end

    Ladder.import ladders_data unless ladders_data.empty?
  end
end