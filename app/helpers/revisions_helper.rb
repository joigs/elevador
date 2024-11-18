module RevisionsHelper
  def other_rule(inspection_id, rule_code)
    revision = Revision.find_by(inspection_id: inspection_id, codes: rule_code)
    revision ? revision.flaws : nil
  end



  def revision_level_or_g(rule, last_revision, revision_id)
    if last_revision&.codes&.include?(rule.code) and last_revision.id != revision_id
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

  def display_carpeta(index)
    if index == 1
      "Certificado conformidad MINVU."
    elsif index == 2
      "Plano de planta ascensores (primer piso)."
    elsif index == 3
      "Certificado de inscripción vigente del instalador."
    elsif index == 4
      "Declaración jurada del instalador, cumple normativa."
    elsif index == 5
      "Declaración jurada del instalador, que se ejecutaron los ensayos y que se encuentra sin fallas."
    elsif index == 6
      "Declaración de instalación eléctrica (te1) y plano respectivo."
    elsif index == 7
      "En ascensores electromecánicos vert. Se adjunta informe técnico."
    elsif index == 8
      "Plano y esp. Técnicas de cada uno anexo c norma 440/1 de los instaladores."
    elsif index == 9
      "Plan anual de mantención."
    elsif index == 10
      "Manual de procedimiento e inspecciones."
    elsif index == 11
      "Manual de uso e instrucciones de rescate."
    else
      "Error"
    end
  end
end

