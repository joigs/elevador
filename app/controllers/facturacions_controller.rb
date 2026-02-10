class FacturacionsController < ApplicationController
  before_action :set_facturacion, only: [
    :show, :edit, :update,
    :download_solicitud_file, :download_cotizacion_doc_file,
    :download_cotizacion_pdf_file, :download_orden_compra_file,
    :download_facturacion_file, :download_all_files,
  ]

  before_action :authorize_user
  require 'csv'
  require 'roo'
  require 'write_xlsx'
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

  # require 'roo'  # si no está autoload

  def create
    @facturacion = Facturacion.new(facturacion_params)

    uploaded = facturacion_params[:solicitud_file]
    if uploaded
      xlsx = Roo::Spreadsheet.open(
        uploaded.tempfile.path,
        extension: File.extname(uploaded.original_filename).delete('.').presence || 'xlsx'
      )
      sheet = xlsx.sheet(0)

      empresa_val = nil
      n1_val = nil
      found_cond = false
      found_asc = false

      (1..11).each do |r|
        (1..11).each do |c|
          raw = sheet.cell(r, c)
          norm = raw.to_s.gsub(/\s+/, '').downcase

          if !found_cond && norm == 'condominio'
            debajo = sheet.cell(r + 1, c)
            empresa_val = debajo.to_s.strip if debajo.present?
            found_cond = true
          end

          if !found_asc && norm == 'ascensores'
            debajo = sheet.cell(r + 1, c)
            if debajo.to_s.strip.match?(/\A\d+\z/)
              n1_val = debajo.to_i
            end
            found_asc = true
          end
        end
      end

      if empresa_val.blank?
        b5 = sheet.cell(5, 2)
        empresa_val = b5.to_s.strip if b5.present?
      end
      if n1_val.nil?
        d5 = sheet.cell(5, 4)
        n1_val = d5.to_i if d5.to_s.strip.match?(/\A\d+\z/)
      end

      @facturacion.empresa_provisional = empresa_val if empresa_val.present?
      @facturacion.n1 = n1_val if n1_val.is_a?(Integer)
    end

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

  def set_fecha_venta
    @facturacion = Facturacion.find(params[:id])

    if @facturacion.update(fecha_venta: Date.current)
      respond_to do |format|
        format.html { redirect_to @facturacion, notice: "Fecha de venta establecida a hoy." }
        format.json { render json: { success: true, fecha_venta: @facturacion.fecha_venta.strftime('%d-%m-%Y') } }
      end
    else
      respond_to do |format|
        format.html { redirect_to @facturacion, alert: "No se pudo actualizar la fecha." }
        format.json { render json: { success: false }, status: :unprocessable_entity }
      end
    end
  end

  def update_fecha_venta
    @facturacion = Facturacion.find(params[:id])

    raw = params.dig(:facturacion, :fecha_venta).to_s
    # acepta "dd-mm-YYYY" o "dd/mm/YYYY"
    parsed =
      begin
        Date.strptime(raw.tr('/', '-'), '%d-%m-%Y')
      rescue ArgumentError
        nil
      end

    unless parsed
      render json: { success: false, message: "Fecha inválida" }, status: :unprocessable_entity and return
    end

    if @facturacion.update(fecha_venta: parsed)
      render json: { success: true, fecha_venta: @facturacion.fecha_venta.strftime('%d-%m-%Y') }
    else
      render json: { success: false, message: @facturacion.errors.full_messages.to_sentence }, status: :unprocessable_entity
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




  def update_empresa_provisional
    @facturacion = Facturacion.find(params[:id])

    if @facturacion.update(empresa_provisional: params.dig(:facturacion, :empresa_provisional))
      render json: { success: true, empresa_provisional: @facturacion.empresa_provisional }
    else
      render json: { success: false, errors: @facturacion.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_n1
    @facturacion = Facturacion.find(params[:id])

    if @facturacion.update(n1: params.dig(:facturacion, :n1))
      render json: { success: true, n1: @facturacion.n1 }
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
      send_file file_path,
                filename: "Solicitud_Template.xlsx",
                type: "application/vnd.ms-excel"

      DeleteTempFileJob.set(wait: 5.minutes).perform_later(file_path.to_s)
    else
      redirect_to facturacion_path(@facturacion), alert: "La plantilla de solicitud no está disponible."
    end
  end

  def download_cotizacion_template
    @facturacion = Facturacion.find(params[:id])

    begin
      new_doc_path = DocumentGeneratorCotizacion.generate_document(@facturacion.id)

      send_file new_doc_path,
                type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                disposition: 'attachment',
                filename: File.basename(new_doc_path)

      DeleteTempFileJob.set(wait: 5.minutes).perform_later(new_doc_path.to_s)

    rescue StandardError => e
      flash[:alert] = "Error al generar la plantilla de cotización: #{e.message}"
      redirect_to facturacion_path(@facturacion)
    end
  end

  def download_cotizacion_template_og
    @facturacion = Facturacion.find(params[:id])

    begin
      new_doc_path = DocumentGeneratorCotizacionOg.generate_document(@facturacion.id)

      send_file new_doc_path,
                type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                disposition: 'attachment',
                filename: File.basename(new_doc_path)

      DeleteTempFileJob.set(wait: 5.minutes).perform_later(new_doc_path.to_s)

    rescue StandardError => e
      flash[:alert] = "Error al generar la plantilla de cotización: #{e.message}"
      redirect_to facturacion_path(@facturacion)
    end
  end

  def download_all_excel
    facturaciones = Facturacion.with_attached_solicitud_file

    temp_file = Tempfile.new("solicitudes-#{Time.now.to_i}.zip")

    begin
      Zip::OutputStream.open(temp_file) { |zos| }

      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
        facturaciones.each do |facturacion|
          next unless facturacion.solicitud_file.attached?

          file = facturacion.solicitud_file
          file_name = "#{file.filename}"

          zipfile.get_output_stream(file_name) { |f| f.write(file.download) }
        end
      end

      send_data File.read(temp_file.path),
                type: 'application/zip',
                filename: "solicitudes_#{Time.now.strftime('%Y%m%d%H%M%S')}.zip"
      DeleteTempFileJob.set(wait: 5.minutes).perform_later(temp_file.to_s)

    ensure
      temp_file.close
      temp_file.unlink
    end
  end


  def export_xlsx
    @facturacions = Facturacion
                     .order(number: :asc)



    Tempfile.create(['cotizaciones', '.xlsx']) do |tmp|
      path = tmp.path
      tmp.close

      workbook  = WriteXLSX.new(path)
      sheet     = workbook.add_worksheet('Cotizaciones')

      headers = [
        'N° Correlativo', 'Nombre', 'Solicitud', 'Emisión', 'Entregado', 'Resultado', 'Orden de Compra', 'Fecha Venta', 'Fecha inspección', 'Inspecciones completadas', 'Factura'
      ]
      sheet.write_row(0, 0, headers)

      Facturacion
        .order(number: :asc)
        .find_each
        .with_index(1) do |ins, row|
        sheet.write_row row, 0, [
          ins.number,
          ins.name,
          format_date(ins.solicitud),
          format_date(ins.emicion),
          format_date(ins.entregado),
          ins.resultado,
          format_date(ins.oc),
          format_date(ins.fecha_venta),
          format_date(ins.fecha_inspeccion),
          "#{ins.inspecciones_con_resultado_count}/#{ins.inspecciones_total}",
          format_date(ins.factura)
        ]
      end

      workbook.close

      send_data File.binread(path),
                filename: "cotizaciones_#{Time.zone.now.strftime('%Y%m%d_%H%M')}.xlsx",
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                disposition: :attachment

      DeleteTempFileJob.set(wait: 5.minutes).perform_later(path)
    end
  end
  def export_report_region_month
    load_location_data

    @data = {}
    @errors = {}

    years = [2024, 2025, 2026]
    regions_list = @regions_map.values.uniq.sort

    years.each do |y|
      @data[y] = {}
      @errors[y] = []
      (1..12).each do |m|
        next if y == 2026 && m > 1

        @data[y][m] = {}
        regions_list.each do |r|
          @data[y][m][r] = { cotizaciones: 0, ventas: 0, equipos_cot: 0, equipos_ven: 0 }
        end
      end
    end

    facturaciones = Facturacion.includes(solicitud_file_attachment: :blob)
                               .where("emicion >= ? OR factura >= ?", Date.new(2024, 1, 1), Date.new(2024, 1, 1))

    facturaciones.find_each do |facturacion|
      process_facturacion_for_report(facturacion, years)
    end

    Tempfile.create(['reporte_regional', '.xlsx']) do |tmp|
      path = tmp.path
      tmp.close

      workbook = WriteXLSX.new(path)

      header_format = workbook.add_format(bold: 1, border: 1, bg_color: '#DDDDDD', align: 'center')
      bold_format = workbook.add_format(bold: 1)
      error_header_format = workbook.add_format(bold: 1, color: 'white', bg_color: 'red')

      years.each do |year|
        sheet = workbook.add_worksheet(year.to_s)
        current_row = 0

        (1..12).each do |month|
          next if @data[year][month].nil?

          month_name = Date.new(year, month, 1).strftime("%B").capitalize
          sheet.write(current_row, 0, "Mes: #{month_name}", bold_format)
          current_row += 1

          headers = ['Región', 'N° Cotizaciones', 'N° Ventas', 'N° Equipos Cot.', 'N° Equipos Ven.']
          sheet.write_row(current_row, 0, headers, header_format)
          current_row += 1

          regions_list.each do |region|
            stats = @data[year][month][region]
            row_data = [
              region,
              stats[:cotizaciones],
              stats[:ventas],
              stats[:equipos_cot],
              stats[:equipos_ven]
            ]
            sheet.write_row(current_row, 0, row_data)
            current_row += 1
          end
          current_row += 2
        end

        if @errors[year].any?
          sheet.write(0, 7, "Errores de Procesamiento", error_header_format)
          sheet.write_row(1, 7, ['ID', 'Número', 'Descripción del Error'], header_format)

          error_row = 2
          @errors[year].each do |err|
            sheet.write(error_row, 7, err[:id])
            sheet.write(error_row, 8, err[:number])
            sheet.write(error_row, 9, err[:error])
            error_row += 1
          end
          sheet.set_column(9, 9, 50)
        end
      end

      workbook.close

      send_data File.binread(path),
                filename: "Reporte_Regional_#{Time.now.strftime('%Y%m%d')}.xlsx",
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                disposition: 'attachment'

      DeleteTempFileJob.set(wait: 5.minutes).perform_later(path)
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
      :n1,
      :presos,
      :solicitud,
      :emicion,
      :entregado,
      :resultado,
      :oc,      
      :fecha_entrega,
      :fecha_venta,
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
    parts = filename.split(/[_-]/, 2)
    number = parts[0].to_i

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

  def format_date(date)
    date&.strftime('%d/%m/%Y')
  end

  def load_location_data
    csv_path = Rails.root.join('app', 'templates', 'comunas.csv')
    @commune_map = {} # "comuna_normalizada" => "Nombre Region"
    @regions_map = {} # "region_normalizada" => "Nombre Region"

    CSV.foreach(csv_path, headers: false) do |row|
      commune_name = row[0]
      region_name = row[4]

      norm_commune = normalize_text(commune_name)
      norm_region = normalize_text(region_name)

      @commune_map[norm_commune] = region_name
      @regions_map[norm_region] = region_name
    end
  end

  def process_facturacion_for_report(facturacion, valid_years)
    # Verificar si tiene fechas relevantes para los años solicitados
    has_emicion = facturacion.emicion && valid_years.include?(facturacion.emicion.year)
    has_factura = facturacion.factura && valid_years.include?(facturacion.factura.year)

    return unless has_emicion || has_factura
    return unless facturacion.solicitud_file.attached?

    # --- Paso 1 y 2: Abrir Excel y Buscar Dirección ---
    begin
      info = extract_info_from_excel(facturacion)
    rescue StandardError => e
      register_error(facturacion, "Error al leer archivo Excel: #{e.message}")
      return
    end

    if info[:error]
      register_error(facturacion, info[:error])
      return
    end

    # Si llegamos aquí, tenemos región y cantidad de equipos válidos
    region = info[:region]
    equipos = info[:equipos]

    # --- Agregar data a Cotizaciones (Emisión) ---
    if has_emicion
      y = facturacion.emicion.year
      m = facturacion.emicion.month
      if @data[y] && @data[y][m]
        @data[y][m][region][:cotizaciones] += 1
        @data[y][m][region][:equipos_cot] += equipos
      end
    end

    # --- Agregar data a Ventas (Factura) ---
    if has_factura
      y = facturacion.factura.year
      m = facturacion.factura.month
      if @data[y] && @data[y][m]
        @data[y][m][region][:ventas] += 1
        @data[y][m][region][:equipos_ven] += equipos
      end
    end
  end

  def extract_info_from_excel(facturacion)
    # Descargar a Tempfile para Roo
    result = { region: nil, equipos: 0, error: nil }

    facturacion.solicitud_file.open do |file|
      xlsx = Roo::Spreadsheet.open(file.path, extension: :xlsx)
      sheet = xlsx.sheet(0)

      # --- Lógica Dirección / Región ---
      lugar_raw = nil
      found_direccion = false

      # Buscamos "Dirección" en las primeras 20 filas/columnas
      (1..20).each do |r|
        (1..10).each do |c|
          cell_val = sheet.cell(r, c).to_s
          if normalize_text(cell_val).include?("direccion")
            # Leemos la celda de abajo
            lugar_raw = sheet.cell(r + 1, c).to_s
            found_direccion = true
            break
          end
        end
        break if found_direccion
      end

      # Si no se encontró, usar C4 -> leer C5 (fila 5, columna 3)
      unless found_direccion
        lugar_raw = sheet.cell(5, 3).to_s # C5
      end

      if lugar_raw.blank?
        return { error: "No se encontró texto de dirección (LUGAR vacío)." }
      end

      # Identificar Región basado en LUGAR
      region_detected = identify_region(lugar_raw)

      if region_detected == :ambiguous
        return { error: "Ambigüedad: Se detectaron múltiples comunas/regiones en '#{lugar_raw}'." }
      elsif region_detected.nil?
        return { error: "No se encontró comuna/región válida en '#{lugar_raw}'." }
      else
        result[:region] = region_detected
      end

      # --- Lógica Equipos (Ascensores) ---
      found_asc = false
      start_row = nil
      start_col = nil

      (1..20).each do |r|
        (1..10).each do |c|
          cell_val = sheet.cell(r, c).to_s
          if normalize_text(cell_val).include?("ascensores")
            start_row = r + 1
            start_col = c
            found_asc = true
            break
          end
        end
        break if found_asc
      end

      # Si no encuentra, usar D4 -> leer desde D5 (fila 5, columna 4)
      unless found_asc
        start_row = 5
        start_col = 4
      end

      # Sumar hacia abajo
      total_equipos = 0
      current_r = start_row

      # Iterar hacia abajo hasta encontrar vacío (limite de seguridad 50 filas)
      loop do
        val = sheet.cell(current_r, start_col)
        break if val.nil? || val.to_s.strip.empty? || current_r > (start_row + 50)

        # Intentar convertir a numero
        num = val.to_s.gsub(',', '.').to_f # Manejo básico de decimales si hubiera
        total_equipos += num.to_i # Asumimos equipos enteros

        current_r += 1
      end

      if total_equipos == 0
        return { error: "Cantidad de equipos detectada es 0 o no se pudo leer." }
      end

      result[:equipos] = total_equipos
      result
    end

    result # Return final
  end

  def identify_region(lugar_text)
    norm_lugar = normalize_text(lugar_text)
    matches = Set.new

    # 1. Buscar coincidencia exacta al final del string para Comunas
    @commune_map.each do |commune_norm, region_name|
      # Verificamos si la dirección termina con la comuna o contiene la comuna
      # El prompt dice "ver cual aparece al final", pero a veces hay CP u otros datos.
      # Usaremos include? para ser flexibles, pero priorizando el final.
      if norm_lugar.end_with?(commune_norm) || norm_lugar.include?(" #{commune_norm} ") || norm_lugar.include?(" #{commune_norm}")
        matches << region_name
      end
    end

    # 2. Buscar coincidencias con Nombres de Regiones directamente
    @regions_map.each do |region_norm, region_name|
      if norm_lugar.include?(region_norm)
        matches << region_name
      end
    end

    return nil if matches.empty?
    return :ambiguous if matches.size > 1

    matches.first
  end

  def normalize_text(text)
    return "" if text.nil?
    # Transliterate quita acentos (á -> a), downcase minusculas, gsub quita puntuación
    I18n.transliterate(text).downcase.gsub(/[^a-z0-9\s]/, '').strip
  end

  def register_error(facturacion, msg)
    y_emicion = facturacion.emicion&.year
    y_factura = facturacion.factura&.year

    # Registramos el error en el año correspondiente (o en ambos si aplica)
    years_to_log = [y_emicion, y_factura].compact.select { |y| @errors.key?(y) }.uniq

    # Si no tiene fecha válida pero falló el proceso, lo metemos en el primer año disponible o 2024 por defecto para que se vea
    years_to_log = [2024] if years_to_log.empty?

    years_to_log.each do |y|
      @errors[y] << {
        id: facturacion.id,
        number: facturacion.number,
        error: msg
      }
    end
  end
end
