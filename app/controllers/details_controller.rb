class DetailsController < ApplicationController

  # GET /details or /details.json
  def index
    @details = Detail.all
  end

  # GET /details/1 or /details/1.json
  def show
    details
  end

  # GET /details/1/edit
  def edit
    authorize! detail
  end


  # GET /details/new
  def new
    authorize! @detail = Detail.new
    if params[:item_id].present?
      @item = Item.find(params[:item_id])
    else
      redirect_to items_path, alert: 'No se ha encontrado el item'
    end
  end

  def create
    authorize! @detail = Detail.new(detail_params)
  end

  # PATCH/PUT /details/1 or /details/1.json
  def update
    authorize! detail
    if detail.update(detail_params)
      report = Report.find_by(item_id: detail.item_id)
      redirect_to edit_report_path(report), notice: 'Información modificada exitosamente'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /details/1 or /details/1.json
  def destroy
    authorize! @detail.destroy!
    redirect_to details_path, notice: "Detalle eliminado"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def detail
      @detail = Detail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def detail_params
      params.require(:detail).permit(:detalle, :marca, :modelo, :n_serie, :mm_marca, :mm_n_serie, :potencia, :capacidad, :personas, :ct_marca, :ct_cantidad, :ct_diametro, :medidas_cintas, :rv_marca, :rv_n_serie, :paradas, :embarques, :sala_maquinas, :item_id)
    end
end
