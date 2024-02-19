class ReportPolicy < BasePolicy
  def method_missing(m, *args, &block)
    record.inspection.owner?
  end
end