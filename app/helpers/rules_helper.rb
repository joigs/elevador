module RulesHelper
  #Ve la variable level del defecto y lo interpreta al usuario
  def display_rule_level(rule)
    if rule.level.include?('G') && rule.level.include?('L')
      "A decisión del inspector"
    elsif rule.level.include?('G')
      "Grave"
    elsif rule.level.include?('L')
      "Leve"
    else
      "Error"
    end
  end

  #Ve la variable ins_type del defecto y lo interpreta al usuario
  def display_rule_ins_type(rule)
    types = rule.ins_type

    result = []

    result << 'DO' if types.include?('DO')
    result << 'VI' if types.include?('VI')
    result << 'FU' if types.include?('FU')
    result << 'DI' if types.include?('DI')

    if result.size >= 2
      result.join('-')
    else
      result.join('')
    end
  end
end