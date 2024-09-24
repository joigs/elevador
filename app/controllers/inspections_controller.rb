class InspectionsController < ApplicationController
  require "ostruct"

  def index
    @q = Inspection.ransack(params[:q])
    @inspections = @q.result(distinct: true).where("number > 0").includes(:item, :principal, :report).order(number: :desc)
    if Current.user.tabla
      @pagy, @inspections = pagy(@inspections, items: 10) # Paginación tradicional para la tabla
    else
      @pagy, @inspections = pagy_countless(@inspections, items: 10) # Paginación infinita para las tarjetas
    end

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
    @control = @inspection == @last_inspection
    @control3 = @item.identificador.include? "CAMBIAME"
    @report = Report.find_by(inspection: inspection)
  end
  def new



    @inspection = Inspection.new

    authorize! @inspection
    @items = Item.all
    @item = Item.new
    @manual_action_name = "new"
    @back_path = request.referer || inspections_path

  end

  def create
    ActiveRecord::Base.transaction do
      @manual_action_name = inspection_params[:manual_action_name]
      @inspection = Inspection.new(inspection_params.except(:identificador, :group_id, :principal_id, :manual_action_name))

      authorize! @inspection

      control = true
      item_params = inspection_params.slice(:identificador, :group_id, :principal_id)
      item_params[:identificador] = item_params[:identificador].gsub(/\s+/, "") if item_params[:identificador].present?

      # Agrega errores al objeto @inspection en lugar de flash.now
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
      @item.assign_attributes(item_params)
      is_new_item = @item.new_record?

      if @item.new_record? && Item.exists?(identificador: item_params[:identificador])
        @inspection.errors.add(:base, "El activo con id #{item_params[:identificador]} pertenece a la empresa #{Item.find_by(identificador: item_params[:identificador]).principal.name}")
        render :new, status: :unprocessable_entity
        return
      end

      if !@item.new_record? && current_group != item_params[:group_id]
        @inspection.errors.add(:base, "Activo con identificador #{@item.identificador} pertenece a #{@item.group.name}, seleccione el grupo correspondiente")
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
          @revision.revision_colors.create!(section: number, color: false)
        end
        if is_new_item
          @detail = LadderDetail.create!(item: @item)
        end
      elsif @item.group.type_of == "ascensor"
        @revision = Revision.create!(inspection: @inspection, item: @inspection.item, group: @inspection.item.group)
        (0..11).each do |index|
          @revision.revision_colors.create!(section: index, color: false)
        end
        if is_new_item
          @detail = Detail.create!(item: @item)
        end
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
      ins_date: Date.today # Establecer la fecha de inspección como la fecha actual o la que desees
    )

    @item = last_inspection.item
    @manual_action_name = "new_with_last"


    render :new
  end

  def edit
    authorize! inspection
    #inspection_not_modifiable!(inspection)
    @manual_action_name = "edit"

    @items = Item.all
    @item = inspection.item
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

    # Intenta actualizar la inspección
    if @inspection.update(inspection_params.except(:manual_action_name))
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
    if black_inspection
      black_inspection.destroy
    end

    inspection.destroy
    flash[:notice] = "Inspección eliminada"
    respond_to do |format|
      format.html { redirect_to inspections_path, status: :see_other }
      format.turbo_stream { head :no_content }
    end
  end



  def download_document

    inspection = Inspection.find(params[:id])

    inspection_id = inspection.id
    admin_id = Current.user.id

    principal_id = inspection.item.principal_id
    item_id = inspection.item_id

    if inspection.inf_date.nil?
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


    send_file new_doc_path, type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', disposition: 'attachment', filename: File.basename(new_doc_path)
  rescue StandardError => e
    flash[:alert] = "Error al generar el documento: #{e.message}"
    redirect_to inspection_path(inspection)
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
            flash[:alert] = 'Hubo un error al enviar la inspección'
            redirect_to inspection_path(@inspection)
          end
        end


      end

    end

  end





  def download_json
    authorize! inspection

    if @inspection.nil?
      flash[:alert] = "No se encontró la inspección para el activo"
      redirect_to(home_path)
      return
    end

    @revision = Revision.find_by(inspection_id: @inspection.id)
    if @revision.nil?
      flash[:alert] = "Checklist no disponible."
      redirect_to(home_path)
      return
    end

    @revision_base = Revision.find_by(inspection_id: @inspection.id)
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


  private
  def inspection_params
    params.require(:inspection).permit(:place, :ins_date, :validation, :manual_action_name, :inf_date, :ending, :identificador, :group_id, :principal_id, user_ids: [])

  end
  #indices para ordenar
  def inspection_params_index
    params.permit(:number, :query_text, :user_id, :q)
  end

  def inspection
    @inspection = Inspection.find(params[:id])
  end

end
