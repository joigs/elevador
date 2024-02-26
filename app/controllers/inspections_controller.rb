class InspectionsController < ApplicationController

  def index
    @inspections = Inspection.order(number: :desc)
    @pagy, @inspections = pagy_countless(FindInspections.new.call(inspection_params_index), items: 10  )

  end
  def show
    inspection
    @detail = Detail.find_by(item_id: inspection.item_id)
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


      @principal = Principal.find(item_params[:principal_id])

      @item = Item.where(identificador: item_params[:identificador], principal_id: @principal.id).first_or_initialize



      current_group = @item.group.id.to_s

      @item.assign_attributes(item_params)
      is_new_item = @item.new_record?




      if @item.new_record? && Item.exists?(identificador: item_params[:identificador])
        flash.now[:alert] = 'Activo pertenece a otra empresa'
        render :new, status: :unprocessable_entity
        return
      end


      if !@item.new_record? && current_group != item_params[:group_id]
        flash.now[:alert] = 'Activo pertenece a otro grupo, seleccione el grupo correspondiente'
        render :new, status: :unprocessable_entity
        return
      end

      @item.save!

      @inspection.item = @item

      if is_new_item
        @detail = Detail.create!(item: @item)
      end

      @inspection.save!
      @report = Report.create!(inspection: @inspection, item: @inspection.item)
      @revision = Revision.create!(inspection: @inspection, item: @inspection.item, group: @inspection.item.group)



      redirect_to inspection_path(@inspection), notice: 'Inspección creada con éxito'
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.join(', ')
    render :new, status: :unprocessable_entity
  end

  def edit
    authorize! inspection
    @items = Item.all
    @item = inspection.item
  end

  def update
    authorize! inspection

    ActiveRecord::Base.transaction do
      item_params = inspection_params[:item_attributes]
      current_item = @inspection.item

      if item_params[:principal_id].blank? || !Principal.exists?(item_params[:principal_id])
        @inspection.errors.add(:base, 'Ingrese una empresa')
        render :new, status: :unprocessable_entity
        return
      end


      @principal = Principal.find(item_params[:principal_id])

      new_item = Item.find_or_initialize_by(identificador: item_params[:identificador], principal_id: @principal.id)
      is_new_item = new_item.new_record?

      if !is_new_item && new_item.group_id.to_s != item_params[:group_id]
        flash.now[:alert] = 'Activo pertenece a otro grupo, seleccione el grupo correspondiente'
        render :edit, status: :unprocessable_entity
        return
      end

      if item_params[:identificador] != current_item.identificador


        if is_new_item && Item.exists?(identificador: item_params[:identificador])
          flash.now[:alert] =  'Activo pertenece a otra empresa'
          render :edit, status: :unprocessable_entity
          return
        end
        new_item.assign_attributes(item_params)
        new_item.save!

        if is_new_item
          Detail.create!(item: new_item)
        end

        @inspection.item = new_item
      end

      if @inspection.update(inspection_params.except(:item_attributes))
        @report = Report.find_or_initialize_by(inspection: @inspection)
        @report.update(item: @inspection.item)

        @revision = Revision.find_or_initialize_by(inspection: @inspection)
        @revision.update(item: @inspection.item, group: @inspection.item.group)


        redirect_to inspection_path(@inspection), notice: 'Inspección actualizada'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.join(', ')
    render :edit, status: :unprocessable_entity
  end



  def destroy
    authorize! inspection
    inspection.destroy
    redirect_to inspections_path, notice: 'Inspección eliminada', status: :see_other
  end



  def download_document
    inspection = Inspection.find(params[:id])
    inspection.update(inf_date: Time.zone.now.to_date)
    inspection_id = inspection.id
    principal_id = inspection.item.principal_id
    revision_id = Revision.find_by(inspection_id: inspection.id).id
    item_id = inspection.item_id
    admin_id = Current.user.id
    new_doc_path = DocumentGenerator.generate_document(inspection_id, principal_id, revision_id, item_id, admin_id)

    send_file new_doc_path, type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', disposition: 'attachment', filename: File.basename(new_doc_path)
  rescue StandardError => e
    redirect_to inspection_path(inspection), alert: "Error al generar el documento: #{e.message}"
  end

  def close_inspection
    @inspection = Inspection.find(params[:id])
    @revision = Revision.find(params[:revision_id])
    detail = @inspection.item.detail
    report = inspection.report
    if @inspection.item.detail.sala_maquinas == "Responder más tarde"
      redirect_to inspection_path(@inspection), alert: 'No se puede cerrar la inspección, No se ha especificado presencia de sala de máquinas'
    else
      detail.attributes.each do |attr_name, value|
        if  value.is_a?(String) && (value.nil? or value == "")
          detail.update_attribute(attr_name, "S/I")
        end
      end
      report.attributes.each do |attr_name, value|
        if  value.is_a?(String) && (value.nil? or value == "")
          report.update_attribute(attr_name, "S/I")
        end
      end
      if @revision.levels.include?("G")
        @inspection.update(result: "Rechazado")
      else
        @inspection.update(result: "Aprobado")
      end
      if @inspection.update(state: "Cerrado")

        redirect_to inspection_path(@inspection), notice: 'Inspección enviada con exito'
      else
        redirect_to inspection_path(@inspection), alert: 'Hubo un error al enviar la inspección'
      end
    end

  end




  private
  def inspection_params
    params.require(:inspection).permit(:number, :place, :validation, :ins_date, :user_id, item_attributes: [:id, :identificador, :group_id, :principal_id]).tap do |whitelisted|
      if whitelisted[:item_attributes] && whitelisted[:item_attributes][:identificador]
        # Remove all blank spaces from the identificador
        whitelisted[:item_attributes][:identificador].gsub!(/\s+/, "")
      end
    end
  end
  #indices para ordenar
  def inspection_params_index
    params.permit(:number, :query_text, :user_id)
  end

  def inspection
    @inspection = Inspection.find(params[:id])
  end

end
