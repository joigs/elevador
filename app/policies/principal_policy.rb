class PrincipalPolicy < BasePolicy
  def method_missing(m, *args, &block)
    Current.user.admin
  end

  def no_conformidad
    Current.user.admin
  end
end
