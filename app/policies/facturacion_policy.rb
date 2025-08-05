class FacturacionPolicy < BasePolicy


  def new
    Current.user.solicitar || Current.user.mini_solicitar
  end

  def create
    Current.user.solicitar || Current.user.mini_solicitar
  end

  def edit
    Current.user.solicitar || Current.user.mini_solicitar
  end

  def update
    Current.user.solicitar || Current.user.mini_solicitar
  end

  def destroy
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



  def update_fecha_entrega
    Current.user.cotizar || Current.user.solicitar
  end

  def update_price
    Current.user.gestion
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

  def download_all_excel
    Current.user.solicitar
  end

  def set_fecha_venta
    Current.user.cotizar
  end

  def method_missing(m, *args, &block)
    Current.user.gestion
  end
end
