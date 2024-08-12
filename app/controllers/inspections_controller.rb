class InspectionsController < ApplicationController
  require 'fileutils'
  require 'open3'

  def index
    @q = Inspection.ransack(params[:q])
    @inspections = @q.result(distinct: true).where("number > 0").includes(:item, :principal).order(number: :desc)
    @pagy, @inspections = pagy_countless(@inspections, items: 10)
  end
  def show
    inspection
    @item = inspection.item
    @last_inspection = Inspection.where(item: @item).order(created_at: :desc).first
    @control2 =  @item.group == Group.where("name LIKE ?", "%Escala%").first
    if @control2
      @detail = LadderDetail.find_by(item_id: @item.id)
    else
      @detail = Detail.find_by(item_id: @item.id)
    end
    @control = @inspection == Inspection.where(item: @item).order(created_at: :desc).first
    @control3 = @item.identificador.include? "CAMBIAME"
    @report = Report.find_by(inspection: inspection)
  end
  def new
    @inspection = Inspection.new
    @inspection.build_item
    @items = Item.all
  end

  def create
    ActiveRecord::Base.transaction do
      @inspection = Inspection.new(inspection_params.except(:item_attributes))

      item_params = inspection_params[:item_attributes]

      if item_params[:principal_id].blank? || !Principal.exists?(item_params[:principal_id])
        @inspection.errors.add(:base, 'Ingrese una empresa')
        render :new, status: :unprocessable_entity
        return
      end

      if item_params[:identificador].blank?
        item_params[:identificador] = "CAMBIAME(Empresa: #{item_params[:principal_id]}. Lugar de inspeccion: #{@inspection.place} #{SecureRandom.hex(10)})"
      end


      @principal = Principal.find(item_params[:principal_id])

      @item = Item.where(identificador: item_params[:identificador], principal_id: @principal.id).first_or_initialize


      current_group = @item.group&.id.to_s

      @item.assign_attributes(item_params)
      is_new_item = @item.new_record?




      if @item.new_record? && Item.exists?(identificador: item_params[:identificador])
        flash.now[:alert] = "El activo con id #{item_params[:identificador]} pertenece a la empresa #{Item.find_by(identificador: item_params[:identificador]).principal.name}"
        render :new, status: :unprocessable_entity
        return
      end


      if !@item.new_record? && current_group != item_params[:group_id]
        flash.now[:alert] = "Activo con identificador #{@item.identificador} pertenece a #{@item.group.name}, seleccione el grupo correspondiente"
        render :new, status: :unprocessable_entity
        return
      end

      @item.save!

      @inspection.item = @item



      @inspection.save!
      @report = Report.create!(inspection: @inspection, item: @inspection.item)

      if @item.group.type_of == "escala"
        @revision = LadderRevision.create!(inspection: @inspection, item: @inspection.item)
        numbers = [0,1,2,3,4,5,6,7,8,11, 12, 13, 14, 15]
        numbers.each do |number|
          @revision.revision_colors.create!(number: number, color: false)
        end
        if is_new_item
          @detail = LadderDetail.create!(item: @item)
        end
      elsif @item.group.type_of == "ascensor"
        @revision = Revision.create!(inspection: @inspection, item: @inspection.item, group: @inspection.item.group)
        (0..11).each do |index|
          @revision.revision_colors.create!(number: index, color: false)
        end
        if is_new_item
          @detail = Detail.create!(item: @item)
        end
      elsif @item.group.type_of == "libre"
        @revision = Revision.create!(inspection: @inspection, item: @inspection.item, group: @inspection.item.group)
        numbers = [0, 100]
        numbers.each do |number|
          @revision.revision_colors.create!(number: number, color: false)
        end
        if is_new_item
          @detail = Detail.create!(item: @item)
        end
      end




      redirect_to inspection_path(@inspection), notice: 'Inspección creada con éxito'
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.join(', ')
    render :new, status: :unprocessable_entity
  end



  def new_with_last
    @from_last_inspection = true
    last_inspection = Inspection.order(created_at: :desc).find_by(params[:inspection_id])
    @inspection = Inspection.new(
      place: last_inspection.place,
      validation: last_inspection.validation
    )

    if last_inspection.item
      @inspection.build_item(
        identificador: last_inspection.item.identificador,
        group_id: last_inspection.item.group_id,
        principal_id: last_inspection.item.principal_id
      )
    end

    render :new
  end

  def edit
    authorize! inspection
    #inspection_not_modifiable!(inspection)

    @items = Item.all
    @item = inspection.item
  end







  def update_ending
    authorize! inspection
    ending = inspection_params[:ending]
    @report = Report.find_by(inspection: inspection)
    if @report.update(ending: ending)
      redirect_to @inspection, notice: 'Fecha de vigencia de certificación actualizada'
    else
      render @inspection, status: :unprocessable_entity
    end
  end




  def update
    authorize! inspection

    if @inspection.update(inspection_params)


      redirect_to @inspection, notice: 'Inspección actualizada con éxito.'
    else
      render :edit
    end
  end



  def destroy
    authorize! inspection
    black_inspection = Inspection.find_by(number: inspection.number*-1)
    if black_inspection
      black_inspection.destroy
    end

    inspection.destroy
    redirect_to inspections_path, notice: 'Inspección eliminada', status: :see_other
  end



  def download_document

    inspection = Inspection.find(params[:id])

    inspection_id = inspection.id
    admin_id = Current.user.id
=begin
    if inspection.users.any? { |user| user.signature.blank? } || Current.user.signature.blank?
      redirect_to inspection_path(inspection), alert: 'Falta firma del inspector o del administrador'
      return
    end
