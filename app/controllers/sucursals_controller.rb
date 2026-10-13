class SucursalsController < ApplicationController
  before_action :set_principal
  before_action :set_sucursal, only: [:edit, :update, :destroy]

  def new
    authorize! @sucursal = @principal.sucursals.build(nombre: "Sucursal #{@principal.sucursals.count + 1}")
  end

  def create
    authorize! @sucursal = @principal.sucursals.build(sucursal_params)

    if @sucursal.save
      flash[:notice] = "Sucursal creada"
      redirect_to principal_path(@principal), status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize! @sucursal
  end

  def update
    authorize! @sucursal

    if @sucursal.update(sucursal_params)
      flash[:notice] = "Sucursal modificada"
      redirect_to principal_path(@principal), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @sucursal

    if @sucursal.destroy
      flash[:notice] = "Sucursal eliminada"
    else
      flash[:alert] = @sucursal.errors.full_messages.to_sentence
    end

    redirect_to principal_path(@principal), status: :see_other
  end

  private

  def set_principal
    @principal = Principal.find(params[:principal_id])
  end

  def set_sucursal
    @sucursal = @principal.sucursals.find(params[:id])
  end

  def sucursal_params
    params.require(:sucursal).permit(:nombre, :place, :contact_name, :contact_email, :cellphone)
  end
end