class HomeController < ApplicationController


  def index

    @user = Current.user

    if @user.empresa != nil
      redirect_to principal_path(@user.principal)
    end

    if @user.admin
      inspections_scope = Inspection.where("number > 0").where(state: "abierto")
    else

      inspections_scope = Inspection.joins(:users).where(users: { id: @user.id }).where("number > 0").where(state: "abierto")

    end

    @q = inspections_scope.ransack(params[:q])
    @inspections = @q.result(distinct: true).order(ins_date: :asc)
    @pagy, @inspections = pagy_countless(@inspections, items: 10)


  end
end
