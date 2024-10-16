class InspectionPolicy < BasePolicy

  def new
    Current.user.admin
  end

  def create
    Current.user.admin
  end

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


  def close_inspection
    record.users.exists?(id: Current.user&.id)
  end


  def download_images
    Current.user.admin
  end

  def download_document
    Current.user.admin
  end

  def force_close_inspection
    Current.user.admin
  end

  def method_missing(m, *args, &block)
    Current.user.admin
  end

end