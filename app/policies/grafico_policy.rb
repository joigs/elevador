class GraficoPolicy < BasePolicy

  def index
    Current.user
  end

  def method_missing(m, *args, &block)
    Current.user
  end
end