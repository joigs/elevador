class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])

    inspections_scope = if @user.admin
                          Inspection.where(state: "Cerrado")
                        else
                          Inspection.joins(:users).where(users: { id: @user.id }).where("number > 0")
                        end

    @q = inspections_scope.ransack(params[:q])
    @inspections = @q.result(distinct: true).order(number: :desc)
    if Current.user.tabla
      @pagy, @inspections = pagy(@inspections, items: 10) # Paginación tradicional para la tabla
    else
      @pagy, @inspections = pagy_countless(@inspections, items: 10) # Paginación infinita para las tarjetas
    end
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end


  def toggle_tabla
    if Current.user.update(tabla: params[:user][:tabla] == 'true')
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(Current.user, partial: "users/user", locals: { user: Current.user }) }
        format.html { redirect_to perfil_path(Current.user.username) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(Current.user, partial: "users/user", locals: { user: Current.user }) }
        format.html { redirect_to perfil_path(Current.user.username), flash: { error: 'Hubo un error al actualizar el estado de tabla.' } }
      end
    end
  end
end
