class ObservacionsController < ApplicationController
  before_action :set_facturacion
  before_action :set_observacion, only: %i[update destroy]

  def create
    @observacion = @facturacion.observacions.build(observacion_params)
    @observacion.user = Current.user if Current.user
    @observacion.momento = calcular_momento(@facturacion)

    if @observacion.save
      render json: {
        success: true,
        observacion: @observacion,
        user_name: @observacion.user&.real_name || "Anónimo",
        momento: @observacion.momento,
        facturacion_id: @facturacion.id
      }
    else
      render json: { success: false, errors: @observacion.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @observacion.update(observacion_params)
      render json: { success: true, observacion: @observacion }
    else
      render json: { success: false, errors: @observacion.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @observacion.destroy
    render json: { success: true }
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
