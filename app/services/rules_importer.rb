require 'roo'

class RulesImporter
  def self.import(file_path, group_id)
    group = Group.find(group_id)
    xlsx = Roo::Spreadsheet.open(file_path)
    rules_data = []

    xlsx.sheet(0).each_row_streaming(offset: 0) do |row|
      rule_code_modified = row[1].cell_value.to_s.sub(/\.[^.]*\z/, "")


      ruletype = Ruletype.find_by(gygatype_number: rule_code_modified)

      next unless ruletype

      ins_type = row[2].cell_value.split(',').map(&:strip)
      level = []
      if row[3]&.cell_value == 'L'
        level << 'L'
      else
        level << 'G'
      end
      level << 'G' if row[4]&.cell_value == 'G'

      point = row[0].cell_value
      code = row[1].cell_value

      puts(code)
      puts(level)
      puts("1: #{row[3]&.cell_value}")
      puts("2: #{row[4]&.cell_value}")
        rules_data << Rule.new(
          point: point,
          code: code,
          ins_type: ins_type,
          level: level,
          ruletype_id: ruletype.id
        )


    end

    rules_data.each { |rule| Ruleset.create(group: group, rule: rule) } unless rules_data.empty?
  end
end
