class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])
    #@pagy, @products = pagy_countless(FindInspections.new.call({ user_id: @user.id}), items: 4)
  end
end