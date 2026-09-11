class EmpresaUsersController < ApplicationController
  PERMISOS_GESTIONABLES = [Permiso::EMPRESA_ADMIN, Permiso::RECIBE_CORREO].freeze

  before_action :set_principal
  before_action :autorizar_gestion!
  before_action :set_user

  def destroy
    if @user == Current.user
      return redirigir(alert: "No puedes eliminar tu propia cuenta")
    end

    @user.destroy
    redirigir(notice: "Usuario eliminado")
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
                (Current.user.empresa_admin? && Current.user.principal_id == @principal.id)

    unless permitido
      flash[:alert] = "No tienes permiso"
      redirect_to home_path
    end
  end

  def set_user
    @user = @principal.users.find(params[:id])
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
end