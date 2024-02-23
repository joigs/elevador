class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])
    if @user.admin
      @inspections = Inspection.where(state: "Cerrado")
      @pagy, @inspections = pagy_countless(@inspections, items: 10  )
    else
      @inspections = Inspection.order(number: :desc).where(user_id: @user.id)

      @pagy, @inspections = pagy_countless(@inspections, items: 10  )
    end


  end
end