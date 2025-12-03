class RulesPlatsController < ApplicationController
  before_action :authorize!

  def index
    @q = RulesPlat.ransack(params[:q])
    @rules_plats = @q.result(distinct: true).ordered_by_code
    @pagy, @rules_plats = pagy_countless(@rules_plats, items: 50)
  end

  def show
    rules_plat
  end

  def new
    @rules_plat = RulesPlat.new
    authorize! @rules_plat
  end

  def create
    @rules_plat = RulesPlat.new(rules_plat_params)

    authorize! @rules_plat

    if @rules_plat.save
      flash[:notice] = "Se definió la regla con éxito"
      redirect_to rules_plats_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize! rules_plat
  end

  def update
    authorize! rules_plat

    if rules_plat.update(rules_plat_params)
      flash[:notice] = "Se modificó la regla"
      redirect_to rules_plat_path(rules_plat)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! rules_plat
    rules_plat.destroy

    flash[:notice] = "Se eliminó la regla"
    respond_to do |format|
      format.html { redirect_to rules_plats_path }
      format.turbo_stream { head :no_content }
    end
  end

  def new_import
  end

  def import
    if params[:file].nil?
      flash[:alert] = "No se seleccionó ningún archivo"
      redirect_to new_import_rules_plats_path
      return
    end

    RulesPlatsImporter.import(params[:file].path)
    flash[:notice] = "Se importaron las reglas con éxito"
    redirect_to rules_plats_path
  end

  private

  def rules_plat_params

    params.require(:rules_plat).permit(:code, :point, :ref, :level)
  end

  def rules_plat
    @rules_plat ||= RulesPlat.find(params[:id])
  end
end
