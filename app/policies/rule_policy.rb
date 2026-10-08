class RulePolicy < BasePolicy
  def method_missing(m, *args, &block)
    Current.user.admin?
  end
end