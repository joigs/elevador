class SucursalPolicy < BasePolicy
  def method_missing(m, *args, &block)
    Current.user.admin || Current.user.crear
  end
end