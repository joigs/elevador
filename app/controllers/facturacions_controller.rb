class FacturacionsController < ApplicationController
  before_action :set_facturacion, only: [:show, :edit, :update, :destroy]

  def index
    @facturacions = Facturacion.all
  end

  def show
    # @facturacion ya está definido en set_facturacion
  end

  def new
    @facturacion = Facturacion.new
  end

  def create
    @facturacion = Facturacion.new(facturacion_params)
    if @facturacion.save
      redirect_to @facturacion, notice: "Facturación creada con éxito."
    else
      render :new
    end
  end

  def edit
    # @facturacion ya está definido en set_facturacion
  end

  def update
    if @facturacion.update(facturacion_params)
      redirect_to @facturacion, notice: "Facturación actualizada con éxito."
    else
      render :edit
    end
  end

  def destroy
    @facturacion.destroy
    redirect_to facturacions_path, notice: "Facturación eliminada con éxito."
  end

  private

  # Encuentra la facturación según el :id
  def set_facturacion
    @facturacion = Facturacion.find(params[:id])
  end

  # Filtros fuertes (Strong Parameters)
  def facturacion_params
    params.require(:facturacion).permit(
      :number,
      :name,
      :solicitud,
      :emicion,
      :entregado,
      :resultado,
      :oc,
      :factura
    )
  end
end
