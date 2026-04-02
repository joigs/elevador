require 'roo'

class RulesPlatsImporter
  def self.import(file_path, group_id:)
    xlsx = Roo::Spreadsheet.open(file_path)
    rules_data = []

    xlsx.sheet(0).each_row_streaming(offset: 0) do |row|
      next if row.nil? || row.compact.empty?

      code = row[0]&.cell_value
      break if code.blank?

      point = row[1]&.cell_value
      ref   = row[2]&.cell_value

      rules_data << RulesPlat.new(
        point: point,
        code: code,
        ref: ref,
        level: ['L', 'G'],
        group_id: group_id
      )
    end

    RulesPlat.import(rules_data) unless rules_data.empty?
  end
end