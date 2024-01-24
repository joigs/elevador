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
  end
  def create
    @inspection = Inspection.new(inspection_params)
    if @inspection.ins_date.present? && (@inspection.ins_date.saturday? || @inspection.ins_date.sunday?)
        flash.now[:alert] = "No se pueden programar inspecciones los fines de semana."
        render :new, status: :unprocessable_entity
      else
      if @inspection.save
        redirect_to inspections_path, notice: 'Nueva inspección creada'
      else
        flash.now[:alert] = @inspection.errors.full_messages.first
        render :new, status: :unprocessable_entity
      end
    end
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
    params.require(:inspection).permit(:number, :place, :validation, :ins_date, :user_id)
  end

  def inspection_params_index
    params.permit(:user_id)
  end

  def inspection
    @inspection = Inspection.find(params[:id])
  end
end
