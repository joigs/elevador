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

  def new_bulk_upload
    Current.user.super
  end

  def bulk_upload
    Current.user.super
  end

  def new_bulk_upload_pdf
    Current.user.super
  end

  def bulk_upload_pdf
    Current.user.super
  end

  def download_solicitud_template
    Current.user.solicitar
  end

  def download_cotizacion_template
    Current.user.cotizar
  end

  def method_missing(m, *args, &block)
    Current.user.gestion
  end
end
