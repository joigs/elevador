class EmpresaUsersController < ApplicationController
  PERMISOS_GESTIONABLES = [Permiso::EMPRESA_ADMIN, Permiso::RECIBE_CORREO].freeze

  before_action :set_principal
  before_action :autorizar_gestion!
  before_action :set_user

  def destroy
    if @user == Current.user
      return redirigir(alert: "No puedes eliminar tu propia cuenta")
    end

    ajenas = @user.sucursal_ids - Current.user.sucursales_asignables_para(@user).pluck(:id)
    unless ajenas.empty?
      return redirigir(alert: "El usuario tiene acceso a sucursales que no administras. Quítalo de tus empresas en lugar de eliminarlo.")
    end

    @user.destroy
    redirigir(notice: "Usuario eliminado")
  end

  def agregar_empresa
    empresa = Current.user.empresas_gestionables.find_by(id: params[:empresa_id])
    return responder(alert: "Empresa no válida") unless empresa

    sucursal_ids = Current.user.sucursales_gestionables_en(empresa).pluck(:id)
    return responder(alert: "No tienes sucursales que asignar en #{empresa.name}") if sucursal_ids.empty?

    ActiveRecord::Base.transaction do
      sucursal_ids.each { |sucursal_id| SucursalUser.find_or_create_by!(user_id: @user.id, sucursal_id: sucursal_id) }
      @user.sincronizar_empresas_desde_sucursales!
    end

    responder(notice: "Usuario agregado a #{empresa.name}")
  end

  def quitar_empresa
    empresa = Current.user.empresas_gestionables.find_by(id: params[:empresa_id])
    return responder(alert: "Empresa no válida") unless empresa

    if @user == Current.user
      return responder(alert: "No puedes quitarte a ti mismo de una empresa")
    end

    sucursal_ids = Current.user.sucursales_gestionables_en(empresa).pluck(:id)

    if (@user.sucursal_ids - sucursal_ids).empty?
      return responder(alert: "El usuario debe pertenecer al menos a una empresa")
    end

    ActiveRecord::Base.transaction do
      SucursalUser.where(user_id: @user.id, sucursal_id: sucursal_ids).destroy_all
      @user.sincronizar_empresas_desde_sucursales!
    end

    if empresa == @principal && !Current.user.usuarios_gestionables_en(@principal).exists?(id: @user.id)
      quitar_fila
    else
      responder(notice: "Usuario quitado de #{empresa.name}")
    end
  end

  def toggle_activo
    if @user == Current.user
      return responder(alert: "No puedes cambiar el estado de tu propia cuenta")
    end

    @user.update(activo: params[:valor] == "1")
    responder(notice: @user.activo? ? "Usuario activado" : "Usuario desactivado")
  end

  def toggle_permiso
    nombre = params[:permiso].to_s

    unless PERMISOS_GESTIONABLES.include?(nombre)
      return responder(alert: "Permiso no válido")
    end

    if @user == Current.user && nombre == "empresa_admin"
      return responder(alert: "No puedes quitarte a ti mismo la administración de la empresa")
    end

    permiso = Permiso.find_by(nombre: nombre)
    return responder(alert: "Permiso no encontrado") unless permiso

    if params[:valor] == "1"
      @user.permisos << permiso unless @user.permisos.include?(permiso)
    else
      @user.permisos.destroy(permiso)
    end

    responder(notice: "Permisos actualizados")
  end

  private

  def set_principal
    @principal = Principal.find(params[:principal_id])
  end

  def autorizar_gestion!
    permitido = Current.user.admin? ||
                (Current.user.empresa_admin? && Current.user.empresa_de?(@principal))

    unless permitido
      flash[:alert] = "No tienes permiso"
      redirect_to home_path
    end
  end

  def set_user
    @user = Current.user.usuarios_gestionables_en(@principal).find(params[:id])
  end

  def redirigir(flash_opts)
    redirect_to principal_path(@principal, tab: "usuarios"),
                flash_opts.merge(status: :see_other)
  end

  def responder(flash_opts)
    @user.reload

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = flash_opts[:notice] if flash_opts[:notice]
        flash.now[:alert]  = flash_opts[:alert]  if flash_opts[:alert]

        render turbo_stream: turbo_stream.replace(
          helpers.dom_id(@user, :empresa_row),
          partial: "principals/empresa_user_row",
          locals: { user: @user, principal: @principal }
        )
      end
      format.html { redirigir(flash_opts) }
    end
  end

  def quitar_fila
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(helpers.dom_id(@user, :empresa_row))
      end
      format.html { redirigir(notice: "Usuario quitado de la empresa") }
    end
  end
end
