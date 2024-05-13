class DetailsController < ApplicationController

  # GET /details or /details.json
  def index
    @details = Detail.all
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
    authorize! @detail = Detail.new
    if params[:item_id].present?
      @item = Item.find(params[:item_id])
      @inspection = Inspection.where(item_id: @item.id).where.not(result: 'black').order(created_at: :desc).first
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
      report = Report.where(item_id: detail.item_id).last
      inspection = Inspection.find(report.inspection_id)
      inspection.update(state: 'Abierto', result: 'En revisión')
      revision = Revision.find_by(inspection_id: inspection.id)





      if @detail.sala_maquinas == "Responder más tarde"

        codes, points, levels, comment, fail_statuses = [], [], [], [], []
        revision.codes.each_with_index do |code, index|
          if !(code.starts_with?('2') || code.starts_with?('9'))
            codes << code
            points << revision.points[index]
            levels << revision.levels[index]
            comment << revision.comment[index]
            fail_statuses << revision.fail[index]
          end
        end
        revision.codes = codes
        revision.points = points
        revision.levels = levels
        revision.comment = comment
        revision.fail = fail_statuses
        revision.save!

      elsif @detail.sala_maquinas == "Si"


        codes, points, levels, comment, fail_statuses = [], [], [], [], []
        revision.codes.each_with_index do |code, index|
          if !code.starts_with?('9')
            codes << code
            points << revision.points[index]
            levels << revision.levels[index]
            comment << revision.comment[index]
            fail_statuses << revision.fail[index]
          end
        end
        revision.codes = codes
        revision.points = points
        revision.levels = levels
        revision.comment = comment
        revision.fail = fail_statuses
        revision.save!

      elsif @detail.sala_maquinas == "No. Máquina en la parte superior"
        codes, points, levels, comment, fail_statuses = [], [], [], [], []
        revision.codes.each_with_index do |code, index|
          if !(code.starts_with?('2') || code.starts_with?('9.3') || code.starts_with?('9.4'))
            codes << code
            points << revision.points[index]
            levels << revision.levels[index]
            comment << revision.comment[index]
            fail_statuses << revision.fail[index]
          end
        end
        revision.codes = codes
        revision.points = points
        revision.levels = levels
        revision.comment = comment
        revision.fail = fail_statuses
        revision.save!

      elsif @detail.sala_maquinas == "No. Máquina en foso"
        codes, points, levels, comment, fail_statuses = [], [], [], [], []
        revision.codes.each_with_index do |code, index|
          if !(code.starts_with?('2') || code.starts_with?('9.2') || code.starts_with?('9.4'))
            codes << code
            points << revision.points[index]
            levels << revision.levels[index]
            comment << revision.comment[index]
            fail_statuses << revision.fail[index]
          end
        end
        revision.codes = codes
        revision.points = points
        revision.levels = levels
        revision.comment = comment
        revision.fail = fail_statuses
        revision.save!

      elsif @detail.sala_maquinas == "No. Maquinaria fuera de la caja de elevadores"
        codes, points, levels, comment, fail_statuses = [], [], [], [], []
        revision.codes.each_with_index do |code, index|
          if !(code.starts_with?('2') || code.starts_with?('9.2') || code.starts_with?('9.3'))
            codes << code
            points << revision.points[index]
            levels << revision.levels[index]
            comment << revision.comment[index]
            fail_statuses << revision.fail[index]
          end
        end
        revision.codes = codes
        revision.points = points
        revision.levels = levels
        revision.comment = comment
        revision.fail = fail_statuses
        revision.save!

      elsif @detail.sala_maquinas == "No. Maquinaria fuera de la caja de elevadores"
        codes, points, levels, comment, fail_statuses = [], [], [], [], []
        revision.codes.each_with_index do |code, index|
          if !(code.starts_with?('2') || code.starts_with?('9.2') || code.starts_with?('9.3'))
            codes << code
            points << revision.points[index]
            levels << revision.levels[index]
            comment << revision.comment[index]
            fail_statuses << revision.fail[index]
          end
        end
        revision.codes = codes
        revision.points = points
        revision.levels = levels
        revision.comment = comment
        revision.fail = fail_statuses
        revision.save!

      end


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
      params.require(:detail).permit(:detalle, :marca, :modelo, :n_serie, :mm_marca, :mm_n_serie, :potencia, :capacidad, :personas, :ct_marca, :ct_cantidad, :ct_diametro, :medidas_cintas, :rv_marca, :rv_n_serie, :paradas, :embarques, :sala_maquinas, :velocidad, :item_id)
    end
end
