class ReportPolicy < BasePolicy

  def edit
    record.inspection.owner? || Current.user.admin
  end
  def update
    record.inspection.owner? || Current.user.admin

  end

  def method_missing(m, *args, &block)
    record.inspection.owner?
  end
end