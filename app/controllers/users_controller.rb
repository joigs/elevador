class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])
    @pagy, @inspections = pagy_countless(FindInspections.new.call({ user_id: @user.id}), items: 10)
  end
end