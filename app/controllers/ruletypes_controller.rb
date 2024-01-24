class RuletypesController < ApplicationController
  before_action :authorize!
  # GET /ruletypes or /ruletypes.json
  def index
    @ruletypes = Ruletype.all.order(rtype: :asc)
  end


  # GET /ruletypes/new
  def new
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
      params.require(:ruletype).permit(:rtype)
    end
end
