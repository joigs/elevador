class InspectionsController < ApplicationController
  require "ostruct"
  require 'securerandom'
  require 'fileutils'
  require 'open3'
  def index
    if params[:facturacion_id].present?
      params[:q] ||= {}
      params[:q][:facturacion_id_eq] = params[:facturacion_id]
      @facturacion = Facturacion.find(params[:facturacion_id])
    end

    @q = Inspection.ransack(params[:q])

    @inspections = @q.result(distinct: true)
                     .where("number > 0")
                     .includes(:item, :principal, :report)
                     .order(number: :desc)
                     .then { |relation| @facturacion ? relation.where(facturacion_id: @facturacion.id) : relation }


    unless Current.user.tabla
      @pagy, @inspections = pagy_countless(@inspections, items: 10)
    end
  end

  def show


    inspection
    @item = inspection.item
    @report = Report.find_by(inspection_id: @inspection.id)

    @previous_inspection = @item.inspections.where(state: ["Cerrado", "Abierto"]).order(number: :desc).offset(1).first

    if @previous_inspection
      @show_third_radio_button = true
    else
      @show_third_radio_button = false
    end

    @last_inspection = Inspection.where(item: @item).order(number: :desc).first
    @control2 = @item.group.type_of == "escala"
    if @control2
      @detail = LadderDetail.find_by(item_id: @item.id)
      @revision = LadderRevision.find_by(inspection_id: @inspection.id)
    else
      @detail = Detail.find_by(item_id: @item.id)
      @revision = Revision.find_by(inspection_id: @inspection.id)
    end

    @has_incomplete_revision_colors = @revision.revision_colors.exists?(color: false)

    @control = @inspection == @last_inspection
    @control3 = @item.identificador.include? "CAMBIAME"
    @report = Report.find_by(inspection: inspection)
    @inspections = Inspection.where("number > 0").order(number: :desc)





  end
  def new



    @inspection = Inspection.new

    authorize! @inspection
    @items = Item.all
    @item = Item.new
    @manual_action_name = "new"
    @back_path = request.referer || inspections_path
    @cot0 = Facturacion.find_by(number: 0)
  end

  def create
    ActiveRecord::Base.transaction do
      @manual_action_name = inspection_params[:manual_action_name]
      @inspection = Inspection.new(inspection_params.except(:identificador, :group_id, :principal_id, :manual_action_name))

      authorize! @inspection

      control = true
      item_params = inspection_params.slice(:identificador, :group_id, :principal_id)
      item_params[:identificador] = item_params[:identificador].gsub(/\s+/, "") if item_params[:identificador].present?

      if item_params[:group_id] == "bad"
        @inspection.errors.add(:base, "Seleccione un grupo")
        control = false
      end

      if item_params[:principal_id].blank? || !Principal.exists?(item_params[:principal_id])
        @inspection.errors.add(:base, "Seleccione una empresa")
        control = false
      else
        @principal = Principal.find(item_params[:principal_id])
      end

      if item_params[:identificador].blank?
        item_params[:identificador] = "CAMBIAME(Empresa: #{item_params[:principal_id]}. Lugar de inspección: #{@inspection.place} #{SecureRandom.hex(10)})"
      end

      if control == false
        @item = Item.new(item_params)
        render :new, status: :unprocessable_entity
        return
      else
        @item = Item.where(identificador: item_params[:identificador], principal_id: @principal.id).first_or_initialize
      end

      current_group = @item.group&.id.to_s
      current_group_name = @item.group&.name
      @item.assign_attributes(item_params)
      is_new_item = @item.new_record?

      if @item.new_record? && Item.exists?(identificador: item_params[:identificador])
        @inspection.errors.add(:base, "El activo con id #{item_params[:identificador]} pertenece a la empresa #{Item.find_by(identificador: item_params[:identificador]).principal.name}")
        render :new, status: :unprocessable_entity
        return
      end

      if !@item.new_record? && current_group != item_params[:group_id]
        @inspection.errors.add(:base, "Activo con identificador #{@item.identificador} pertenece a #{current_group_name}, seleccione el grupo correspondiente")
        render :new, status: :unprocessable_entity
        return
      end


      inspection_abierta = Inspection.where(item: @item, state: "abierto").order(id: :desc).first
      if inspection_abierta
        inspection_link = helpers.link_to("Inspección N°#{inspection_abierta.number}", inspection_path(inspection_abierta), style: "color: blue; text-decoration: underline;")
        @inspection.errors.add(:base, "Ya existe una inspección abierta para este activo: #{inspection_link}".html_safe)
        render :new, status: :unprocessable_entity
        return
      end



      @item.save!
      @inspection.item = @item
      puts(@inspection.inspect)
      @inspection.save!
      @report = Report.create!(inspection: @inspection, item: @inspection.item)
      if @item.group.type_of == "escala"
        @revision = LadderRevision.create!(inspection: @inspection, item: @inspection.item)
        numbers = [0,1,2,3,4,5,6,7,8,11, 12, 13, 14, 15]
        numbers.each do |number|
          @revision.revision_colors.create!(section: number, color: false)
        end
        @detail = LadderDetail.find_or_create_by(item: @item)

      elsif @item.group.type_of == "ascensor"
        @revision = Revision.create!(inspection: @inspection, item: @inspection.item, group: @inspection.item.group)
        (0..11).each do |index|
          @revision.revision_colors.create!(section: index, color: false)
        end
        @detail = Detail.find_or_create_by(item: @item)

      elsif @item.group.type_of == "libre"
        @revision = Revision.create!(inspection: @inspection, item: @inspection.item, group: @inspection.item.group)
        numbers = [0, 100]
        numbers.each do |number|
          @revision.revision_colors.create!(section: number, color: false)
        end
        if is_new_item
          @detail = Detail.create!(item: @item)
        end
      end
      flash[:notice] = "Inspección creada con éxito"
      redirect_to inspection_path(@inspection)
    end
  rescue ActiveRecord::RecordInvalid => e
    # Agregar los errores de validación al modelo
    @inspection.errors.add(:base, e.record.errors.full_messages.uniq.join(', '))
    render :new, status: :unprocessable_entity
  end



  def new_with_last
    @from_last_inspection = true
    last_inspection = Inspection.find(params[:id])

    @inspection = Inspection.new(
      place: last_inspection.place,
      validation: last_inspection.validation,
      ins_date: Date.today
    )

    @item = last_inspection.item
    @manual_action_name = "new_with_last"

    @cot0 = Facturacion.find_by(number: 0)
    render :new
  end

  def edit
    authorize! inspection
    #inspection_not_modifiable!(inspection)
    @manual_action_name = "edit"

    @items = Item.all
    @item = inspection.item
    @cot0 = Facturacion.find_by(number: 0)
  end







  def update_ending
    authorize! inspection
    ending = inspection_params[:ending]
    @report = Report.find_by(inspection: inspection)
    if @report.update(ending: ending)
      flash[:notice] = "Fecha de término de certificación actualizada"
      redirect_to @inspection
    else
      render @inspection, status: :unprocessable_entity
    end
  end

  def update_inf_date
    authorize! inspection
    inf_date = inspection_params[:inf_date]
    if @inspection.update(inf_date: inf_date)
      flash[:notice] = "Fecha de emisión de informe actualizada"
      redirect_to @inspection
    else
      render @inspection, status: :unprocessable_entity
    end
  end



  def update
    authorize! inspection
    @manual_action_name = inspection_params[:manual_action_name]

    black_number = inspection.number*-1

    # Intenta actualizar la inspección
    if @inspection.update(inspection_params.except(:manual_action_name))

      @black_inspection = Inspection.find_by(number: black_number)
      if @black_inspection
        @black_inspection.update(number: @inspection.number*-1)
      end
      flash[:notice] = "Inspección actualizada"
      redirect_to @inspection
    else
      # Si la actualización falla debido a errores de validación, renderiza el formulario con los errores
      flash.now[:alert] = @inspection.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end




  def destroy
    authorize! inspection
    black_inspection = Inspection.find_by(number: inspection.number*-1)

    inspections = inspection.item.inspections.where("number > 0").order(created_at: :desc)

    if inspections.second == inspection
      message = "No se puede eliminar ya que otra inspección podría hacer referencia a esta."
      respond_to do |format|
        format.html do
          flash[:alert] = message
          redirect_to inspections_path
        end
        format.json { render json: { error: message }, status: :unprocessable_entity }
      end
      return
    end

    black_inspection&.destroy
    inspection.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = "Inspección eliminada"
        redirect_to inspections_path, status: :see_other
      end
      format.json { render json: { message: "Inspección eliminada" }, status: :ok }
    end
  end


  def download_document

    inspection = Inspection.find(params[:id])
    authorize!

    inspection_id = inspection.id

    admin_id = params[:admin_id].presence || Current.user.id


    principal_id = inspection.item.principal_id
    item_id = inspection.item_id

    if inspection.inf_date.nil? && !Current.user.only_see
      inspection.update(inf_date: Time.zone.now.to_date)
    end

    if inspection.item.group.type_of == "escala"
      revision_id = LadderRevision.find_by(inspection_id: inspection.id).id
      new_doc_path = DocumentGeneratorLadder.generate_document(inspection_id, principal_id, revision_id, item_id, admin_id)
    elsif inspection.item.group.type_of == "ascensor"
      revision_id = Revision.find_by(inspection_id: inspection.id).id
      new_doc_path = DocumentGenerator.generate_document(inspection_id, principal_id, revision_id, item_id, admin_id)

      elsif inspection.item.group.type_of == "libre"
      revision_id = Revision.find_by(inspection_id: inspection.id).id
      new_doc_path = DocumentGeneratorLibre.generate_document(inspection_id, principal_id, revision_id, item_id, admin_id)
    end
    send_file new_doc_path, type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
              disposition: 'attachment',
              filename: File.basename(new_doc_path)
    DeleteTempFileJob.set(wait: 5.minutes).perform_later(new_doc_path.to_s)
  rescue StandardError => e
    flash[:alert] = "Error al generar el documento: #{e.message}"
    redirect_to inspection_path(inspection)
  end


  def close_inspection
    @inspection = Inspection.find(params[:id])
    authorize! @inspection
    if @inspection.item.group.type_of == "escala"
      @revision = LadderRevision.find_by(inspection_id: @inspection.id)
      isladder = true
      detail = @inspection.item.ladder_detail
    else
      @revision = Revision.find(params[:revision_id])
      isladder = false
      detail = @inspection.item.detail

    end

    report = inspection.report
    revision_nulls = @revision.revision_nulls
    if isladder == false && detail.sala_maquinas == "Responder más tarde"
      flash[:alert] = "No se puede cerrar la inspección, No se ha especificado presencia de sala de máquinas"
      redirect_to inspection_path(@inspection)
    else
      control1 = true
      control2 = true
      @revision.revision_colors.select(:section, :color).each do |color|
        if color.color == false
          if control1 == true
            control1 = false
          else
            control2 = false
          end
        end
      end
      if control2 == false
        flash[:alert] = "No se puede cerrar la inspección, No se han completado todos los controles de calidad"
        redirect_to inspection_path(@inspection)
      else
        revision_color_section_0 = @revision.revision_colors.find_by(section: 0)
        if isladder == false && !(revision_nulls.any? { |element| element.point&.start_with?('0.1.1_') } || revision_color_section_0&.codes&.first == '0.1.1') && (report.certificado_minvu == '' || report.certificado_minvu == nil || report.certificado_minvu == 'No' || report.certificado_minvu == 'no')
          flash[:alert] = "No se puede cerrar la inspección, No se ha ingresado certificado MINVU"
          redirect_to inspection_path(@inspection)
        else


          detail.attributes.each do |attr_name, value|
            if value.is_a?(String) && (value.nil? || value == "") && attr_name != "empresa_instaladora_rut"
              detail.update_attribute(attr_name, "S/I")
            end
          end
          report.attributes.each do |attr_name, value|
            if  value.is_a?(String) && (value.nil? || value == "")
              report.update_attribute(attr_name, "S/I")
            end
          end
          if @revision.revision_colors.any? { |rc| rc.levels.include?("G") }
            @inspection.update(result: "Rechazado")
          else
            @inspection.update(result: "Aprobado")
          end
          if @inspection.update(state: "Cerrado")
            flash[:notice] = "Inspección cerrada con éxito"
            redirect_to inspection_path(@inspection)
          else
            flash[:alert] = 'Hubo un error al cerrar la inspección'
            redirect_to inspection_path(@inspection)
          end
        end


      end

    end

  end

  def force_close_inspection
    authorize! inspection

    if @inspection.item.group.type_of == "escala"
      @revision = LadderRevision.find_by(inspection_id: @inspection.id)
      detail = @inspection.item.ladder_detail
    else
      @revision = Revision.find_by(inspection_id: @inspection.id)
      detail = @inspection.item.detail

    end

    report = inspection.report

    detail.attributes.each do |attr_name, value|
      if  value.is_a?(String) && (value.nil? || value == "") && attr_name != "empresa_instaladora_rut"
        detail.update_attribute(attr_name, "S/I")
      end
    end
    report.attributes.each do |attr_name, value|
      if  value.is_a?(String) && (value.nil? || value == "")
        report.update_attribute(attr_name, "S/I")
      end
    end
    if @revision.revision_colors.any? { |rc| rc.levels.include?("G") }
      @inspection.update(result: "Rechazado")
    else
      @inspection.update(result: "Aprobado")
    end
    if @inspection.update(state: "Cerrado")
      flash[:notice] = "Inspección cerrada con éxito"
      redirect_to inspection_path(@inspection)
    else
      flash[:alert] = 'Hubo un error al cerrar la inspección'
      redirect_to inspection_path(@inspection)
    end
  end





  def download_json
    authorize! inspection

    if @inspection.nil?
      flash[:alert] = "No se encontró la inspección para el activo"
      redirect_to(home_path)
      return
    end

    if @inspection.item.group.type_of == "escala"
      @revision_base = LadderRevision.find_by(inspection_id: @inspection.id)
    else
      @revision_base = Revision.find_by(inspection_id: @inspection.id)
    end


    if @revision_base.nil?
      flash[:alert] = "Checklist no disponible."
      redirect_to(home_path)
      return
    end


    @item = @revision_base.item
    @revision_photos = @revision_base.revision_photos

    @revision_photos_data = @revision_photos.map do |photo|
      if photo.photo.attached?
        {
          code: photo.code,
          photo: Base64.encode64(photo.photo.download)
        }
      else
        {
          code: photo.code,
          photo: nil
        }
      end
    end

    @report = Report.find_by(inspection: @inspection)
    if @report.cert_ant == "Si"
      @black_inspection = Inspection.find_by(number: @inspection.number*-1)
      if @black_inspection
        @black_revision_base = Revision.find_by(inspection_id: @black_inspection.id)
        @last_revision_base = nil
      end

    elsif @report.cert_ant == "sistema"
      @last_revision_base = Revision.where(item_id: @item.id).order(created_at: :desc).offset(1).first

    elsif @report.cert_ant == "No"
      @last_revision_base = nil

    else
      @last_revision_base = Revision.where(item_id: @item.id).order(created_at: :desc).offset(1).first
    end

    @group = @item.group


    if @group.type_of == "escala"
      @revision = OpenStruct.new(codes: [], points: [], levels: [], comment: [], number: [], priority: [])
    elsif @group.type_of == "ascensor"
      @revision = OpenStruct.new(codes: [], points: [], levels: [], comment: [])
    end



    @revision_base.revision_colors.order(:section).each do |revision_color|
      @revision.codes.concat(revision_color.codes || [])
      @revision.points.concat(revision_color.points || [])
      @revision.levels.concat(revision_color.levels || [])
      @revision.comment.concat(revision_color.comment || [])

      if @group.type_of == "escala"
        @revision.number.concat(revision_color.number || [])
        @revision.priority.concat(revision_color.priority || [])
      end

    end

    if @last_revision_base
      @last_revision_base_real = @last_revision_base
    elsif @black_revision_base
      @last_revision_base_real = @black_revision_base
    end

    if @last_revision_base_real

      if @group.type_of == "escala"
        @last_revision_real = OpenStruct.new(codes: [], points: [], levels: [], comment: [], number: [], priority: [])
      elsif @group.type_of == "ascensor"
        @last_revision_real = OpenStruct.new(codes: [], points: [], levels: [], comment: [])
      end

      @last_revision_base_real.revision_colors.order(:section).each do |revision_color|
        @last_revision_real.codes.concat(revision_color.codes || [])
        @last_revision_real.points.concat(revision_color.points || [])
        @last_revision_real.levels.concat(revision_color.levels || [])
        @last_revision_real.comment.concat(revision_color.comment || [])

        if @group.type_of == "escala"
          @last_revision_real.number.concat(revision_color.number || [])
          @last_revision_real.priority.concat(revision_color.priority || [])
        end

      end
    end



    if @group.type_of == "escala"
      @detail = LadderDetail.find_by(item_id: @item.id)
    elsif @group.type_of == "ascensor"
      @detail = Detail.find_by(item_id: @item.id)
    end

    @colors = @revision_base.revision_colors.select(:section, :color)

    json_data = {
      inspection: @inspection,
      revision: @revision,
      item: @item,
      revision_nulls: @revision_nulls,
      group: @group,
      detail: @detail,
      report: @report,
      colors: @colors,
      last_revision: @last_revision_real,
      revision_photos: @revision_photos_data
    }

    send_data json_data.to_json, filename: "inspection_#{params[:inspection_id]}.json", type: 'application/json'
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Error al guardar la inspección"
    redirect_to(home_path)
  end

  def download_images
    inspection = Inspection.find(params[:id])

    authorize! inspection

    # Determinar si es escala o ascensor
    if inspection.item.group.type_of == "escala"
      revision_base = LadderRevision.find_by(inspection_id: inspection.id)
    else
      revision_base = Revision.find_by(inspection_id: inspection.id)
    end

    # Obtener las fotos ordenadas por `revision_photo.code`
    revision_photos = revision_base.revision_photos.ordered_by_code
    item = inspection.item
    item_rol = item.identificador.chars.last(4).join

    if revision_photos.empty?
      flash[:alert] = "No se encontraron fotos para descargar."
      redirect_to inspection_path(inspection) and return
    end

    begin
      # Directorio temporal para guardar el archivo LaTeX y las imágenes
      latex_dir = Rails.root.join('tmp', 'latex')
      FileUtils.mkdir_p(latex_dir)

      # Generar un nombre base que incluye `inspection.number` y un sufijo aleatorio para garantizar la unicidad
      random_suffix = SecureRandom.hex(6)
      base_name = "#{inspection.number}_#{inspection.ins_date.strftime('%m')}_#{inspection.ins_date.strftime('%Y')}_#{item_rol}_#{random_suffix}"

      # Nombre del archivo LaTeX
      latex_file = File.join(latex_dir, "#{base_name}.tex")

      # Generar el contenido LaTeX dinámicamente basado en las imágenes y códigos
      latex_content = "\\documentclass{article}\n"
      latex_content += "\\usepackage{graphicx}\n"
      latex_content += "\\usepackage{geometry}\n"
      latex_content += "\\geometry{a4paper, margin=1in}\n"
      latex_content += "\\pagestyle{empty}\n" # Quitar el número de página
      latex_content += "\\renewcommand{\\figurename}{Imagen}\n"
      latex_content += "\\renewcommand{\\thefigure}{N°\\arabic{figure}}\n"
      latex_content += "\\begin{document}\n"

      revision_photos.each_slice(2) do |photos|
        latex_content += "\\begin{figure}[h!]\n"
        photos.each do |photo|
          # Descargar la imagen a un archivo temporal
          image_path = ActiveStorage::Blob.service.send(:path_for, photo.photo.key)
          image_destination = File.join(latex_dir, "#{base_name}_#{photo.id}.jpg")
          FileUtils.cp(image_path, image_destination)

          latex_content += "  \\begin{minipage}[b]{0.45\\textwidth}\n"
          latex_content += "    \\centering\n"
          latex_content += "    \\includegraphics[width=0.8\\textwidth, height=0.5\\textheight, keepaspectratio]{#{File.basename(image_destination)}}\n"
          latex_content += "    \\caption{#{photo.code}}\n"
          latex_content += "  \\end{minipage}\n"
          latex_content += "  \\hfill\n" if photos.size > 1
        end
        latex_content += "\\end{figure}\n"
      end

      latex_content += "\\end{document}\n"

      # Guardar el contenido en el archivo LaTeX
      File.open(latex_file, 'w') { |file| file.write(latex_content) }

      # Compilar el archivo LaTeX a PDF usando pdflatex
      Dir.chdir(latex_dir) do
        stdout, stderr, status = Open3.capture3("pdflatex #{File.basename(latex_file)}")
        unless status.success?
          raise "Error al compilar LaTeX: #{stderr}"
        end
      end

      # Definir la ruta del archivo PDF
      pdf_file = File.join(latex_dir, "#{base_name}.pdf")

      # Eliminar todos los archivos temporales excepto el PDF
      Dir.glob("#{latex_dir}/#{base_name}*").each do |file_path|
        File.delete(file_path) if File.exist?(file_path) && file_path != pdf_file
      end

      send_file pdf_file,
                type: 'application/pdf',
                filename: "#{inspection.number}_#{random_suffix}.pdf",
                disposition: 'attachment'

      DeleteTempFileJob.set(wait: 5.minutes).perform_later(pdf_file.to_s)

    rescue StandardError => e
      flash[:alert] = "Error al generar el documento PDF: #{e.message}"
      redirect_to inspection_path(inspection)
    end
  end


  def edit_informe
    @inspection = Inspection.find(params[:id])
    authorize! @inspection
  end

  def update_informe
    @inspection = Inspection.find(params[:id])
    authorize! @inspection

    if params[:inspection].nil? || params[:inspection][:informe].blank?
      flash.now[:alert] = "Debes seleccionar un archivo para subir."

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append('flash', partial: 'shared/flash') }
        format.html { render :edit_informe }
      end
      return
    end

    @inspection.informe.purge if @inspection.informe.attached?

    if @inspection.update(informe: params[:inspection][:informe])
      redirect_to @inspection, notice: "Informe actualizado exitosamente. Subido el #{Time.current.strftime('%d/%m/%Y %H:%M')}."
    else
      flash.now[:alert] = "Error al subir el informe."

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append('flash', partial: 'shared/flash') }
        format.html { render :edit_informe }
      end
    end
  end


  def download_informe

    @inspection = Inspection.find(params[:id])
    authorize! @inspection

    if @inspection.informe.attached?
      redirect_to rails_blob_path(@inspection.informe, disposition: "attachment")
    else
      redirect_to @inspection, alert: "No hay informe disponible para descargar."
    end
  end


  def export_xlsx
    @inspections = Inspection
                     .where("number > 0")
                     .includes(:item, :principal, :report, :users)
                     .order(number: :desc)

    puts("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
    puts(@inspections.inspect)

    Tempfile.create(['inspecciones', '.xlsx']) do |tmp|
      path = tmp.path
      tmp.close

      workbook  = WriteXLSX.new(path)
      sheet     = workbook.add_worksheet('Inspecciones')

      headers = [
        'N° Inspección', 'Nombre', 'Activo', 'Empresa', 'Rut empresa',
        'Fecha Inspección', 'Resultado', 'Tiempo en resultado actual',
        'Fecha término', 'Inspector asignado', 'Nombre contacto', 'email contacto', 'Teléfono contacto'
      ]
      sheet.write_row(0, 0, headers)

      Inspection
        .where('number > 0')
        .includes(:item, :principal, :report, :users)
        .order(number: :desc)
        .find_each
        .with_index(1) do |ins, row|
        sheet.write_row row, 0, [
          ins.number,
          ins.name,
          ins.item&.identificador,
          ins.item&.principal&.name,
          ins.principal&.rut,
          ins.ins_date&.strftime('%d-%m-%Y'),
          ins.result,
          ins.cambio ? "#{(Date.current - ins.cambio).to_i} días" : nil,
          ins.report&.ending&.strftime('%d-%m-%Y'),
          ins.users.present? ? ins.users.map(&:real_name).join(', ') : 'No asignado',
          ins.principal&.contact_name,
          ins.principal&.contact_email,
          ins.principal&.cellphone
        ]
      end

      workbook.close

      send_data File.binread(path),
                filename: "inspecciones_#{Time.zone.now.strftime('%Y%m%d_%H%M')}.xlsx",
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                disposition: :attachment

      DeleteTempFileJob.set(wait: 5.minutes).perform_later(path)
    end
  end


  def edit_massive_load
  end

  def update_massive_load
    if params[:file].nil?
      flash[:alert] = "No se seleccionó ningún archivo. Por favor, selecciona un archivo para cargar."
      redirect_to edit_massive_load_inspection_path
      return
    end

    begin
      # Llamada al servicio para procesar el archivo
      result = MassiveLoadService.process(params[:file].path)

      if result[:success]
        flash[:notice] = "Carga masiva completada con éxito: #{result[:message]}"
      else
        flash[:alert] = "Error en la carga masiva: #{result[:message]}"
      end
    rescue StandardError => e
      flash[:alert] = "Ocurrió un error inesperado: #{e.message}"
    end

    redirect_to inspections_path
  end


  def copy

    @inspection = Inspection.find(params[:id])
    authorize! @inspection
    @item = @inspection.item
    @report = Report.find_by(inspection: @inspection)
    if @inspection.item.group.type_of == "escala"
      @revision = LadderRevision.find_by(inspection_id: @inspection.id)
      @detail = LadderDetail.find_by(item_id: @item.id)
    elsif @inspection.item.group.type_of == "ascensor"
      @revision = Revision.find_by(inspection_id: @inspection.id)
      @detail = Detail.find_by(item_id: @item.id)
    end

    @anothers = @item.inspections.where.not(id: @inspection.id).order(number: :desc)





    @inspection_og = Inspection.find(params[:selected_inspection_id])
    @report_og = Report.find_by(inspection: @inspection_og)
    @item_og = @inspection_og.item
    if @inspection_og.item.group.type_of == "escala"
      @revision_og = LadderRevision.find_by(inspection_id: @inspection_og.id)
      @detail_og = LadderDetail.find_by(item_id: @item_og.id)
    elsif @inspection_og.item.group.type_of == "ascensor"
      @revision_og = Revision.find_by(inspection_id: @inspection_og.id)
      @detail_og = Detail.find_by(item_id: @item_og.id)
    end

    if @item.group.id != @item_og.group.id
      flash[:alert] = "No se puede copiar, los tipos de grupo son diferentes."
      redirect_to inspection_path(@inspection)
      return
    end

    if params[:selected_inspection_id].to_s == params[:id].to_s
      flash[:alert] = "No se puede copiar la misma inspección."
      redirect_to inspection_path(@inspection)
      return
    end

    @revision_colors_og = @revision_og.revision_colors.order(:section)
    @revision_nulls_og = @revision_og.revision_nulls
    @anothers_og = @item_og.anothers



    ActiveRecord::Base.transaction do


      @report.update!(
        fecha: @report_og.fecha,
        vi_co_man_ini: @report_og.vi_co_man_ini,
        vi_co_man_ter: @report_og.vi_co_man_ter,
        ul_reg_man: @report_og.ul_reg_man,
        urm_fecha: @report_og.urm_fecha,
        empresa_anterior: @report_og.empresa_anterior,
        ea_rol: @report_og.ea_rol,
        ea_rut: @report_og.ea_rut,
        empresa_mantenedora: @report_og.empresa_mantenedora,
        em_rol: @report_og.em_rol,
        em_rut: @report_og.em_rut,
        nom_tec_man: @report_og.nom_tec_man,
        tm_rut: @report_og.tm_rut,
      )

      # Copiar atributos de detalle
      @count_inspections = @item.inspections.where("number > 0").count
      if @detail && @detail_og && @count_inspections == 1
        detail_attributes = @detail_og.attributes.except("id", "item_id", "created_at", "updated_at")
        @detail.update!(detail_attributes)
      end


      @revision.revision_nulls.destroy_all
      @revision_nulls_og.each do |src|
        @revision.revision_nulls.create!(point: src.point, comment: src.comment)
      end


      @anothers_og.each do |src|
        @item.anothers.find_or_create_by(point: src.point, ruletype_id: src.ruletype_id, code: src.code, level: src.level, ins_type: src.ins_type, section: src.section)
      end


      @revision.revision_colors.destroy_all

      @revision_og.revision_colors.order(:section).each do |src|
        @revision.revision_colors.create!(section: src.section, color: false, codes: src.codes, points: src.points, levels: src.levels, comment: src.comment, number: src.number, priority: src.priority)

      end






    end


    @inspection.update(copia: true)


    @conexions = Conexion.where(copy_inspection_id: @inspection.id)
    if @conexions.any?
      @conexions.destroy_all
    end

    Conexion.create!(original_inspection: @inspection_og, copy_inspection: @inspection)






    respond_to do |format|
      format.html { redirect_to inspection_path(@inspection), notice: "Copiado correctamente." }
      format.json { render json: { ok: true } }
    end
  rescue => e
    respond_to do |format|
      format.html do
        flash[:alert] = "Error al copiar: #{e.message}"
        redirect_to inspection_path(@inspection)
      end
      format.json { render json: { ok: false, error: e.message }, status: :unprocessable_entity }
    end
  end

  def search_candidates
    @inspection = Inspection.find(params[:id])
    authorize! @inspection

    q         = params[:q].to_s.strip
    page      = [params[:page].to_i, 1].max
    per_page  = params[:per_page].present? ? params[:per_page].to_i.clamp(5, 100) : 20


    group_id = @inspection.item.group_id

    scope = Inspection
              .joins(item: :group)
              .where(groups: { id: group_id })
              .where.not(id: @inspection.id)
              .where("inspections.number > 0")

    if q.present?
      if q =~ /\A\d+\z/            # "1" => 1,10,11,12... (no 21,31,...)
        scope = scope.where("CAST(inspections.number AS CHAR) LIKE ?", "#{q}%")
      else
        scope = scope.where("inspections.name LIKE ?", "%#{q}%")
      end
    end

    total_count = scope.count
    results = scope
                .includes(:item)
                .order(number: :desc)
                .offset((page - 1) * per_page)
                .limit(per_page)

    payload = results.map do |i|
      {
        id: i.id,
        number: i.number,
        name: i.name,
        place: i.place,
        ins_date: i.ins_date&.strftime("%Y-%m-%d"),
        state: i.state,
        item_identificador: i.item&.identificador,
        group_id: i.item&.group&.id
      }
    end

    render json: {
      results: payload,
      meta: {
        page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: (total_count.to_f / per_page).ceil
      }
    }
  end


  # app/controllers/inspections_controller.rb
  def copy_preview
    @inspection = Inspection.find(params[:id])
    authorize! @inspection
    @item = @inspection.item
    @report = Report.find_by(inspection: @inspection)

    if @inspection.item.group.type_of == "escala"
      @revision = LadderRevision.find_by(inspection_id: @inspection.id)
      @detail   = LadderDetail.find_by(item_id: @item.id)
    else
      @revision = Revision.find_by(inspection_id: @inspection.id)
      @detail   = Detail.find_by(item_id: @item.id)
    end

    @inspection_og = Inspection.find(params[:selected_inspection_id])
    @report_og     = Report.find_by(inspection: @inspection_og)
    @item_og       = @inspection_og.item

    if @inspection_og.item.group.type_of == "escala"
      @revision_og = LadderRevision.find_by(inspection_id: @inspection_og.id)
      @detail_og   = LadderDetail.find_by(item_id: @item_og.id)
    else
      @revision_og = Revision.find_by(inspection_id: @inspection_og.id)
      @detail_og   = Detail.find_by(item_id: @item_og.id)
    end

    if @item.group.id != @item_og.group.id
      return render json: { error: "Los grupos son diferentes." }, status: :unprocessable_entity
    end

    if params[:selected_inspection_id].to_s == params[:id].to_s
      return render json: { error: "No se puede copiar la misma inspección." }, status: :unprocessable_entity
    end

    # Campos de reporte a comparar (estructura igual)
    report_fields = %i[
    fecha vi_co_man_ini vi_co_man_ter ul_reg_man urm_fecha empresa_anterior ea_rol ea_rut
    empresa_mantenedora em_rol em_rut nom_tec_man tm_rut
  ]

    report_changes = []
    if @report && @report_og
      report_fields.each do |f|
        current = @report.send(f)
        source  = @report_og.send(f)
        report_changes << { field: f.to_s, current: current, source: source, will_update: (current != source) }
      end
    end

    # Detalle: comparar atributo a atributo si aplica la copia (tu regla original)
    count_inspections = @item.inspections.where("number > 0").count
    will_copy_detail  = (@detail && @detail_og && count_inspections == 1)

    detail_changes = []
    if will_copy_detail
      # mismos campos en ambas clases de detail (estructura "igual"; si algún campo no existe, rescue)
      src_attrs  = @detail_og.attributes.except("id","item_id","created_at","updated_at")
      src_attrs.each do |k, src_v|
        cur_v = @detail.respond_to?(k) ? @detail.send(k) : nil
        detail_changes << { field: k, current: cur_v, source: src_v, will_update: (cur_v != src_v) }
      end
    end

    # Nulls/Colors/Anothers: lista completa de lo que se destruye/crea
    revision_nulls_current = (@revision&.revision_nulls || [])
    revision_nulls_source  = (@revision_og&.revision_nulls || [])

    revision_colors_current = (@revision&.revision_colors&.order(:section) || [])
    revision_colors_source  = (@revision_og&.revision_colors&.order(:section) || [])

    anothers_current = @item.respond_to?(:anothers)   ? @item.anothers : []
    anothers_source  = @item_og.respond_to?(:anothers)? @item_og.anothers : []

    # Para 'anothers' indicamos cuáles se crearían (clave compuesta)
    existing_keys = anothers_current.map { |a| [a.point, a.ruletype_id, a.code, a.level, a.ins_type, a.section] }
    anothers_to_create = anothers_source.map { |s| [s.point, s.ruletype_id, s.code, s.level, s.ins_type, s.section] } - existing_keys

    current_snapshot = {
      inspection: { id: @inspection.id, number: @inspection.number, name: @inspection.name,
                    item_id: @inspection.item_id, group_id: @inspection.item&.group&.id },
      report: @report&.slice(*report_fields),
      detail: will_copy_detail ? @detail&.attributes&.except("id","item_id","created_at","updated_at") : nil,
      revision_nulls: revision_nulls_current.map { |n| { point: n.point, comment: n.comment } },
      revision_colors: revision_colors_current.map { |c| { section: c.section, color: c.color, codes: c.codes, points: c.points, levels: c.levels, comment: c.comment, number: c.number, priority: c.priority } },
      anothers: anothers_current.map { |a| { point: a.point, ruletype_id: a.ruletype_id, code: a.code, level: a.level, ins_type: a.ins_type, section: a.section } }
    }

    source_snapshot = {
      inspection: { id: @inspection_og.id, number: @inspection_og.number, name: @inspection_og.name,
                    item_id: @inspection_og.item_id, group_id: @inspection_og.item&.group&.id },
      report: @report_og&.slice(*report_fields),
      detail: will_copy_detail ? @detail_og&.attributes&.except("id","item_id","created_at","updated_at") : nil,
      revision_nulls: revision_nulls_source.map { |n| { point: n.point, comment: n.comment } },
      revision_colors: revision_colors_source.map { |c| { section: c.section, color: c.color, codes: c.codes, points: c.points, levels: c.levels, comment: c.comment, number: c.number, priority: c.priority } },
      anothers: anothers_source.map { |a| { point: a.point, ruletype_id: a.ruletype_id, code: a.code, level: a.level, ins_type: a.ins_type, section: a.section } }
    }

    # Resumen detallado (no “columnas”, sino info completa)
    summary = {
      report: report_changes,
      detail: detail_changes,
      revision_nulls: {
        current: current_snapshot[:revision_nulls],
        source:  source_snapshot[:revision_nulls]
      },
      revision_colors: {
        current: current_snapshot[:revision_colors],
        source:  source_snapshot[:revision_colors]
      },
      anothers: {
        current: current_snapshot[:anothers],
        source:  source_snapshot[:anothers],
        will_create: anothers_to_create.map { |p, rt, code, lvl, it, sec| { point: p, ruletype_id: rt, code: code, level: lvl, ins_type: it, section: sec } }
      }
    }

    render json: {
      summary: summary,
      current_snapshot: current_snapshot,
      source_snapshot: source_snapshot
    }
  end




  private
  def inspection_params
    params.require(:inspection).permit(:place, :ins_date, :validation, :manual_action_name, :inf_date, :ending, :identificador, :comuna, :region, :principal_name, :name, :number, :rerun, :group_id, :principal_id, :facturacion_id, user_ids: [])

  end
  #indices para ordenar
  def inspection_params_index
    params.permit(:number, :query_text, :user_id, :q)
  end

  def inspection
    @inspection = Inspection.find(params[:id])
  end

  def informe_params
    params.require(:inspection).permit(:informe, :dummy_field)
  end



  def convert_docx_to_pdf(file_path)

    pdf_output = Tempfile.new(["informe", ".pdf"])
    system("pandoc", file_path, "-o", pdf_output.path)
    pdf_content = File.read(pdf_output.path)
    pdf_output.close
    pdf_output.unlink
    pdf_content
  end


end
