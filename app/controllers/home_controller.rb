class HomeController < ApplicationController
  def index

    @user = Current.user

    if @user.admin
      inspections_scope = Inspection.where(inf_date: nil).where(state: "cerrado")
    else

      inspections_scope = Inspection.joins(:users).where(users: { id: @user.id }).where("number > 0").where(state: "abierto")

    end

    @q = inspections_scope.ransack(params[:q])
    @inspections = @q.result(distinct: true).order(ins_date: :asc)
    @pagy, @inspections = pagy_countless(@inspections, items: 10)


  end
end
