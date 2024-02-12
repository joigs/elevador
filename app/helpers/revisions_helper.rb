module RevisionsHelper
  def other_rule(inspection_id, rule_code)
    revision = Revision.find_by(inspection_id: inspection_id, codes: rule_code)
    revision ? revision.flaws : nil
  end

  def revision_label_text(rule, last_revision)
    if last_revision&.codes&.include?(rule.code)
      if last_revision.points.include?(rule.point)
        "#{rule.code} #{rule.point} Grave"
      else
        "#{rule.code} #{display_rule_ins_type(rule)} #{rule.point} #{display_rule_level_short(rule)}"
      end
    else
      "#{rule.code} #{display_rule_ins_type(rule)} #{rule.point} #{display_rule_level_short(rule)}"
    end
  end

  def revision_level_or_g(rule, last_revision)
    if last_revision&.codes&.include?(rule.code)
      if last_revision.points.include?(rule.point)
        "G"
      else
        rule.level
      end
    else
      rule.level
    end
  end
  def display_rule_level_short(rule)
    if rule.level.include?('G') && rule.level.include?('L')
      "Depende"
    elsif rule.level.include?('G')
      "Grave"
    elsif rule.level.include?('L')
      "Leve"
    else
      "Error"
    end
  end
end