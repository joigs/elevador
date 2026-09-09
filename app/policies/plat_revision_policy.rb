class PlatRevisionPolicy < BasePolicy
  def method_missing(m, *args, &block)
    record.only_owner?
  end

  def show?
    Current.user.empresa_de?(record.inspection) || Current.user.empresa == nil
  end

  def update?
    record.only_owner?
  end
end