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

  def export_monthly_report
    require 'csv'
    require 'roo'
    require 'write_xlsx'

    levenshtein = lambda do |s, t|
      return t.length if s.empty?
      return s.length if t.empty?

      d = Array.new(s.length + 1) { Array.new(t.length + 1) }
      (0..s.length).each { |i| d[i][0] = i }
      (0..t.length).each { |j| d[0][j] = j }

      (1..t.length).each do |j|
        (1..s.length).each do |i|
          cost = (s[i - 1] == t[j - 1]) ? 0 : 1
          d[i][j] = [d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost].min
        end
      end
      d[s.length][t.length]
    end

    csv_path = Rails.root.join('app', 'templates', 'comunas.csv')
    commune_list = []

    if File.exist?(csv_path)
      CSV.foreach(csv_path, headers: false) do |row|
        next unless row[0].present? && row[4].present?

        raw_commune = row[0].strip
        raw_region = row[4].strip

        clean_commune = ActiveSupport::Inflector.transliterate(raw_commune).downcase.gsub(/[^a-z0-9\s]/, ' ').strip.squeeze(' ')

        commune_list << {
          clean: clean_commune,
          original_commune: raw_commune,
          region: raw_region,
          word_count: clean_commune.split.size
        }
      end
    end

    commune_list.sort_by! { |c| -c[:clean].length }

    ordered_regions = commune_list.map { |c| c[:region] }.uniq.sort

    years = [2024, 2025, 2026]
    data_store = {}

    years.each do |y|
      data_store[y] = {}
      (1..12).each do |m|
        data_store[y][m] = {}
        ordered_regions.each do |reg|
          data_store[y][m][reg] = { cots: 0, vens: 0, eq_cots: 0, eq_vens: 0 }
        end
      end
    end

    errors_log = {}
    years.each { |y| errors_log[y] = [] }

    Facturacion.includes(solicitud_file_attachment: :blob).find_each do |fact|
      next unless fact.solicitud_file.attached?

      year_em = fact.emicion&.year

      sale_date = fact.fecha_inspeccion || fact.fecha_venta
      year_sale = sale_date&.year

      next unless (year_em && years.include?(year_em)) || (year_sale && years.include?(year_sale))

      error_msg = nil
      region_found = nil
      equipos_count = 0
      commune_found_name = nil

      begin
        Tempfile.create(['solicitud', fact.solicitud_file.filename.extension_with_delimiter]) do |temp_file|
          temp_file.binmode
          temp_file.write(fact.solicitud_file.download)
          temp_file.rewind

          xlsx = Roo::Spreadsheet.open(temp_file.path, extension: File.extname(temp_file.path).delete('.'))
          sheet = xlsx.sheet(0)

          lugar_raw = nil
          addr_row, addr_col = nil, nil

          (1..30).each do |r|
            (1..20).each do |c|
              val = sheet.cell(r, c).to_s
              clean_val = ActiveSupport::Inflector.transliterate(val).downcase

              if clean_val.include?('direccion') || levenshtein.call('direccion', clean_val) <= 2
                addr_row, addr_col = r + 1, c
                break
              end
            end
            break if addr_row
          end

          if addr_row
            lugar_raw = sheet.cell(addr_row, addr_col).to_s
          else
            lugar_raw = sheet.cell(4, 3).to_s
          end

          if lugar_raw.blank?
            error_msg = "Celda de dirección vacía"
          else
            lugar_clean = ActiveSupport::Inflector.transliterate(lugar_raw).downcase.gsub(/[^a-z0-9\s]/, ' ').strip.squeeze(' ')
            lugar_words = lugar_clean.split

            match_found = false

            commune_list.each do |commune_obj|
              target = commune_obj[:clean]
              target_words_count = commune_obj[:word_count]

              if lugar_clean.include?(target)
                region_found = commune_obj[:region]
                commune_found_name = commune_obj[:original_commune]
                match_found = true
                break
              end

              if lugar_words.size >= target_words_count
                (0..(lugar_words.size - target_words_count)).each do |i|
                  snippet = lugar_words[i, target_words_count].join(' ')

                  dist = levenshtein.call(target, snippet)
                  threshold = (target.length * 0.25).ceil
                  threshold = 1 if threshold < 1

                  if dist <= threshold
                    region_found = commune_obj[:region]
                    commune_found_name = commune_obj[:original_commune]
                    match_found = true
                    break
                  end
                end
              end
              break if match_found
            end

            unless match_found
              error_msg = "No se identificó comuna válida en: '#{lugar_raw}'"
            end

            if match_found && region_found.nil?
              error_msg = "Comuna '#{commune_found_name}' encontrada pero sin región asociada."
            end
          end

          if error_msg.nil?
            equip_row, equip_col = nil, nil

            (1..30).each do |r|
              (1..20).each do |c|
                val = sheet.cell(r, c).to_s
                clean_val = ActiveSupport::Inflector.transliterate(val).downcase

                if clean_val.include?('ascensores') || clean_val.include?('equipos') || levenshtein.call('ascensores', clean_val) <= 3
                  equip_row, equip_col = r + 1, c
                  break
                end
              end
              break if equip_row
            end

            unless equip_row
              equip_row, equip_col = 4, 4
            end

            sum_equipos = 0
            current_r = equip_row
            found_number = false

            loop do
              cell_val = sheet.cell(current_r, equip_col)
              break if cell_val.nil? || cell_val.to_s.strip.empty?

              if cell_val.to_s.match?(/\d+/)
                sum_equipos += cell_val.to_f
                found_number = true
              end
              current_r += 1
              break if current_r > equip_row + 50
            end

            if !found_number && sum_equipos == 0
              val_check = sheet.cell(equip_row, equip_col).to_s
              unless val_check.match?(/\d+/)
                error_msg = "No se encontraron equipos numéricos"
              end
            end
            equipos_count = sum_equipos.to_i
          end

        end
      rescue StandardError => e
        error_msg = "Error leyendo archivo: #{e.message}"
      end

      target_year_log = year_em && years.include?(year_em) ? year_em : (year_sale && years.include?(year_sale) ? year_sale : years.first)

      if error_msg
        errors_log[target_year_log] << [fact.number, error_msg]
      else
        if fact.emicion && years.include?(fact.emicion.year)
          m = fact.emicion.month
          y = fact.emicion.year
          data_store[y][m][region_found][:cots] += 1
          data_store[y][m][region_found][:eq_cots] += equipos_count
        end

        if sale_date && years.include?(sale_date.year)
          m = sale_date.month
          y = sale_date.year
          data_store[y][m][region_found][:vens] += 1
          data_store[y][m][region_found][:eq_vens] += equipos_count
        end
      end
    end

    Tempfile.create(['reporte_mensual', '.xlsx']) do |tmp|
      path = tmp.path
      tmp.close

      workbook = WriteXLSX.new(path)

      header_format = workbook.add_format(bold: 1, align: 'center', border: 1, bg_color: '#D3D3D3')
      sub_header_format = workbook.add_format(bold: 1, align: 'center', border: 1, font_size: 9)
      cell_format = workbook.add_format(border: 1, align: 'center')
      region_format = workbook.add_format(bold: 1, border: 1)
      error_header_format = workbook.add_format(bold: 1, color: 'white', bg_color: 'red', align: 'center')

      months_es = %w[None Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre]

      years.each do |year|
        sheet = workbook.add_worksheet(year.to_s)

        sheet.write(0, 0, "Región", header_format)

        col_idx = 1
        (1..12).each do |month|
          month_name = months_es[month]
          sheet.merge_range(0, col_idx, 0, col_idx + 3, month_name, header_format)
          sheet.write(1, col_idx, "Cot", sub_header_format)
          sheet.write(1, col_idx + 1, "Ventas", sub_header_format)
          sheet.write(1, col_idx + 2, "Eq.Cot", sub_header_format)
          sheet.write(1, col_idx + 3, "Eq.Ven", sub_header_format)
          col_idx += 4
        end

        row_idx = 2
        ordered_regions.each do |reg|
          sheet.write(row_idx, 0, reg, region_format)
          curr_col = 1
          (1..12).each do |month|
            d = data_store[year][month][reg]
            sheet.write(row_idx, curr_col, d[:cots], cell_format)
            sheet.write(row_idx, curr_col + 1, d[:vens], cell_format)
            sheet.write(row_idx, curr_col + 2, d[:eq_cots], cell_format)
            sheet.write(row_idx, curr_col + 3, d[:eq_vens], cell_format)
            curr_col += 4
          end
          row_idx += 1
        end

        err_start_col = (12 * 4) + 2
        sheet.write(0, err_start_col, "Número", error_header_format)
        sheet.write(0, err_start_col + 1, "Detalle Error", error_header_format)
        sheet.set_column(err_start_col + 1, err_start_col + 1, 50)

        err_row = 1
        errors_log[year].each do |err_data|
          sheet.write(err_row, err_start_col, err_data[0])
          sheet.write(err_row, err_start_col + 1, err_data[1])
          err_row += 1
        end
      end

      workbook.close

      send_data File.binread(path),
                filename: "reporte_mensual_#{Time.zone.now.strftime('%Y%m%d_%H%M')}.xlsx",
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                disposition: :attachment

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

    parts = base_name.split(/[_-]/, 2)
    number = parts[0].to_i

    name_part = parts[1]&.strip || ""
    name = name_part.sub(/^[\d_\-]+/, '').strip

    [number, name]
  end

  def format_date(date)
    date&.strftime('%d/%m/%Y')
  end


end
