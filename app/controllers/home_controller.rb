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

    @notifications = current_notifications



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

    notifications.uniq
  end
end
