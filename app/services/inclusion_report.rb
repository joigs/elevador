module InclusionReport
  TEXTO_PENDIENTES = "De los aspectos evaluados, se identificaron condiciones que se encuentran pendientes de " \
                     "implementación, las cuales se detallan en la presente lista de verificación, con el objeto de " \
                     "informar al propietario y/o administrador respecto de las medidas que deberán ser consideradas " \
                     "para avanzar en la adecuación del equipo y su entorno a las exigencias de accesibilidad que " \
                     "resulten aplicables."

  TEXTO_SIN_PENDIENTES = "De los aspectos evaluados, no se identificaron condiciones pendientes de implementación " \
                         "respecto de las condiciones de accesibilidad verificadas en la presente lista."

  TEXTO_NO_REGISTRADA = "La lista de verificación de condiciones de accesibilidad no fue registrada durante la inspección."

  def self.reemplazar(doc, registro)
    checks = registro.inclusion_checks.index_by(&:numero)

    InclusionCheck::CRITERIOS.each do |criterio|
      n      = criterio[:numero]
      check  = checks[n]
      estado = check&.estado

      doc.replace("{{inc_#{n}_cumple}}", estado == "Cumple" ? "X" : "")
      doc.replace("{{inc_#{n}_no}}",     estado == "No implementado" ? "X" : "")
      doc.replace("{{inc_#{n}_na}}",     estado == "N/A" ? "X" : "")
      doc.replace("{{inc_#{n}_obs}}",    check&.comment.to_s)
    end

    conclusion =
      if checks.empty?
        TEXTO_NO_REGISTRADA
      elsif checks.values.any?(&:no_implementado)
        TEXTO_PENDIENTES
      else
        TEXTO_SIN_PENDIENTES
      end

    doc.replace("{{inc_conclusion}}", conclusion)
  end

  def self.fotos(registro)
    return [] unless registro.inclusion_aplica?

    elementos = InclusionCheck::CRITERIOS.index_by { |c| c[:numero] }

    registro.inclusion_checks.with_attached_photos.order(:numero).flat_map do |check|
      texto = "Inclusión #{check.numero}. #{elementos.dig(check.numero, :elemento)}"
      texto += ": #{check.comment}" if check.comment.present?
      check.photos.map { |foto| [foto, texto] }
    end
  end
end
