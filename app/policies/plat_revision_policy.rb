class PlatRevisionPolicy < BasePolicy
  def method_missing(m, *args, &block)
    record.only_owner?
  end

  def update?
    record.only_owner?
  end
end