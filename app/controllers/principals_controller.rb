class PrincipalsController < ApplicationController

  # GET /principals or /principals.json
  def index
    @q = Principal.ransack(params[:q])
    @principals = @q.result(distinct: true).order(created_at: :desc)

    if Current.user.tabla
      @pagy, @principals = pagy(@principals, items: 10) # Paginación tradicional para la tabla
    else
      @pagy, @principals = pagy_countless(@principals, items: 10)
    end

  end



  # GET /principals/1 or /principals/1.json
  def show
    principal
    @q = principal.items.ransack(params[:q])
    @items = @q.result(distinct: true).order(created_at: :desc)
    if Current.user.tabla
      @pagy, @items = pagy(@items, items: 10)  # Paginación tradicional para la tabla
    else
      @pagy, @items = pagy_countless(@items, items: 10)  # Paginación infinita para las tarjetas
    end
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
      flash[:notice] = "Empresa añadida exitosamente"
      redirect_to principals_path
    else
      render :new, status: :unprocessable_entity
    end

  end

  # PATCH/PUT /principals/1 or /principals/1.json
  def update
    authorize! principal
    if principal.update(principal_params)
      flash[:notice] = "Empresa modificada"
      redirect_to principals_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /principals/1 or /principals/1.json
  def destroy
    authorize! principal.destroy
    flash[:notice] = "Empresa eliminada"
    respond_to do |format|
      format.html { redirect_to principals_path }
      format.turbo_stream { head :no_content }
    end
  end


  def items
    principal = Principal.find(params[:id])
    items = principal.items.select(:id, :identificador).order(:identificador)
    render json: items
  end

  def places
    principal = Principal.find(params[:id])
    places = principal.inspections.select(:place).distinct.map(&:place)
    render json: places
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def principal
      @principal = Principal.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def principal_params
      params.require(:principal).permit(:rut, :name, :business_name, :contact_name, :email, :phone, :cellphone, :contact_email, :place)
    end
end
