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
    I18n.l(date.to_date, format: "%B %Y").to_s.sub(/\A./) { |c| c.upcase }
  end

  def proxima_inspeccion_info(inspection)
    ending = inspection.ins_date
    return { text: "N/A", order: nil } if ending.blank?

    estado = inspection.result.to_s.strip.downcase.gsub(/\s+/, " ")

    aprobados  = ["aprobado", "vencido (aprobado)"]
    rechazados = ["rechazado", "vencido (rechazado)"]

    if aprobados.include?(estado)
      return {
        text:  mes_anio_es(ending),
        order: ending.strftime("%Y%m01")
      }
    end

    if rechazados.include?(estado)
      identificador = inspection.item&.identificador.to_s

      despues = identificador.split("-", 2)[1].to_s
      limpio  = despues.gsub(/[^0-9A-Za-z]/, "")

      rol = limpio[4]
      periodo    = ROL_A_PERIODO[rol]
      mes_inicio = ROL_A_MES_INICIO[rol]

      return { text: "N/A", order: nil } if periodo.blank? || mes_inicio.blank?

      anio = ending.year

      anio += 1 if mes_inicio <= ending.month

      anio += 1 if inspection.validation.to_i == 2

      return {
        text:  "#{periodo} #{anio}",
        order: format("%04d%02d01", anio, mes_inicio)
      }
    end

    # Fallback general
    { text: mes_anio_es(ending), order: ending.strftime("%Y%m01") }
  end
end
