class InspectionsController < ApplicationController

  def index
    @inspections = Inspection.order(state: :asc)
    @pagy, @inspections = pagy_countless(FindInspections.new.call(inspection_params_index), items: 4)

  end
  def show
    inspection
  end
  def new
    @inspection = Inspection.new
    @inspection.build_item  # build an item for the inspection

  end

  def create
    ActiveRecord::Base.transaction do
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

      if is_new_item
        redirect_to edit_detail_path(@detail), notice: 'Nueva inspección creada, por favor añada detalles para el nuevo activo'
      else
        redirect_to edit_report_path(@report), notice: 'Nueva inspección creada, puede añadir información adicional para el informe'
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.join(', ')
    render :new, status: :unprocessable_entity
  end

  def edit
    authorize! inspection
    inspection
  end

  def update
    authorize! inspection
    if inspection.update(inspection_params)
      redirect_to inspections_path, notice: 'Inspección actualizada'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! inspection
    inspection.destroy
    redirect_to inspections_path, notice: 'Inspección eliminada', status: :see_other
  end

  private
  def inspection_params
    params.require(:inspection).permit(:number, :place, :validation, :ins_date, :user_id, item_attributes: [:identificador, :group_id, :principal_id, :minor_id])
  end

  #indices para ordenar
  def inspection_params_index
    params.permit(:user_id)
  end

  def inspection
    @inspection = Inspection.find(params[:id])
  end

end
