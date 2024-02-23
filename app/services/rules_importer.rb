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
      level << 'L' if row[3]&.cell_value == 'x'
      level << 'G' if row[4]&.cell_value == 'x'

      point = row[0].cell_value
      code = row[1].cell_value

      if old_rule = Rule.find_by(point: point, code: code, ins_type: ins_type, level: level)
          Ruleset.create(group: group, rule: old_rule)
      else
        rules_data << Rule.new(
          point: point,
          code: code,
          ins_type: ins_type,
          level: level,
          ruletype_id: ruletype.id
        )
      end


    end

    Rule.import rules_data unless rules_data.empty?
    rules_data.each { |rule| Ruleset.create(group: group, rule: rule) }
  end
end
