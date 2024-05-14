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

  def update_ending
    Current.user.admin || record.user == Current.user
  end

end