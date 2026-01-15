

# app/helpers/items_helper.rb
module ItemsHelper
  ROL_A_PERIODO = {
    "0" => "Ene-Feb-Mar",
    "1" => "Abril",
    "2" => "Mayo",
    "3" => "Junio",
    "4" => "Julio",
    "5" => "Agosto",
    "6" => "Septiembre",
    "7" => "Octubre",
    "8" => "Noviembre",
    "9" => "Diciembre"
  }.freeze

  # Para ordenar, usamos el primer mes del periodo como referencia
  ROL_A_MES_INICIO = {
    "0" => 1,
    "1" => 4,
    "2" => 5,
    "3" => 6,
    "4" => 7,
    "5" => 8,
    "6" => 9,
    "7" => 10,
    "8" => 11,
    "9" => 12
  }.freeze
  def last_inspection(item)
    item.inspections.order(number: :desc).first
  end
  def mes_anio_es(date)
    # Requiere locale :es para que %B salga en español
    I18n.l(date.to_date, format: "%B %Y").to_s.sub(/\A./) { |c| c.upcase }
  end

  # Retorna { text: "...", order: "YYYYMMDD/YYYMM01" }
  def proxima_inspeccion_info(inspection)
    ending = inspection.ins_date
    return { text: "N/A", order: nil } if ending.blank?

    # Normaliza el texto del estado (quita espacios extra)
    estado = inspection.result.to_s.strip.downcase.gsub(/\s+/, " ")

    aprobados  = ["aprobado", "vencido (aprobado)"]
    rechazados = ["rechazado", "vencido (rechazado)"]

    # Aprobado / Vencido (Aprobado) => Mes Año desde report.ending
    if aprobados.include?(estado)
      return {
        text:  mes_anio_es(ending),
        order: ending.strftime("%Y%m01")
      }
    end

    # Rechazado / Vencido (Rechazado) => mapeo por rol + año (y +1 si validation==2)
    if rechazados.include?(estado)
      identificador = inspection.item&.identificador.to_s

      # Parte después del primer "-" y limpiamos símbolos (incluye guiones)
      despues = identificador.split("-", 2)[1].to_s
      limpio  = despues.gsub(/[^0-9A-Za-z]/, "") # elimina '-', espacios, etc.

      rol = limpio[4] # 5to carácter (0-based)
      periodo   = ROL_A_PERIODO[rol]
      mes_inicio = ROL_A_MES_INICIO[rol]

      anio = ending.year
      anio += 1 if inspection.validation.to_i == 2

      if periodo.present? && mes_inicio.present?
        return {
          text:  "#{periodo} #{anio}",
          order: format("%04d%02d01", anio, mes_inicio)
        }
      end

      # Fallback si el identificador no calza (evita N/A)
      return { text: mes_anio_es(ending), order: ending.strftime("%Y%m01") }
    end

    # Fallback general
    { text: mes_anio_es(ending), order: ending.strftime("%Y%m01") }
  end
end
