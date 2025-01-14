class ObservacionsController < ApplicationController
  before_action :set_facturacion

  def index
    @observacions = @facturacion.observacions
  end

  def show
    @observacion = @facturacion.observacions.find(params[:id])
  end

  def new
    @observacion = @facturacion.observacions.build
  end

  def create
    @observacion = @facturacion.observacions.build(observacion_params)
    if @observacion.save
      redirect_to facturacion_observacions_path(@facturacion), notice: "Observación creada correctamente."
    else
      render :new
    end
  end

  def edit
    @observacion = @facturacion.observacions.find(params[:id])
  end

  def update
    @observacion = @facturacion.observacions.find(params[:id])
    if @observacion.update(observacion_params)
      redirect_to facturacion_observacions_path(@facturacion), notice: "Observación actualizada correctamente."
    else
      render :edit
    end
  end

  def destroy
    @observacion = @facturacion.observacions.find(params[:id])
    @observacion.destroy
    redirect_to facturacion_observacions_path(@facturacion), notice: "Observación eliminada correctamente."
  end

  private

  def set_facturacion
    @facturacion = Facturacion.find(params[:facturacion_id])
  end

  def observacion_params
    params.require(:observacion).permit(:texto)
  end
end
