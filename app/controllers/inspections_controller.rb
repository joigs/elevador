class InspectionsController < ApplicationController

  def index
    @inspections = Inspection.order(state: :asc)
    @pagy, @inspections = pagy_countless(FindInspections.new.call(inspection_params_index), items: 10  )

  end
  def show
    inspection
  end
  def new
    @inspection = Inspection.new
    @inspection.build_item  # build an item for the inspection
    @items = Item.all
  end

  def create
    ActiveRecord::Base.transaction do
      @items = Item.all
      @inspection = Inspection.new(inspection_params.except(:item_attributes))

      item_params = inspection_params[:item_attributes]
      @item = Item.find_or_initialize_by(identificador: item_params[:identificador])

      @item.assign_attributes(item_params)
      is_new_item = @item.new_record?

      @item.save!
      @inspection.item = @item

      if is_new_item
        @detail = Detail.create!(item: @item)
      end

      @inspection.save!
      @report = Report.create!(inspection: @inspection, item: @inspection.item)
      @revision = Revision.create!(inspection: @inspection, item: @inspection.item, group: @inspection.item.group)

      redirect_to inspection_path(@inspection), notice: 'Nueva inspección creada'
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

      if item_params[:identificador] != current_item.identificador
        # Find or initialize a new item with the new identificador
        new_item = Item.find_or_initialize_by(identificador: item_params[:identificador])
        is_new_item = new_item.new_record?

        # Assign attributes and save the new item
        new_item.assign_attributes(item_params)
        new_item.save!

        # Create Detail if it's a new item
        Detail.create!(item: new_item) if is_new_item

        # Update the inspection's item to the new item
        @inspection.item = new_item
      end

      # Proceed with updating the inspection and its associations
      if @inspection.update(inspection_params.except(:item_attributes))
        # Update or create associated Report and Revision
        @report = Report.find_by(inspection: @inspection)
        @report.update(item: @inspection.item)

        @revision = Revision.find_by(inspection: @inspection)
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

  private
  def inspection_params
    params.require(:inspection).permit(:number, :place, :validation, :ins_date, :user_id, item_attributes: [:identificador, :group_id, :principal_id])
  end

  #indices para ordenar
  def inspection_params_index
    params.permit(:number, :user_id)
  end

  def inspection
    @inspection = Inspection.find(params[:id])
  end

end
