class ItemPolicy < BasePolicy


  def edit_identificador
    Current.user.admin || record.inspections.where("number > 0").last&.users&.exists?(id: Current.user&.id) || Current.user.crear
  end
  def update_identificador
    Current.user.admin || record.inspections.where("number > 0").last&.users&.exists?(id: Current.user&.id) || Current.user.crear
  end

  def edit_empresa
    Current.user.admin || Current.user.crear
  end
  def update_empresa
    Current.user.admin || Current.user.crear
  end

  def edit_group
    Current.user.admin || record.inspections.where("number > 0").last&.users&.exists?(id: Current.user&.id) || Current.user.crear
  end

  def update_group
    Current.user.admin || record.inspections.where("number > 0").last&.users&.exists?(id: Current.user&.id) || Current.user.crear
  end
  def method_missing(m, *args, &block)
    Current.user.admin || Current.user.crear
  end
end