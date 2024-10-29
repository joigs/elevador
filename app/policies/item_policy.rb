class ItemPolicy < BasePolicy
  def method_missing(m, *args, &block)
    Current.user.admin
  end

  def edit_identificador
    Current.user.admin || record.inspections.where("number > 0").last.users.exists?(id: Current.user&.id)
  end
  def update_identificador
    Current.user.admin || record.inspections.where("number > 0").last.users.exists?(id: Current.user&.id)
  end

  def edit_empresa
    Current.user.admin
  end
  def update_empresa
    Current.user.admin
  end

  def edit_group
    Current.user.admin || record.inspections.where("number > 0").last.users.exists?(id: Current.user&.id)
  end

  def update_group
    Current.user.admin || record.inspections.where("number > 0").last.users.exists?(id: Current.user&.id)
  end

end