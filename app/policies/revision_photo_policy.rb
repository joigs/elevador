class RevisionPhotoPolicy < BasePolicy
  def method_missing(m, *args, &block)
    record.only_owner?
  end

  def destroy?
    record.only_owner?
  end
end
