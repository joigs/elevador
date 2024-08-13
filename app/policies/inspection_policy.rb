class InspectionPolicy < BasePolicy
  def edit
    Current.user.admin || record.users.exists?(id: Current.user&.id)
  end

  def update
    Current.user.admin || record.users.exists?(id: Current.user&.id)
  end

  def destroy
    Current.user.admin
  end


  def download_json
      Current.user.admin || record.users.exists?(id: Current.user&.id)
  end

  def update_ending
    Current.user.admin || record.users.exists?(id: Current.user&.id)
  end

  def update_inf_date
    Current.user.admin
  end

end