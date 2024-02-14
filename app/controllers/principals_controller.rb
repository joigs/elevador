class PrincipalsController < ApplicationController

  # GET /principals or /principals.json
  def index
    @principals = Principal.all
    @pagy, @principals = pagy_countless(@principals, items: 10)
  end

  # GET /principals/1 or /principals/1.json
  def show
    principal
  end

  # GET /principals/new
  def new
    authorize! @principal = Principal.new
  end

  # GET /principals/1/edit
  def edit
    authorize! principal
  end

  # POST /principals or /principals.json
  def create
    authorize! @principal = Principal.new(principal_params)

    if @principal.save
      redirect_to principals_path, notice: "Empresa mandante añadida exitosamente"
    else
      render :new, status: :unprocessable_entity
    end

  end

  # PATCH/PUT /principals/1 or /principals/1.json
  def update
    authorize! principal
    if principal.update(principal_params)
      redirect_to principals_path, notice: 'Empresa mandante modificada'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /principals/1 or /principals/1.json
  def destroy
    authorize! principal.destroy
    redirect_to principals_path, notice: "Empresa mandante eliminada"

  end


  def items
    principal = Principal.find(params[:id])
    items = principal.items.select(:id, :identificador).order(:identificador)
    render json: items
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def principal
      @principal = Principal.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def principal_params
      params.require(:principal).permit(:rut, :name, :business_name, :contact_name, :email, :phone, :cellphone)
    end
end
