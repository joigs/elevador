class FacturacionsController < ApplicationController
  before_action :set_facturacion, only: [
    :show, :edit, :update,
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
  end

  def new
    @facturacion = Facturacion.new
    @facturacion.number = (Facturacion.maximum(:number) || 0) + 1

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
  end

  def update
    if @facturacion.update(facturacion_params)
      redirect_to @facturacion, notice: "Facturación actualizada con éxito."
    else
      render :edit
    end
  end





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

  def download_all_files
    files = [
      @facturacion.solicitud_file,
      @facturacion.cotizacion_doc_file,
      @facturacion.cotizacion_pdf_file,
      @facturacion.orden_compra_file,
      @facturacion.facturacion_file
    ].compact

    if files.empty?
      redirect_to @facturacion, alert: "No hay archivos disponibles para descargar."
      return
    end

    zip_data = create_zip(files)
    send_data zip_data, filename: "facturacion_#{@facturacion.number}_archivos.zip"
  end


  def marcar_entregado
    @facturacion = Facturacion.find(params[:id])

    if @facturacion.update(entregado: Date.current, resultado: 1)
      render json: { success: true, message: "Fecha de entrega actualizada correctamente." }, status: :ok
    else
      render json: { success: false, message: "No se pudo actualizar la fecha de entrega." }, status: :unprocessable_entity
    end
  end

  def upload_cotizacion
    @facturacion = Facturacion.find(params[:id])

    unless params[:facturacion]
      flash.now[:alert] = "Ambos archivos (DOCX y PDF) son obligatorios."
      render :show, status: :unprocessable_entity
      return
    end

    if params[:facturacion][:cotizacion_doc_file].present? && params[:facturacion][:cotizacion_pdf_file].present?
      @facturacion.cotizacion_doc_file.attach(params[:facturacion][:cotizacion_doc_file])
      @facturacion.cotizacion_pdf_file.attach(params[:facturacion][:cotizacion_pdf_file])

      if valid_file_type?(@facturacion.cotizacion_doc_file, %w[application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document]) &&
        valid_file_type?(@facturacion.cotizacion_pdf_file, %w[application/pdf])
        @facturacion.update(emicion: Date.current)
        redirect_to @facturacion, notice: "Documentos subidos correctamente y fecha de emisión actualizada."
      else
        flash.now[:alert] = "Ambos archivos deben ser del tipo correcto (DOCX y PDF)."
        @facturacion.cotizacion_doc_file.purge
        @facturacion.cotizacion_pdf_file.purge
        render :show, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Ambos archivos (DOCX y PDF) son obligatorios."
      render :show, status: :unprocessable_entity
    end
  end


  def upload_orden_compra
    @facturacion = Facturacion.find(params[:id])

    unless params[:facturacion].present?
      flash.now[:alert] = "No se proporcionaron datos para procesar la Orden de Compra."
      render :show, status: :unprocessable_entity
      return
    end

    resultado = params[:facturacion][:resultado]&.to_i
    orden_compra_file = params[:facturacion][:orden_compra_file]

    unless resultado.present? && Facturacion.resultados.values.include?(resultado)
      flash.now[:alert] = "Debes seleccionar un resultado válido (Aceptado o Rechazado)."
      render :show, status: :unprocessable_entity
      return
    end

    allowed_types = ["application/pdf", "image/png", "image/jpeg", "image/jpg"]
    if resultado == 2 && (!orden_compra_file || !valid_uploaded_file?(orden_compra_file, allowed_types))
      flash.now[:alert] = "Debes subir un archivo válido (PDF, PNG, JPG, o JPEG) para la orden de compra cuando el resultado es Aceptado."
      render :show, status: :unprocessable_entity
      return
    end

    @facturacion.resultado = resultado
    @facturacion.oc = Date.current if resultado == 2
    @facturacion.orden_compra_file.attach(orden_compra_file) if orden_compra_file.present? && resultado == 2

    if @facturacion.save
      redirect_to @facturacion, notice: "Orden de Compra procesada correctamente."
    else
      flash.now[:alert] = "No se pudo procesar la Orden de Compra."
      render :show, status: :unprocessable_entity
    end
  end




  def upload_factura
    @facturacion = Facturacion.find(params[:id])

    unless params[:facturacion]
      flash.now[:alert] = "El archivo PDF y la fecha de inspección son obligatorios."
      render :show, status: :unprocessable_entity
      return
    end

    facturacion_file = params[:facturacion][:facturacion_file]
    fecha_inspeccion = params[:facturacion][:fecha_inspeccion]

    if facturacion_file.blank?
      flash.now[:alert] = "El archivo PDF es obligatorio."
      render :show, status: :unprocessable_entity
      return
    end

    if fecha_inspeccion.blank?
      flash.now[:alert] = "La fecha de inspección es obligatoria."
      render :show, status: :unprocessable_entity
      return
    end

    @facturacion.facturacion_file.attach(facturacion_file)
    unless valid_file_type?(@facturacion.facturacion_file, %w[application/pdf])
      flash.now[:alert] = "El archivo debe ser un PDF."
      @facturacion.facturacion_file.purge
      render :show, status: :unprocessable_entity
      return
    end

    @facturacion.factura = Date.current
    @facturacion.fecha_inspeccion = fecha_inspeccion

    if @facturacion.save
      redirect_to @facturacion, notice: "Factura subida correctamente y fecha de inspección actualizada."
    else
      flash.now[:alert] = "No se pudo procesar la solicitud."
      render :show, status: :unprocessable_entity
    end
  end

  def manage_files
    @facturacion = Facturacion.find(params[:id])
  end

  def replace_file
    @facturacion = Facturacion.find(params[:id])

    unless params[:file].present? && params[:file_field].present?
      flash[:alert] = "Debes seleccionar un archivo válido y un campo para reemplazar."
      redirect_to manage_files_facturacion_path(@facturacion)
      return
    end

    allowed_types = {
      "solicitud_file" => ["application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"],
      "cotizacion_doc_file" => ["application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"],
      "cotizacion_pdf_file" => ["application/pdf"],
      "orden_compra_file" => ["application/pdf", "image/png", "image/jpeg", "image/jpg"],
      "facturacion_file" => ["application/pdf"]
    }

    file_field = params[:file_field]
    file = params[:file]

    if allowed_types[file_field].nil? || !allowed_types[file_field].include?(file.content_type)
      flash[:alert] = "El archivo seleccionado no es válido para el campo #{file_field.humanize}."
      redirect_to manage_files_facturacion_path(@facturacion)
      return
    end

    @facturacion.public_send(file_field).attach(file)

    if @facturacion.save
      flash[:notice] = "Archivo reemplazado correctamente en el campo #{file_field.humanize}."
    else
      flash[:alert] = "No se pudo reemplazar el archivo. Inténtalo de nuevo."
    end

    redirect_to manage_files_facturacion_path(@facturacion)
  end



  def new_bulk_upload
  end

  # Acción para procesar los archivos subidos
  def bulk_upload
    files = params[:files] # Archivos subidos

    if files.blank?
      redirect_to new_bulk_upload_facturacions_path, alert: "No se seleccionaron archivos para subir."
      return
    end

    errores = [] # Para registrar errores
    archivos_procesados = 0

    files.each do |file|
      # Asegúrate de que `file` es un objeto válido
      next unless file.is_a?(ActionDispatch::Http::UploadedFile)

      # Extraer el número y el nombre del archivo
      begin
        nombre_archivo = file.original_filename
        number, name = parse_filename(nombre_archivo)

        # Crear la facturación
        facturacion = Facturacion.new(number: number, name: name)
        facturacion.solicitud_file.attach(file)

        if facturacion.save
          archivos_procesados += 1
        else
          errores << "#{nombre_archivo}: #{facturacion.errors.full_messages.join(', ')}"
        end
      rescue StandardError => e
        errores << "#{file.original_filename}: Error procesando el archivo - #{e.message}"
      end
    end

    # Mostrar mensaje final
    if errores.any?
      flash[:alert] = "Se procesaron #{archivos_procesados} archivos, pero hubo errores: #{errores.join('; ')}"
    else
      flash[:notice] = "Todos los archivos se procesaron correctamente. #{archivos_procesados} facturaciones creadas."
    end

    redirect_to facturacions_path
  end

  def new_bulk_upload_pdf
    # Solo muestra el formulario
  end
  def bulk_upload_pdf
    archivos = params[:archivos] || [] # Asegurarse de que archivos es un array válido
    errores = []
    procesados = 0

    archivos.each do |file|
      begin
        # Verificar que el archivo sea del tipo esperado
        if file.is_a?(ActionDispatch::Http::UploadedFile)
          # Extraer el nombre base del archivo
          base_name = File.basename(file.original_filename, File.extname(file.original_filename))
          number = base_name.split(' ', 2).first.to_i

          # Buscar la facturación correspondiente
          facturacion = Facturacion.find_by(number: number)

          if facturacion
            # Adjuntar el archivo y actualizar la fecha de emisión
            facturacion.cotizacion_pdf_file.attach(file)
            facturacion.update!(emicion: Date.current)

            procesados += 1
          else
            errores << "#{file.original_filename}: No se encontró una facturación con el número #{number}."
          end
        else
          errores << "Uno de los elementos subidos no es un archivo válido."
        end
      rescue StandardError => e
        errores << "#{file.original_filename}: Error procesando el archivo - #{e.message}"
      end
    end

    # Generar mensajes de resultado
    if errores.any?
      flash[:alert] = "Se procesaron #{procesados} archivos, pero hubo errores: #{errores.join(', ')}"
    else
      flash[:notice] = "Todos los archivos se procesaron exitosamente (#{procesados} archivos)."
    end
    redirect_to facturacions_path
  end



  private

  def set_facturacion
    @facturacion = Facturacion.find(params[:id])
  end

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


  def valid_file_type?(file, allowed_types)
    file.attached? && file.content_type.in?(allowed_types)
  end
  def valid_uploaded_file?(file, allowed_types)
    file.is_a?(ActionDispatch::Http::UploadedFile) && file.content_type.in?(allowed_types)
  end


  def parse_filename(filename)
    base_name = File.basename(filename, File.extname(filename))

    parts = base_name.split(' ', 2)
    number = parts[0].to_i

    name_match = base_name.match(/OPORTUNIDAD DE NEGOCIO.*?\.\s*(.+)/i)
    name = name_match[1] if name_match

    if name.present?
      name = name.split.map(&:capitalize).join(' ')
    else
      raise "No se pudo extraer el nombre de '#{filename}'. Asegúrate de que siga el formato esperado."
    end

    [number, name]
  end






  def capitalize_words(texto)
    texto.split.map(&:capitalize).join(' ')
  end

end
