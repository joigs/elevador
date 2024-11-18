class RevisionPhotoPolicy < BasePolicy
  def method_missing(m, *args, &block)
    record.only_owner? || Current.user.admin
  end

  def destroy?
    record.only_owner? || Current.user.admin
  end

  def rotate
    record.only_owner? || Current.user.admin
  end
end
