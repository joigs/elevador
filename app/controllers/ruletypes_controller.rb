class RuletypesController < ApplicationController
  before_action :authorize!
  # GET /ruletypes or /ruletypes.json
  def index
    @q = Ruletype.ransack(params[:q])
    @ruletypes = @q.result(distinct: true).merge(Ruletype.ordered_by_gygatype_number)
    @pagy, @ruletypes = pagy_countless(@ruletypes, items: 10)
  end


  # GET /ruletypes/new
  def new
    @last_used_ruletype = Ruletype.last&.gygatype
    @ruletype = Ruletype.new
  end



  # POST /ruletypes or /ruletypes.json
  def create
    @ruletype = Ruletype.new(ruletype_params)

    if @ruletype.rtype.downcase == "placeholder"
      @ruletype.gygatype = "100"
      @ruletype.gygatype_number = "100"
    end

    if @ruletype.save
      flash[:notice] = "Tipo de regla creada"
      redirect_to ruletypes_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    ruletype
  end

  # DELETE /ruletypes/1 or /ruletypes/1.json
  def destroy
    authorize! ruletype
    @ruletype.destroy!

    flash[:notice] = "Tipo de regla eliminada"
    respond_to do |format|
      format.html { redirect_to ruletypes_path }
      format.turbo_stream { head :no_content }
    end  end

  def new_import
  end

  def import

    if Ruletype.exists?
      flash[:alert] = "Ya existen comprobaciones"
      redirect_to new_import_ruletypes_path
      return
    end



    if params[:file].nil?
      flash[:alert] = "No se seleccionó ningún archivo"
      redirect_to new_import_ruletypes_path
      return
    end


    RuletypesImporter.import(params[:file].path)
    flash[:notice] = "Se importaron las comprobaciones con exito"
    redirect_to ruletypes_path
  end


  private

    def ruletype
      @ruletype = Ruletype.find(params[:id])
    end

    def ruletype_params
      params.require(:ruletype).permit(:rtype, :gygatype, :gygatype_number)
    end


end
