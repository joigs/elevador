class RevisionPolicy < BasePolicy
  def method_missing(m, *args, &block)
    record.owner?
  end
end