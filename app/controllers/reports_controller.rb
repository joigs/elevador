class ReportsController < ApplicationController

  # GET /reports/1/edit
  def edit
    authorize! report

  end



  # PATCH/PUT /reports/1 or /reports/1.json
  def update
    authorize! report
    if @report.update(report_params)

      if @report.inspection.item.group.name == Group.where("name LIKE ?", "%Escalera%").first&.name
        redirect_to edit_ladder_revision_path(inspection_id: @report.inspection_id), notice: 'Información modificada exitosamente'
      else
        redirect_to edit_revision_path(inspection_id: @report.inspection_id), notice: 'Información modificada exitosamente'
      end

    else
      render :edit, status: :unprocessable_entity
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def report
      @report = Report.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def report_params
      params.require(:report).permit(:certificado_minvu, :cert_ant, :instalation_number, :fecha, :empresa_anterior, :ea_rol, :ea_rut, :empresa_mantenedora, :em_rol, :em_rut, :vi_co_man_ini, :vi_co_man_ter, :nom_tec_man, :tm_rut, :ul_reg_man, :urm_fecha, :inspection_id, :item_id)
    end
end
