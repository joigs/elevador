class ReportsController < ApplicationController

  # GET /reports or /reports.json
  def index
    @reports = Report.all
  end

  # GET /reports/1 or /reports/1.json
  def show
    report
  end

  # GET /reports/new
  def new
    authorize! @report = Report.new
  end

  # GET /reports/1/edit
  def edit
    authorize! report
  end

  # POST /reports or /reports.json
  def create
    authorize! @report = Report.new(report_params)

    if @report.save
      redirect_to home_path, notice: "Informe creado exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /reports/1 or /reports/1.json
  def update
    authorize! report
    if @report.update(report_params)
      redirect_to edit_revision_path(inspection_id: @report.inspection_id), notice: 'Información modificada exitosamente'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /reports/1 or /reports/1.json
  def destroy
    authorize! @report.destroy!
    redirect_to reports_path, notice: "Informe eliminado"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def report
      @report = Report.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def report_params
      params.require(:report).permit(:certificado_minvu, :instalation_number, :fecha, :empresa_anterior, :ea_rol, :ea_rut, :empresa_mantenedora, :em_rol, :em_rut, :vi_co_man_ini, :vi_co_man_ter, :nom_tec_man, :tm_rut, :ul_reg_man, :urm_fecha, :inspection_id, :item_id)
    end
end
