class LadderDetailsController < ApplicationController

  # GET /details or /details.json
  def index
    @details = LadderDetail.all
  end

  # GET /details/1 or /details/1.json
  def show
    detail
  end

  # GET /details/1/edit
  def edit
    authorize! detail
    @inspection = Inspection.where(item_id: detail.item_id).where.not(result: 'black').order(created_at: :desc).first

  end


  # GET /details/new
  def new
    authorize! @detail = LadderDetail.new
    if params[:item_id].present?
      @item = Item.find(params[:item_id])
    else
      redirect_to items_path, alert: 'No se ha encontrado el item'
    end
  end

  def create
    authorize! @detail = LadderDetail.new(ladder_detail_params)
  end

  # PATCH/PUT /details/1 or /details/1.json
  def update
    authorize! detail
    if detail.update(ladder_detail_params)
      report = Report.where(item_id: detail.item_id).last
      inspection = Inspection.find(report.inspection_id)
      inspection.update(state: 'Abierto', result: 'En revisión')
      revision = LadderRevision.find_by(inspection_id: inspection.id)



      redirect_to edit_report_path(report), notice: 'Información modificada exitosamente'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /details/1 or /details/1.json
  def destroy
    authorize! @detail.destroy!
    redirect_to ladder_details_path, notice: "Detalle eliminado"
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def detail
    @detail = LadderDetail.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def ladder_detail_params
    params.require(:ladder_detail).permit(
      :marca,
      :modelo,
      :nserie,
      :mm_marca,
      :mm_nserie,
      :potencia,
      :capacidad,
      :personas,
      :peldaños,
      :longitud,
      :inclinacion,
      :ancho,
      :velocidad,
      :fabricacion,
      :procedencia
    )
  end
end
