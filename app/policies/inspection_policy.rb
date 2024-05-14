class InspectionPolicy < BasePolicy
  def edit
    Current.user.admin
  end

  def update
    Current.user.admin
  end

  def destroy
    Current.user.admin
  end

  def edit_identificador
    Current.user.admin
  end

  def update_identificador
    Current.user.admin
  end

end