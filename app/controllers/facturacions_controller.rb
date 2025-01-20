class FacturacionsController < ApplicationController
  before_action :set_facturacion, only: [
    :show, :edit, :update, :destroy,
    :download_solicitud_file, :download_cotizacion_doc_file,
    :download_cotizacion_pdf_file, :download_orden_compra_file,
    :download_facturacion_file, :download_all_files
  ]

  before_action :authorize_user

  def index
    @facturacions_origin = Facturacion.all
    @facturacions = @facturacions_origin
  end

  def show
    # @facturacion ya está definido en set_facturacion
  end

  def new
    @facturacion = Facturacion.new
  end

  def create
    @facturacion = Facturacion.new(facturacion_params)

    if @facturacion.save
      redirect_to @facturacion, notice: "Facturación creada con éxito."
    else
      render :new, status: :unprocessable_entity
    end
  end


  def edit
    # @facturacion ya está definido en set_facturacion
  end

  def update
    if @facturacion.update(facturacion_params)
      redirect_to @facturacion, notice: "Facturación actualizada con éxito."
    else
      render :edit
    end
  end

  def destroy
    authorize!
      @facturacion.destroy
      flash[:notice] = "facturación eliminado exitosamente"
      respond_to do |format|
        format.html { redirect_to home_path(tab: 'cotizaciones') }
        format.turbo_stream { head :no_content }
      end

  end



  # Archivos individuales
  def download_solicitud_file
    download_file(@facturacion.solicitud_file)
  end

  def download_cotizacion_doc_file
    download_file(@facturacion.cotizacion_doc_file)
  end

  def download_cotizacion_pdf_file
    download_file(@facturacion.cotizacion_pdf_file)
  end

  def download_orden_compra_file
    download_file(@facturacion.orden_compra_file)
  end

  def download_facturacion_file
    download_file(@facturacion.facturacion_file)
  end
  # Etc. Mismo patrón para los otros 3

  def download_all_files
    files = [
      @facturacion.solicitud_file,
      @facturacion.cotizacion_doc_file,
      @facturacion.cotizacion_pdf_file,
      @facturacion.orden_compra_file,
      @facturacion.facturacion_file
    ].compact # Elimina los que no están adjuntos

    if files.empty?
      redirect_to @facturacion, alert: "No hay archivos disponibles para descargar."
      return
    end

    zip_data = create_zip(files)
    send_data zip_data, filename: "facturacion_#{@facturacion.id}_archivos.zip"
  end

  def upload_cotizacion
    @facturacion = Facturacion.find(params[:id])

    if params[:facturacion][:cotizacion_doc_file].present? && params[:facturacion][:cotizacion_pdf_file].present?
      @facturacion.cotizacion_doc_file.attach(params[:facturacion][:cotizacion_doc_file])
      @facturacion.cotizacion_pdf_file.attach(params[:facturacion][:cotizacion_pdf_file])
      @facturacion.update(emicion: Date.current)

      redirect_to @facturacion, notice: "Documentos subidos correctamente y fecha de emisión actualizada."
    else
      flash.now[:alert] = "Ambos archivos (DOCX y PDF) son obligatorios."
      render :show, status: :unprocessable_entity
    end
  end

  def marcar_entregado
    @facturacion = Facturacion.find(params[:id])

    if @facturacion.update(entregado: Date.current, resultado: 1)
      render json: { success: true, message: "Fecha de entrega actualizada correctamente." }, status: :ok
    else
      render json: { success: false, message: "No se pudo actualizar la fecha de entrega." }, status: :unprocessable_entity
    end
  end

  def upload_orden_compra
    @facturacion = Facturacion.find(params[:id])

    # Verifica si el archivo fue subido
    if params[:facturacion][:orden_compra_file].present? && params[:facturacion][:resultado].present?
      @facturacion.orden_compra_file.attach(params[:facturacion][:orden_compra_file])
      @facturacion.oc = Date.current
      @facturacion.resultado = params[:facturacion][:resultado].to_i # Conversión explícita a entero

      if @facturacion.save
        redirect_to @facturacion, notice: "Orden de Compra subida correctamente y estado actualizado."
      else
        flash.now[:alert] = "No se pudo procesar la solicitud."
        render :show, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "El archivo PDF y el resultado son obligatorios."
      render :show, status: :unprocessable_entity
    end
  end

  def upload_factura
    @facturacion = Facturacion.find(params[:id])

    # Verifica si el archivo fue subido
    if params[:facturacion][:facturacion_file].present?
      @facturacion.facturacion_file.attach(params[:facturacion][:facturacion_file])
      @facturacion.factura = Date.current

      if @facturacion.save
        redirect_to @facturacion, notice: "Factura subida correctamente y fecha de factura actualizada."
      else
        flash.now[:alert] = "No se pudo procesar la solicitud."
        render :show, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "El archivo PDF es obligatorio."
      render :show, status: :unprocessable_entity
    end
  end



  private

  # Encuentra la facturación según el :id
  def set_facturacion
    @facturacion = Facturacion.find(params[:id])
  end

  # Filtros fuertes (Strong Parameters)
  def facturacion_params
    params.require(:facturacion).permit(
      :number,
      :name,
      :solicitud,
      :emicion,
      :entregado,
      :resultado,
      :oc,
      :factura,
      :solicitud_file,
      :cotizacion_doc_file,
      :cotizacion_pdf_file,
      :orden_compra_file,
      :facturacion_file
    )
  end


  def download_file(file)
    if file.attached?
      redirect_to rails_blob_path(file, disposition: "attachment")
    else
      redirect_to @facturacion, alert: "No hay archivo disponible para descargar."
    end
  end

  def create_zip(files)
    buffer = Zip::OutputStream.write_buffer do |zip|
      files.each do |file|
        zip.put_next_entry(file.filename.to_s)
        zip.write(file.download)
      end
    end
    buffer.string
  end

  def authorize_user
    authorize!
  end
end