=end
    principal_id = inspection.item.principal_id
    item_id = inspection.item_id

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


    send_file new_doc_path, type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', disposition: 'attachment', filename: File.basename(new_doc_path)
  rescue StandardError => e
    redirect_to inspection_path(inspection), alert: "Error al generar el documento: #{e.message}"
  end

  def close_inspection
    @inspection = Inspection.find(params[:id])
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
      redirect_to inspection_path(@inspection), alert: 'No se puede cerrar la inspección, No se ha especificado presencia de sala de máquinas'
    else
      control1 = true
      control2 = true
      @revision.revision_colors.each do |color|
        if color.color == false
          if control1 == true
            control1 = false
          else
            control2 = false
          end
        end
      end
      if control2 == false
        redirect_to inspection_path(@inspection), alert: 'No se puede cerrar la inspección, No se han completado todos los controles de calidad'
      else

        if isladder == false && !(revision_nulls.any? { |element| element.point&.start_with?('0.1.1_') } || @revision.codes[0]=='0.1.1') && (report.certificado_minvu == '' || report.certificado_minvu == nil || report.certificado_minvu == 'No' || report.certificado_minvu == 'no')
          redirect_to inspection_path(@inspection), alert: 'Se ingresó que no hay certificado MINVU, pero en la checklist se ingresó que si hay'
        else


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
          if @revision.levels.include?("G")
            @inspection.update(result: "Rechazado")
          else
            @inspection.update(result: "Aprobado")
          end
          if @inspection.update(state: "Cerrado", inf_date: Time.zone.now.to_date)
            redirect_to inspection_path(@inspection), notice: 'Inspección enviada con exito'
          else
            redirect_to inspection_path(@inspection), alert: 'Hubo un error al enviar la inspección'
          end
        end


      end

    end

  end




  def download_json
    # Autorización y selección de la revisión
    authorize! inspection

    if inspection.item.group.type_of == "escala"
      revision = LadderRevision.find_by(inspection_id: inspection.id)
    else
      revision = Revision.find_by(inspection_id: inspection.id)
    end

    # Obtener las fotos ordenadas por `revision_photo.code`
    revision_photos = revision.revision_photos.ordered_by_code

    # Directorio temporal para guardar el archivo LaTeX y las imágenes
    latex_dir = Rails.root.join('tmp', 'latex')
    FileUtils.mkdir_p(latex_dir)

    # Nombre del archivo LaTeX
    latex_file = File.join(latex_dir, 'document.tex')

    # Generar el contenido LaTeX dinámicamente basado en las imágenes y códigos
    latex_content = "\\documentclass{article}\n"
    latex_content += "\\usepackage{graphicx}\n"
    latex_content += "\\usepackage{geometry}\n"
    latex_content += "\\geometry{a4paper, margin=1in}\n"
    latex_content += "\\pagestyle{empty}\n" # Quitar el número de página
    latex_content += "\\renewcommand{\\figurename}{Imagen}\n" # Cambiar "Figure" por "Imagen"
    latex_content += "\\renewcommand{\\thefigure}{N°\\arabic{figure}}\n" # Cambiar el formato a "N°"
    latex_content += "\\begin{document}\n"

    revision_photos.each_slice(2) do |photos|
      latex_content += "\\begin{figure}[h!]\n"
      photos.each do |photo|
        image_path = ActiveStorage::Blob.service.path_for(photo.photo.key)
        FileUtils.cp(image_path, File.join(latex_dir, "#{photo.id}.jpg"))

        latex_content += "  \\begin{minipage}[b]{0.45\\textwidth}\n"
        latex_content += "    \\centering\n"
        latex_content += "    \\includegraphics[width=\\textwidth]{#{photo.id}.jpg}\n"
        latex_content += "    \\caption{#{photo.code}}\n" # Mostrar "Imagen N°<número>: <código>"
        latex_content += "  \\end{minipage}\n"
        latex_content += "  \\hfill\n" if photos.size > 1
      end
      latex_content += "\\end{figure}\n"
    end

    latex_content += "\\end{document}\n"

    # Guardar el contenido en el archivo LaTeX
    File.open(latex_file, 'w') { |file| file.write(latex_content) }

    # Compilar el archivo LaTeX a PDF usando el comando pdflatex
    Dir.chdir(latex_dir) do
      stdout, stderr, status = Open3.capture3("pdflatex document.tex")
      unless status.success?
        render plain: "Error al compilar LaTeX: #{stderr}", status: :internal_server_error
        return
      end
    end

    # Convertir PDF a imágenes (una por página)
    pdf_file = File.join(latex_dir, 'document.pdf')
    image_output_base = File.join(latex_dir, 'page')
    stdout, stderr, status = Open3.capture3("pdftoppm -png #{pdf_file} #{image_output_base}")
    unless status.success?
      render plain: "Error al convertir PDF a imágenes: #{stderr}", status: :internal_server_error
      return
    end

    # Enviar el archivo PDF como descarga
    send_file(pdf_file, filename: "document.pdf", type: "application/pdf")
  end

  private
  def inspection_params
    params.require(:inspection).permit(:number, :place, :validation, :ins_date, :ending, user_ids: [], item_attributes: [:id, :identificador, :group_id, :principal_id]).tap do |whitelisted|
      if whitelisted[:item_attributes] && whitelisted[:item_attributes][:identificador]
        whitelisted[:item_attributes][:identificador].gsub!(/\s+/, "")
      end
    end
  end
  #indices para ordenar
  def inspection_params_index
    params.permit(:number, :query_text, :user_id, :q)
  end

  def inspection
    @inspection = Inspection.find(params[:id])
  end

end
