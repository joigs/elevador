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

end