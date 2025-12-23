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


    vencido_results   = ["Vencido (Aprobado)", "Vencido (Rechazado)"]
    vigente_results   = ["Aprobado", "Rechazado"]

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



    to      = "joigsabra@hotmail.com"
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
      two_months_name:
    ).deliver_now



    render plain: "Correo enviado a #{to}"
  end
end
