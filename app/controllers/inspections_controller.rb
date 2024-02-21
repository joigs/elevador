class InspectionsController < ApplicationController

  def index
    @inspections = Inspection.order(state: :asc)
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

      @item.assign_attributes(item_params)
      is_new_item = @item.new_record?

      if @item.new_record? && Item.exists?(identificador: item_params[:identificador])
        flash.now[:alert] = 'Activo pertenece a otra empresa'
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

      #Bag.create!(number: (1..11).to_a, revision_id: @revision.id)


      redirect_to inspection_path(@inspection), notice: 'Inspección creada con éxito'
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.join(', ')
    render :new, status: :unprocessable_entity
  end

  def edit
    authorize! inspection
    @items = Item.all
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

      if item_params[:identificador] != current_item.identificador
        new_item = Item.where(identificador: item_params[:identificador], principal_id: @principal.id).first_or_initialize
        is_new_item = new_item.new_record?

        if new_item.new_record? && Item.exists?(identificador: item_params[:identificador])
          flash.now[:alert] =  'Activo pertenece a otra empresa'
          render :edit, status: :unprocessable_entity
          return
        end

        new_item.assign_attributes(item_params)
        new_item.save!

        Detail.create!(item: new_item) if is_new_item
        @inspection.item = new_item
      end

      if @inspection.update(inspection_params.except(:item_attributes))
        @report = Report.find_or_initialize_by(inspection: @inspection)
        @report.update(item: @inspection.item)

        @revision = Revision.find_or_initialize_by(inspection: @inspection)
        @revision.update(item: @inspection.item, group: @inspection.item.group)

        #bag = Bag.find_or_initialize_by(revision_id: @revision.id)
        # bag.number = (1..11).to_a
        # bag.save!

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




  private
  def inspection_params
    params.require(:inspection).permit(:number, :place, :validation, :ins_date, :user_id, item_attributes: [:identificador, :group_id, :principal_id])
  end

  #indices para ordenar
  def inspection_params_index
    params.permit(:number, :query_text, :user_id)
  end

  def inspection
    @inspection = Inspection.find(params[:id])
  end

end
