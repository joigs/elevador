class FacturacionsController < ApplicationController
  before_action :set_facturacion, only: [
    :show, :edit, :update,
    :download_solicitud_file, :download_cotizacion_doc_file,
    :download_cotizacion_pdf_file, :download_orden_compra_file,
    :download_facturacion_file, :download_all_files,
  ]

  before_action :authorize_user

  def index
    if params[:notification_id].present?
      @notification = Notification.find(params[:notification_id])
      @facturacions = @notification.facturacions.order(number: :desc)
    else
      @facturacions = Facturacion.order(number: :desc)
    end

    if params[:fecha_inicio].present? || params[:fecha_fin].present?
      begin
        fi = Date.strptime(params[:fecha_inicio], '%d-%m-%Y') if params[:fecha_inicio].present?
        ff = Date.strptime(params[:fecha_fin],   '%d-%m-%Y') if params[:fecha_fin].present?

        if fi && ff
          if fi > ff
            flash[:alert] = "La fecha inicial no puede ser posterior a la fecha final."
          else
            @facturacions = @facturacions.where("solicitud >= ? AND solicitud <= ?", fi, ff)
          end
        elsif fi
          @facturacions = @facturacions.where("solicitud >= ?", fi)
        elsif ff
          @facturacions = @facturacions.where("solicitud <= ?", ff)
        end
      rescue ArgumentError
        flash[:alert] = "Fechas no válidas."
      end
    end
    @facturacions
  end

  def show
    @inspections = Inspection.where(facturacion_id: @facturacion.id)
  end

  def new
    @facturacion = Facturacion.new
    @facturacion.number = (Facturacion.maximum(:number) || 0) + 1

  end

  def create
    @facturacion = Facturacion.new(facturacion_params)

    if @facturacion.save
      notification = Notification.find_by(notification_type: :solicitud_pendiente)
      notification.facturacions << @facturacion if notification

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




    def destroy
      @facturacion = Facturacion.find(params[:id])

      @inspections = Inspection.where(facturacion_id: @facturacion.id)

      if @inspections.any?
        message = "La cotización eliminada estaba asociada a las inspecciones "
      end

      @inspections.each do |inspection|
        inspection.update(facturacion_id: nil)
        message += "N°#{inspection.number}, "
      end
      if @inspections.any?
        message += "por favor volver a registrar la cotización corregida en esas inspecciones."
      end

      authorize! @facturacion.destroy

      if message
        flash[:notice] = message
      else
        flash[:notice] = "Cotización eliminada"
      end

      respond_to do |format|
        format.html { redirect_to home_path }
        format.turbo_stream { head :no_content }
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
      notification = Notification.find_by(notification_type: :entrega_pendiente)
      notification.facturacions.delete(@facturacion) if notification
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


        venv_python = Rails.root.join('ascensor', 'bin', 'python').to_s
        script_path = Rails.root.join('app', 'scripts', 'extract_table_value.py').to_s

        require 'tempfile'
        temp_file = Tempfile.new(["facturacion_doc", ".docx"])
        temp_file.binmode
        temp_file.write(@facturacion.cotizacion_doc_file.blob.download)
        temp_file.flush

        cmd = "#{venv_python} \"#{script_path}\" --docx \"#{temp_file.path}\""
        table_value = `#{cmd}`.strip
        puts "original: #{table_value}"

        temp_file.close
        temp_file.unlink

        matches = table_value.scan(/(\d+(?:[.,]\d+)?)/)

        if matches.any?
          sum = 0.0
          matches.each do |match|
            number_str = match[0].gsub(/\s+/, '').tr(',', '.')
            sum += number_str.to_f
          end
          extracted_number = sum
          flash[:alert] = "El precio obtenido del documento es #{extracted_number}. Si es que es erróneo, por favor cambiar manualmente."
          flash[:alert_type] = "info"

          @facturacion.update(emicion: Date.current, precio: extracted_number)
        else
          flash[:alert] = "Se subieron los documentos, pero no se pudo extraer un precio válido. Por favor ingresar manualmente."
          flash[:alert_type] = "warning"
          @facturacion.update(emicion: Date.current)
        end
        notification = Notification.find_by(notification_type: :solicitud_pendiente)
        notification.facturacions.delete(@facturacion) if notification

        next_notification = Notification.find_by(notification_type: :entrega_pendiente)
        next_notification.facturacions << @facturacion if next_notification

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
    if orden_compra_file.present? && !valid_uploaded_file?(orden_compra_file, allowed_types)
      flash.now[:alert] = "Tipo de archivo invalido"
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


  def update_fecha_entrega
    @facturacion = Facturacion.find(params[:id])

    if @facturacion.update(facturacion_params)
        next_notification = Notification.find_by(notification_type: :factura_pendiente)
        next_notification.facturacions << @facturacion if next_notification
      redirect_to @facturacion, notice: "Fecha de evaluación actualizada con éxito."
    else
      flash.now[:alert] = "No se pudo actualizar la fecha de evaluación."
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

    if facturacion_file.blank?
      flash.now[:alert] = "El archivo PDF es obligatorio."
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

    if @facturacion.save

      notification = Notification.find_by(notification_type: :factura_pendiente)
      notification.facturacions.delete(@facturacion) if notification


      redirect_to @facturacion, notice: "Factura subida correctamente."
    else
      flash.now[:alert] = "No se pudo procesar la solicitud."
      render :show, status: :unprocessable_entity
    end
  end

  def update_price
    @facturacion = Facturacion.find(params[:id])

    if @facturacion.update(precio_params)
      render json: { success: true, precio: @facturacion.precio }
    else
      render json: { success: false, errors: @facturacion.errors.full_messages }, status: :unprocessable_entity
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

  def bulk_upload
    files = params[:files]

    if files.blank?
      redirect_to new_bulk_upload_facturacions_path, alert: "No se seleccionaron archivos para subir."
      return
    end

    errores = []
    archivos_procesados = 0

    files.each do |file|
      next unless file.is_a?(ActionDispatch::Http::UploadedFile)

      begin
        nombre_archivo = file.original_filename
        number, name = parse_excel_filename(nombre_archivo)

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

    if errores.any?
      flash[:alert] = "Se procesaron #{archivos_procesados} archivos, pero hubo errores: #{errores.join('; ')}"
    else
      flash[:notice] = "Todos los archivos se procesaron correctamente. #{archivos_procesados} facturaciones creadas."
    end

    redirect_to facturacions_path
  end


  def new_bulk_upload_pdf
  end
  def bulk_upload_pdf
    archivos = params[:archivos] || []
    errores = []
    procesados_pdf = 0
    procesados_docx = 0

    archivos.each do |file|
      begin
        if file.is_a?(ActionDispatch::Http::UploadedFile)
          base_name = File.basename(file.original_filename, File.extname(file.original_filename))
          number, name = parse_filename(base_name)

          facturacion = Facturacion.find_by(number: number)

          if facturacion
            case file.content_type
            when "application/pdf"
              facturacion.cotizacion_pdf_file.attach(file)
              procesados_pdf += 1
            when "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
              facturacion.cotizacion_doc_file.attach(file)
              procesados_docx += 1
            else
              errores << "#{file.original_filename}: Tipo de archivo no permitido."
              next
            end

            facturacion.update!(emicion: Date.current)
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

    if errores.any?
      flash[:alert] = "Se procesaron #{procesados_pdf} PDFs y #{procesados_docx} DOCX, pero hubo errores: #{errores.join('; ')}"
    else
      flash[:notice] = "Todos los archivos se procesaron exitosamente (#{procesados_pdf} PDFs y #{procesados_docx} DOCX)."
    end
    redirect_to facturacions_path
  end

  def download_solicitud_template
    file_path = Rails.root.join("app", "templates", "solicitud_template.xlsx")
    if File.exist?(file_path)
      send_file file_path, filename: "Solicitud_Template.xlsx", type: "application/vnd.ms-excel"
    else
      redirect_to facturacion_path(@facturacion), alert: "La plantilla de solicitud no está disponible."
    end
  end

  def download_cotizacion_template
    @facturacion = Facturacion.find(params[:id])

    begin
      # Llamar al servicio para generar el documento
      new_doc_path = DocumentGeneratorCotizacion.generate_document(@facturacion.id)

      send_file new_doc_path,
                type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                disposition: 'attachment',
                filename: File.basename(new_doc_path)
    rescue StandardError => e
      flash[:alert] = "Error al generar la plantilla de cotización: #{e.message}"
      redirect_to facturacion_path(@facturacion)
    end
  end



  private

  def set_facturacion
    @facturacion = Facturacion.find(params[:id])
  end

  def facturacion_params
    params.require(:facturacion).permit(
      :number,
      :name,
      :precio,
      :presos,
      :solicitud,
      :emicion,
      :entregado,
      :resultado,
      :oc,      
      :fecha_entrega,
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
    # Separar en partes usando "_" o "-" como delimitador
    parts = filename.split(/[_-]/, 2)
    number = parts[0].to_i

    # Extraer el nombre ignorando números y guiones al inicio
    name_part = parts[1]&.strip || ""
    name = name_part.sub(/^[\d_\-]+/, '').strip

    [number, name]
  end


  def precio_params
    params.require(:facturacion).permit(:precio)
  end




  def capitalize_words(texto)
    texto.split.map(&:capitalize).join(' ')
  end



  def parse_excel_filename(filename)
    base_name = File.basename(filename, File.extname(filename))

    # Separar en partes usando "_" o "-" como delimitador
    parts = base_name.split(/[_-]/, 2)
    number = parts[0].to_i

    # Extraer el nombre ignorando números y guiones al inicio
    name_part = parts[1]&.strip || ""
    name = name_part.sub(/^[\d_\-]+/, '').strip

    [number, name]
  end


end
