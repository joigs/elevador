class LaddersController < ApplicationController
  before_action :authorize!

  def index
    @q = Ladder.ransack(params[:q])
    @ladders = @q.result(distinct: true).order(created_at: :desc)
    @pagy, @ladders = pagy_countless(@ladders, items: 50)
  end

  def show
    ladder
  end

  def new
    @ladder = Ladder.new
  end

  def create
    authorize!
    @ladder = Ladder.new(ladder_params)

    if @ladder.save
      flash[:notice] = "Se definió defecto con éxito"
      redirect_to ladders_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    ladder
  end

  def update
    authorize! ladder

    if ladder.update(ladder_params)
      flash[:notice] = "Se modificó el defecto"
      redirect_to ladder_path(ladder)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! ladder
    ladder.destroy

    flash[:notice] = "Se eliminó el defecto"
    respond_to do |format|
      format.html { redirect_to ladders_path }
      format.turbo_stream { head :no_content }
    end
  end

  def new_import
  end

  def import
    if params[:file].nil?
      flash[:alert] = "No se seleccionó ningún archivo"
      redirect_to new_import_ladders_path
      return
    end

    LaddersImporter.import(params[:file].path)
    flash[:notice] = "Se importaron los defectos con éxito"
    redirect_to ladders_path
  end

  private

  def ladder_params
    params.require(:ladder).permit(:number, :point, :code, :priority, :level)
  end

  def ladder
    @ladder = Ladder.find(params[:id])
  end
end
