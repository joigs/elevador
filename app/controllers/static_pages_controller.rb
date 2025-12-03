class StaticPagesController < ApplicationController
  def warnings
    params[:filter] ||= "expiring_soon"

    latest_inspection_ids =
      Inspection.where("number > 0")
                .select(:id, :item_id, :number)
                .order(:item_id, number: :desc)
                .group_by(&:item_id)
                .values
                .map { |inspections| inspections.first.id }

    latest_inspections_scope = Inspection.where(id: latest_inspection_ids)

    inspections_scope =
      case params[:filter]
      when "expiring_soon"
        latest_inspections_scope
          .joins(:report)
          .where("reports.ending > ?", Time.zone.today)
          .where("reports.ending <= ?", Time.zone.today + 2.months)
          .where(state: "Cerrado", result: "Aprobado", ignorar: false)
          .includes(:report)

      when "vencido"
        latest_inspections_scope
          .vencidos
          .where(ignorar: false)


      when "again_soon"
        latest_inspections_scope
          .joins(:report)
          .where("reports.ending > ?", Time.zone.today)
          .where("reports.ending <= ?", Time.zone.today + 2.months)
          .where(state: "Cerrado", result: "Rechazado", ignorar: false)
          .includes(:report)

      when "ignored"
        latest_inspections_scope
          .where(ignorar: true)

      else
        Inspection.none
      end

    @q = inspections_scope.ransack(params[:q])
    @inspections = @q.result(distinct: true)

    unless Current.user.tabla
      @pagy, @inspections = pagy_countless(@inspections, items: 10)
    end

    @filter = params[:filter]
  end



  def info
    @active_tab = params[:tab].presence || "empresas"

    if @active_tab == "empresas"
      grouped = Hash.new { |h, k| h[k] = { nombres: {}, roles: {}, insps: {} } }

      Report.joins(:inspection)
            .where.not(em_rut: [nil, ""])
            .pluck(:em_rut, :empresa_mantenedora, :em_rol, 'inspections.number', 'inspections.id')
            .each do |rut, nombre, rol, ins_number, ins_id|
        rut = rut.to_s.strip
        grouped[rut][:nombres][normalize_for_dedup(nombre)] ||= nombre.strip if nombre.present?
        grouped[rut][:roles][normalize_for_dedup(rol)]       ||= rol.strip    if rol.present?
        grouped[rut][:insps][ins_number] = ins_id if ins_number.present? && ins_id.present?
      end

      @empresas = grouped.map { |rut, h|
        {
          em_rut: rut,
          empresa_mantenedora: h[:nombres].values.join(" / "),
          em_rol: h[:roles].values.join(" / "),
          inspections_map: h[:insps]
        }
      }.sort_by { |e| [e[:empresa_mantenedora].to_s, e[:em_rut].to_s] }
    end
  end

  def export_empresas_xlsx
    grouped = Hash.new { |h, k| h[k] = { nombres: {}, roles: {}, insps: {} } }

    Report.joins(:inspection)
          .where.not(em_rut: [nil, ""])
          .pluck(:em_rut, :empresa_mantenedora, :em_rol, 'inspections.number', 'inspections.id')
          .each do |rut, nombre, rol, ins_number, ins_id|
      rut = rut.to_s.strip
      grouped[rut][:nombres][normalize_for_dedup(nombre)] ||= nombre.strip if nombre.present?
      grouped[rut][:roles][normalize_for_dedup(rol)]       ||= rol.strip    if rol.present?
      grouped[rut][:insps][ins_number] = ins_id if ins_number.present? && ins_id.present?
    end

    empresas = grouped.map { |rut, h|
      {
        em_rut: rut,
        empresa_mantenedora: h[:nombres].values.join(" / "),
        em_rol: h[:roles].values.join(" / "),
        inspections_numbers: h[:insps].keys.sort_by(&:to_i).join(" / ")
      }
    }.sort_by { |e| [e[:empresa_mantenedora].to_s, e[:em_rut].to_s] }

    Tempfile.create(['empresas_mantenedoras', '.xlsx']) do |tmp|
      path = tmp.path
      tmp.close

      workbook = WriteXLSX.new(path)
      sheet    = workbook.add_worksheet('Empresas Mantenedoras')
      bold     = workbook.add_format(bold: 1)

      headers = ['RUT', 'Empresa mantenedora', 'Rol', 'Inspecciónes (número)']
      sheet.write_row(0, 0, headers, bold)

      empresas.each_with_index do |e, idx|
        row = idx + 1
        sheet.write_row row, 0, [
          e[:em_rut],
          e[:empresa_mantenedora],
          e[:em_rol],
          e[:inspections_numbers]
        ]
      end

      sheet.set_column(0, 0, 14)
      sheet.set_column(1, 1, 50)
      sheet.set_column(2, 2, 30)
      sheet.set_column(3, 3, 28)

      workbook.close

      send_data File.binread(path),
                filename: "empresas_mantenedoras_#{Time.zone.now.strftime('%Y%m%d_%H%M')}.xlsx",
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                disposition: :attachment

      DeleteTempFileJob.set(wait: 5.minutes).perform_later(path) if defined?(DeleteTempFileJob)
    end
  end

  private

  def normalize_for_dedup(s)
    ActiveSupport::Inflector.transliterate(s.to_s)
                            .downcase
                            .gsub(/[[:punct:]]+/, " ")
                            .gsub(/\s+/, " ")
                            .strip
  end
end
