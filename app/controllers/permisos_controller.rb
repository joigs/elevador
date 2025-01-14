class PermisosController < ApplicationController
  before_action :set_permiso, only: [:show, :edit, :update, :destroy]

  # GET /permisos
  def index
    authorize!
    @permisos = Permiso.all
  end

  # GET /permisos/:id
  def show
    authorize!
  end

  # GET /permisos/new
  def new
    authorize!
    @permiso = Permiso.new
  end

  # GET /permisos/:id/edit
  def edit
    authorize!
  end

  # POST /permisos
  def create
    authorize!
    @permiso = Permiso.new(permiso_params)

    if @permiso.save
      authorize!
      redirect_to @permiso, notice: 'El permiso fue creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /permisos/:id
  def update
    authorize!
    if @permiso.update(permiso_params)
      redirect_to @permiso, notice: 'El permiso fue actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /permisos/:id
  def destroy
    authorize!
    @permiso.destroy
    redirect_to permisos_url, notice: 'El permiso fue eliminado exitosamente.'
  end

  private

  # Encuentra el permiso según el ID proporcionado
  def set_permiso
    @permiso = Permiso.find(params[:id])
  end

  # Solo permite parámetros seguros
  def permiso_params
    params.require(:permiso).permit(:nombre, :descripcion)
  end
end


