class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])

    inspections_scope = if @user.admin
                          Inspection.where(state: "Cerrado")
                        else
                          Inspection.where(user_id: @user.id).where("number > 0")
                        end

    @q = inspections_scope.ransack(params[:q])
    @inspections = @q.result(distinct: true).order(number: :desc)
    @pagy, @inspections = pagy_countless(@inspections, items: 10)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
