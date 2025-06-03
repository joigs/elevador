class InspectionPolicy < BasePolicy

  def new
    Current.user.admin || Current.user.crear
  end

  def new_with_last
    Current.user.admin || Current.user.crear
  end

  def create
    Current.user.admin || Current.user.crear
  end

  def edit
    Current.user.admin || record.users.exists?(id: Current.user&.id) || Current.user.crear
  end

  def update
    Current.user.admin || record.users.exists?(id: Current.user&.id) || Current.user.crear
  end

  def destroy
    Current.user.admin || Current.user.crear
  end


  def download_json
      Current.user.admin || record.users.exists?(id: Current.user&.id) || Current.user.crear
  end

  def update_ending
    Current.user.admin || record.users.exists?(id: Current.user&.id) || Current.user.certificar
  end

  def update_inf_date
    Current.user.admin || Current.user.certificar
  end


  def close_inspection
    record.users.exists?(id: Current.user&.id)
  end


  def download_images
    Current.user.admin || Current.user.certificar
  end

  def download_document
    Current.user.admin || Current.user.certificar || Current.user.only_see
  end

  def force_close_inspection
    Current.user.admin || Current.user.crear || Current.user.certificar
  end

  def edit_informe
    Current.user.admin || Current.user.certificar
  end

  def update_informe
    Current.user.admin || Current.user.certificar
  end

  def download_informe
    Current.user.admin || Current.user.certificar || Current.user.only_see
  end


  def method_missing(m, *args, &block)
    Current.user.admin
  end

end