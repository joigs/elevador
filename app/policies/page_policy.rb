
class PagePolicy < BasePolicy

  def bash_fill
    Current.user.admin? || record.users.exists?(id: Current.user&.id)
  end

  def bash_fill_detail
    Current.user.admin? || record.users.exists?(id: Current.user&.id)
  end

  def bash_fill_report
    Current.user.admin? || record.users.exists?(id: Current.user&.id)
  end
end