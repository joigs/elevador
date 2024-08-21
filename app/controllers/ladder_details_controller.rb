class LadderDetailsController < ApplicationController

  # GET /details or /details.json


  # GET /details/1/edit
  def edit
    authorize! detail
    @inspection = Inspection.where(item_id: detail.item_id).where.not(result: 'black').order(created_at: :desc).first
    @inspection.update(state: 'Abierto', result: 'En revisión')


  end




  # PATCH/PUT /details/1 or /details/1.json
  def update
    authorize! detail
    @report = Report.where(item_id: detail.item_id).last
    @inspection = @report.inspection

    if detail.update(ladder_detail_params)



      redirect_to edit_report_path(@report), notice: 'Información modificada exitosamente'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /details/1 or /details/1.json

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
      :procedencia,
      :descripcion,
      :rol_n,
      :numero_permiso,
      :fecha_permiso,
      :destino,
      :recepcion,
      :empresa_instaladora,
      :empresa_instaladora_rut,
      :porcentaje,
      :detalle
    )
  end
end
