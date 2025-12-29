# app/models/inspection_monthly_report_sender.rb
require "write_xlsx"

class InspectionMonthlyReportSender
  def self.run!(to:)
    new.run!(to: to)
  end

  def self.run_daily_test
    run!(to: "joigsabra@hotmail.com")
  end

  def self.run_if_end_of_month(to: nil)
    today = Time.zone.today
    return unless today == today.end_of_month

    run!(to: to)
  end

  def run!(to:)

    recipients =
      if to.present?
        if to.is_a?(String)
          to.split(/[,\s;]+/).reject(&:blank?)
        else
          Array(to).map(&:to_s).flat_map { |s| s.split(/[,\s;]+/) }.reject(&:blank?)
        end
      else
        raw = ENV["INSPECTION_REPORT_TO"].to_s
        raw.split(/[,\s;]+/).reject(&:blank?)
      end

    latest_inspection_ids =
      Inspection.where("number > 0")
                .select(:id, :item_id, :number)
                .order(:item_id, number: :desc)
                .group_by(&:item_id)
                .values
                .map { |inspections| inspections.first.id }

    latest_inspections_scope = Inspection.where(id: latest_inspection_ids)

    today = Time.zone.today

    current_month_start = today.beginning_of_month
    current_month_end   = today.end_of_month

    next_month_start = current_month_start.next_month
    next_month_end   = next_month_start.end_of_month

    two_months_start = current_month_start.next_month(2)
    two_months_end   = two_months_start.end_of_month

    month_names_es = %w[
      enero febrero marzo abril mayo junio
      julio agosto septiembre octubre noviembre diciembre
    ]

    expired_month_name = month_names_es[current_month_start.month - 1]
    next_month_name    = month_names_es[next_month_start.month - 1]
    two_months_name    = month_names_es[two_months_start.month - 1]

    base_scope =
      latest_inspections_scope
        .joins(:report, item: :principal)
        .includes(:report, item: :principal)
        .where(state: "Cerrado", ignorar: false)

    vencido_results = ["Vencido (Aprobado)", "Vencido (Rechazado)"]
    vigente_results = ["Aprobado", "Rechazado"]

    expired_by_status_scope =
      base_scope
        .where(result: vencido_results)
        .where("reports.ending >= ? AND reports.ending <= ?",
               current_month_start, current_month_end)

    ending_last_day_scope =
      base_scope
        .where(result: vigente_results)
        .where("reports.ending = ?", current_month_end)

    expired_this_month_scope =
      expired_by_status_scope.or(ending_last_day_scope).distinct

    expired_this_month_approved =
      expired_this_month_scope.where(result: ["Vencido (Aprobado)", "Aprobado"])

    expired_this_month_rejected =
      expired_this_month_scope.where(result: ["Vencido (Rechazado)", "Rechazado"])

    next_month_approved =
      base_scope
        .where(result: "Aprobado")
        .where("reports.ending >= ? AND reports.ending <= ?",
               next_month_start, next_month_end)

    next_month_rejected =
      base_scope
        .where(result: "Rechazado")
        .where("reports.ending >= ? AND reports.ending <= ?",
               next_month_start, next_month_end)

    two_months_approved =
      base_scope
        .where(result: "Aprobado")
        .where("reports.ending >= ? AND reports.ending <= ?",
               two_months_start, two_months_end)

    two_months_rejected =
      base_scope
        .where(result: "Rechazado")
        .where("reports.ending >= ? AND reports.ending <= ?",
               two_months_start, two_months_end)


    excel_path     = nil
    excel_filename = "resumen_inspecciones_#{today.strftime('%Y_%m_%d')}.xlsx"

    Tempfile.create(['resumen_inspecciones', '.xlsx']) do |tmp|
      excel_path = tmp.path
      tmp.close

      workbook = WriteXLSX.new(excel_path)
      bold     = workbook.add_format(bold: 1)

      sheet_expired = workbook.add_worksheet(expired_month_name.capitalize[0, 31])
      sheet_next    = workbook.add_worksheet(next_month_name.capitalize[0, 31])
      sheet_two     = workbook.add_worksheet(two_months_name.capitalize[0, 31])

      [sheet_expired, sheet_next, sheet_two].each do |sh|
        sh.set_column(0, 0, 15)
        sh.set_column(1, 1, 25)
        sh.set_column(2, 2, 30)
        sh.set_column(3, 4, 16)
      end

      write_section = lambda do |sheet, start_row, title, inspections|
        row = start_row
        sheet.write(row, 0, title, bold)
        row += 2

        headers = ['N° Inspección', 'Activo', 'Empresa', 'Fecha inspección', 'Fecha término']
        headers.each_with_index do |h, col|
          sheet.write(row, col, h, bold)
        end

        row += 1

        inspections.each do |inspection|
          sheet.write(row, 0, inspection.number)
          sheet.write(row, 1, inspection.item&.identificador)
          sheet.write(row, 2, inspection.item&.principal&.name)
          sheet.write(row, 3, inspection.ins_date&.strftime('%d-%m-%Y'))
          sheet.write(row, 4, inspection.report&.ending&.strftime('%d-%m-%Y'))
          row += 1
        end

        row
      end

      write_month_sheet = lambda do |sheet, month_name, approved_collection, rejected_collection, mode:|
        base_verb = mode == :expired ? "vencieron" : "vencen"

        row = 0

        title_approved = "Equipos que #{base_verb} en #{month_name.capitalize} (aprobados)"
        row = write_section.call(sheet, row, title_approved, approved_collection)

        row += 6

        title_rejected = "Equipos que #{base_verb} en #{month_name.capitalize} (rechazados)"
        row = write_section.call(sheet, row, title_rejected, rejected_collection)

        row
      end

      write_month_sheet.call(
        sheet_expired,
        expired_month_name,
        expired_this_month_approved,
        expired_this_month_rejected,
        mode: :expired
      )

      write_month_sheet.call(
        sheet_next,
        next_month_name,
        next_month_approved,
        next_month_rejected,
        mode: :future
      )

      write_month_sheet.call(
        sheet_two,
        two_months_name,
        two_months_approved,
        two_months_rejected,
        mode: :future
      )

      workbook.close
    end


    subject = "Alertas de certificaciones vencidas y por vencer"

    NotifierMailer.inspections_warnings(
      to: recipients,
      subject:,
      expired_this_month_approved:,
      expired_this_month_rejected:,
      next_month_approved:,
      next_month_rejected:,
      two_months_approved:,
      two_months_rejected:,
      expired_month_name:,
      next_month_name:,
      two_months_name:
    ).deliver_now


    { to: to }
  end
end
