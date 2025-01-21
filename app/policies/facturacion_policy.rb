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



  def upload_cotizacion
    Current.user.cotizar
  end


  def marcar_entregado
    Current.user.solicitar
  end

  def upload_orden_compra
    Current.user.solicitar
  end

  def upload_factura
    Current.user.cotizar
  end

  def method_missing(m, *args, &block)
    Current.user.gestion
  end
end
