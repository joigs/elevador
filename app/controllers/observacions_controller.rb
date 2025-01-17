class ObservacionsController < ApplicationController
  before_action :set_facturacion
  before_action :set_observacion, only: %i[edit update destroy]

  def index
    @observacions = @facturacion.observacions.includes(:user).order(created_at: :desc)
  end

  def new
    @observacion = @facturacion.observacions.build
  end

  def create
    @observacion = @facturacion.observacions.build(observacion_params)
    @observacion.user = Current.user if Current.user
    @observacion.momento = calcular_momento(@facturacion)

    if @observacion.save
      redirect_to facturacion_path(@facturacion), notice: "Observación creada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @observacion.update(observacion_params)
      redirect_to facturacion_path(@facturacion), notice: "Observación actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @observacion.destroy
    redirect_to facturacion_path(@facturacion), notice: "Observación eliminada correctamente."
  end

  private

  def set_facturacion
    @facturacion = Facturacion.find(params[:facturacion_id])
  end

  def set_observacion
    @observacion = @facturacion.observacions.find(params[:id])
  end

  def observacion_params
    params.require(:observacion).permit(:texto)
  end

  def calcular_momento(facturacion)
    if facturacion.factura.present?
      "Emisión de factura"
    elsif facturacion.oc.present?
      "Orden de compra"
    elsif facturacion.entregado.present?
      "Entregado a cliente"
    elsif facturacion.emicion.present?
      "Emisión de cotización"
    else
      "Solicitud de cotización"
    end
  end
end
