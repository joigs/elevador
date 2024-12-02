class LadderPolicy < BasePolicy

  def new
    false
  end

  def method_missing(m, *args, &block)
    Current.user.admin?
  end
end