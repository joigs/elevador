class ReportsController < ApplicationController

  # GET /reports/1/edit
  def edit
    authorize! report

  end



  # PATCH/PUT /reports/1 or /reports/1.json
  def update
    authorize! report
    item = @report.item
    inspection = @report.inspection
    if @report.update(report_params)

      if @report[:cert_ant] == 'Si' && item.inspections.where('number > 0').count == 1
        black_number = inspection.number*-1
        black_inspection = Inspection.find_or_create_by(number: black_number, report_id: @report.id, item_id: item.id, principal_id: item.principal_id, place: inspection.place, ins_date: inspection.ins_date state: 'black', result: 'black')
        if item.group.name == Group.where("name LIKE ?", "%Escala%").first&.name
          LadderRevision.find_or_create_by(inspection_id: black_inspection.id)
          redirect_to edit_black_ladder_revision_path(inspection_id: black_inspection.id)
        else
          Revision.find_or_create_by(inspection_id: black_inspection.id)
          redirect_to edit_black_revision_path(inspection_id: black_inspection.id)
        end

      elsif item.group.name == Group.where("name LIKE ?", "%Escala%").first&.name
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
      params.require(:report).permit(:certificado_minvu, :cert_ant, :fecha, :empresa_anterior, :ea_rol, :ea_rut, :empresa_mantenedora, :em_rol, :em_rut, :vi_co_man_ini, :vi_co_man_ter, :nom_tec_man, :tm_rut, :ul_reg_man, :urm_fecha, :inspection_id, :item_id)
    end
end
