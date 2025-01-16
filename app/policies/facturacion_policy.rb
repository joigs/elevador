class FacturacionPolicy < BasePolicy


  def new
    Current.user.solicitar
  end

  def create
    Current.user.solicitar
  end

  def edit
    Current.user.solicitar
  end

  def update
    Current.user.solicitar
  end

  def method_missing(m, *args, &block)
    Current.user.gestion
  end
end
