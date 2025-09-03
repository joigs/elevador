class HomeController < ApplicationController

  def index
    @user = Current.user

    if @user.empresa != nil
      redirect_to principal_path(@user.principal)
    end

    if @user.admin
      inspections_scope = Inspection.where("number > 0").where(state: "abierto")
    else
      inspections_scope = Inspection.joins(:users).where(users: { id: @user.id }).where("number > 0").where(state: "abierto")
    end

    @q = inspections_scope.ransack(params[:q])
    @inspections = @q.result(distinct: true).order(ins_date: :asc)
    unless Current.user.tabla
      @pagy, @inspections = pagy_countless(@inspections, items: 10)
    end
    @facturacions = Facturacion.order(number: :desc)
    @facturacions = @facturacions.where.not(number: 0)

    @notifications, @notif_counts = current_notifications



    #parte de convenios

    @months = %w[Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre]
    @years  = (2025..Date.current.year).to_a.reverse

    sel_month = (params[:month] || Date.current.month).to_i
    sel_year  = (params[:year]  || Date.current.year).to_i

    sel_month = 1  unless (1..12).cover?(sel_month)
    sel_year  = 2025 if sel_year < 2025
    @selected_month = sel_month
    @selected_year  = sel_year

    @convenios = Convenio
                   .includes(:empresa)
                   .where(month: sel_month, year: sel_year)
                   .order("empresas.nombre")

  end

  def check_all_expirations
    Inspection.check_all_expirations
    redirect_to home_path, notice: 'Se han revisado los vencimientos.'
  end

  private

  def current_notifications
    notifications = []

    if Current.user.cotizar
      notifications += Notification.joins(:facturacions)
                                   .where(notification_type: [:solicitud_pendiente, :factura_pendiente])
                                   .distinct
    end
    if Current.user.solicitar
      notifications += Notification.joins(:facturacions)
                                   .where(notification_type: :entrega_pendiente)
                                   .distinct
    end

    counts = { inspeccion_proxima: 0, inspeccion_vencida: 0, inspeccion_rechazada: 0 }

    if Current.user.admin
      window_from = Date.current
      window_to   = 2.months.from_now.to_date

      proximas_scope = Inspection.joins(:report)
                                 .where(state: "Cerrado", result: "Aprobado")
                                 .where("reports.ending > ? AND reports.ending <= ?", window_from, window_to)

      rechazadas_scope = Inspection.joins(:report)
                                   .where(state: "Cerrado", result: "Rechazado")
                                   .where("reports.ending > ? AND reports.ending <= ?", window_from, window_to)

      vencidas_scope = Inspection.vencidos

      counts[:inspeccion_proxima]   = proximas_scope.count
      counts[:inspeccion_rechazada] = rechazadas_scope.count
      counts[:inspeccion_vencida]   = vencidas_scope.count

      notifications += Notification.where(notification_type: :inspeccion_proxima)   if counts[:inspeccion_proxima]   > 0
      notifications += Notification.where(notification_type: :inspeccion_rechazada) if counts[:inspeccion_rechazada] > 0
      notifications += Notification.where(notification_type: :inspeccion_vencida)   if counts[:inspeccion_vencida]   > 0
    end

    [notifications.uniq, counts]
  end
end
