class RuletypesController < ApplicationController
  before_action :authorize!
  # GET /ruletypes or /ruletypes.json
  def index

    if params[:query_text].present?
      @ruletypes = Ruletype.search_full_text(params[:query_text])
    else
      @ruletypes = Ruletype.ordered_by_gygatype_number
    end
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

    if @ruletype.save
      redirect_to ruletypes_url, notice: "Tipo de regla creada"
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

    redirect_to ruletypes_url, notice: "Tipo de regla eliminada"
  end

  private

    def ruletype
      @ruletype = Ruletype.find(params[:id])
    end

    def ruletype_params
      params.require(:ruletype).permit(:rtype, :gygatype, :gygatype_number)
    end


end
