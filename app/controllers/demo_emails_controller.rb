# app/controllers/demo_emails_controller.rb
require "write_xlsx"

class DemoEmailsController < ApplicationController
  def show
    latest_inspection_ids =
      Inspection.where("number > 0")
                .select(:id, :item_id, :number)
                .order(:item_id, number: :desc)
                .group_by(&:item_id)
                .values
                .map { |inspections| inspections.first.id }

    latest_inspections_scope = Inspection.where(id: latest_inspection_ids)

    today = Time.zone.today

    # Mes actual (para vencidos)
    current_month_start = today.beginning_of_month
    current_month_end   = today.end_of_month

    # Mes siguiente
    next_month_start = current_month_start.next_month
    next_month_end   = next_month_start.end_of_month

    # Dos meses después
    two_months_start = current_month_start.next_month(2)
    two_months_end   = two_months_start.end_of_month

    # Nombres de los meses en español sin depender de I18n
    month_names_es = %w[
      enero febrero marzo abril mayo junio
      julio agosto septiembre octubre noviembre diciembre
    ]

    expired_month_name = month_names_es[current_month_start.month - 1]  # mes actual
    next_month_name    = month_names_es[next_month_start.month - 1]     # mes siguiente
    two_months_name    = month_names_es[two_months_start.month - 1]     # dos meses después

    base_scope =
      latest_inspections_scope
        .joins(:report, item: :principal)
        .includes(:report, item: :principal)
        .where(state: "Cerrado", ignorar: false)

    # ====== SCOPES PARA CORREO Y EXCEL ======

    vencido_results   = ["Vencido (Aprobado)", "Vencido (Rechazado)"]
    vigente_results   = ["Aprobado", "Rechazado"]

    # 1) Vencidos en el mes actual:
    #    - Ya marcados como "Vencido (...)" y con ending dentro del mes
    #    - O bien "Aprobado"/"Rechazado" cuyo ending es el último día del mes
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
      expired_by_status_scope.or(ending_last_day_scope)

    expired_this_month_scope = expired_this_month_scope.distinct

    # Separar vencidos en aprobados / rechazados
    expired_this_month_approved =
      expired_this_month_scope.where(result: ["Vencido (Aprobado)", "Aprobado"])

    expired_this_month_rejected =
      expired_this_month_scope.where(result: ["Vencido (Rechazado)", "Rechazado"])

    # 2) Vencen el próximo mes
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

    # 3) Vencen en dos meses
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

    # ====== GENERAR EXCEL TEMPORAL ======

    excel_path     = nil
    excel_filename = "resumen_inspecciones_#{today.strftime('%Y_%m_%d')}.xlsx"

    Tempfile.create(['resumen_inspecciones', '.xlsx']) do |tmp|
      excel_path = tmp.path
      tmp.close

      workbook = WriteXLSX.new(excel_path)
      bold     = workbook.add_format(bold: 1)

      # Aseguramos longitud <= 31 para los nombres de hoja
      sheet_expired = workbook.add_worksheet(expired_month_name.capitalize[0, 31])
      sheet_next    = workbook.add_worksheet(next_month_name.capitalize[0, 31])
      sheet_two     = workbook.add_worksheet(two_months_name.capitalize[0, 31])

      # Ajuste básico de ancho de columnas (opcional)
      [sheet_expired, sheet_next, sheet_two].each do |sh|
        sh.set_column(0, 0, 15) # N° Inspección
        sh.set_column(1, 1, 25) # Activo
        sh.set_column(2, 2, 30) # Empresa
        sh.set_column(3, 4, 16) # Fechas
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
        # mode: :expired o :future
        base_verb = mode == :expired ? "vencieron" : "vencen"

        row = 0

        # Aprobados
        title_approved = "Equipos que #{base_verb} en #{month_name.capitalize} (aprobados)"
        row = write_section.call(sheet, row, title_approved, approved_collection)

        # 6 filas en blanco
        row += 6

        # Rechazados
        title_rejected = "Equipos que #{base_verb} en #{month_name.capitalize} (rechazados)"
        row = write_section.call(sheet, row, title_rejected, rejected_collection)

        row
      end

      # Hoja 1: mes actual (vencidos)
      write_month_sheet.call(
        sheet_expired,
        expired_month_name,
        expired_this_month_approved,
        expired_this_month_rejected,
        mode: :expired
      )

      # Hoja 2: mes siguiente
      write_month_sheet.call(
        sheet_next,
        next_month_name,
        next_month_approved,
        next_month_rejected,
        mode: :future
      )

      # Hoja 3: dos meses después
      write_month_sheet.call(
        sheet_two,
        two_months_name,
        two_months_approved,
        two_months_rejected,
        mode: :future
      )

      workbook.close
    end

    # ====== ENVIAR CORREO CON ADJUNTO ======

    to      = "joigsabra@hotmail.com"  # ajusta
    subject = "[No responder] #{expired_month_name}: Alertas de certificaciones vencidas y por vencer"

    NotifierMailer.inspections_warnings(
      to:,
      subject:,
      expired_this_month_approved:,
      expired_this_month_rejected:,
      next_month_approved:,
      next_month_rejected:,
      two_months_approved:,
      two_months_rejected:,
      expired_month_name:,
      next_month_name:,
      two_months_name:,
      excel_path:,
      excel_filename:
    ).deliver_now

    # ====== BORRAR ARCHIVO TEMPORAL LUEGO ======

    if excel_path.present? && defined?(DeleteTempFileJob)
      DeleteTempFileJob.set(wait: 5.minutes).perform_later(excel_path.to_s)
    end

    render plain: "Correo enviado a #{to} con adjunto #{excel_filename}"
  end
end
