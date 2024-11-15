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

    @inspections = @principal.inspections.where("number > ?", 0).order(number: :desc)

    @available_years = @inspections.map { |inspection| inspection.ins_date.year }.uniq.sort
    @selected_year = params[:year].present? ? params[:year].to_i : @available_years.last

    month_order = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
                   "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    month_mapping = {
      "01" => "Enero", "02" => "Febrero", "03" => "Marzo", "04" => "Abril", "05" => "Mayo", "06" => "Junio",
      "07" => "Julio", "08" => "Agosto", "09" => "Septiembre", "10" => "Octubre", "11" => "Noviembre", "12" => "Diciembre"
    }

    inspections_for_year = @inspections.select { |inspection| inspection.ins_date.year == @selected_year }

    @inspections_by_month = inspections_for_year.group_by { |inspection| month_mapping[inspection.ins_date.strftime("%m")] }
                                                .transform_values(&:count)
    @inspections_by_month = @inspections_by_month.sort_by { |month, _| month_order.index(month) }.to_h

    # Agrupar inspecciones por año y ordenar
    @inspections_by_year = @inspections.group_by { |inspection| inspection.ins_date.year }
                                       .transform_values(&:count)
    @inspections_by_year = @inspections_by_year.sort_by { |year, _| year }.to_h

    result_order = ["Aprobado", "Rechazado", "En revisión", "Creado"]
    @inspection_results = @inspections.group_by(&:result).transform_values(&:count)
    @inspection_results = @inspection_results.sort_by { |result, _| result_order.index(result) || result_order.size }.to_h

    state_order = ["Cerrado", "Abierto"]
    @inspection_states = @inspections.group_by(&:state).transform_values(&:count)
    @inspection_states = @inspection_states.sort_by { |state, _| state_order.index(state) || state_order.size }.to_h

    @chart_type = params[:chart_type] || 'bar'
    @colors = [
      '#ff6347', '#4682b4', '#32cd32', '#ffd700', '#6a5acd', '#ff69b4', '#8a2be2', '#00ced1', '#ff4500', '#2e8b57',
      '#ff7f50', '#6495ed', '#9932cc', '#3cb371', '#b8860b', '#ff1493', '#1e90ff', '#daa520', '#ba55d3', '#7b68ee',
      '#ff4500', '#ffa07a', '#20b2aa', '#87cefa', '#b22222', '#ffdead', '#8fbc8f', '#ff6347', '#6b8e23', '#a9a9a9',
      '#ffe4b5', '#fa8072', '#eee8aa', '#98fb98', '#afeeee', '#cd5c5c', '#ff69b4', '#2e8b57', '#8a2be2', '#20b2aa',
      '#dda0dd', '#66cdaa', '#f08080', '#e9967a', '#3cb371', '#f5deb3', '#ff6347', '#40e0d0', '#4682b4', '#db7093',
    ]

    respond_to do |format|
      format.html
      format.turbo_stream
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
