class PermisoPolicy < BasePolicy


  def method_missing(m, *args, &block)
    Current.user.super
  end
end