class ConveniosController < ApplicationController
  before_action :set_convenio, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user

  # GET /convenios
  def index
    @months = %w[Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre]
    @years  = (2025..Date.current.year).to_a.reverse

    sel_month = (params[:month] || Date.current.month).to_i
    sel_year  = (params[:year]  || Date.current.year).to_i

    sel_month = 1  unless (1..12).cover?(sel_month)
    sel_year  = 2025 if sel_year < 2025

    @selected_month = sel_month
    @selected_year  = sel_year

    @convenios = Convenio
               .includes(:empresa)
               .where(month: sel_month, year: sel_year)
               .order("empresas.nombre")
  end


  # GET /convenios/1
  def show
    @convenio = Convenio.find(params[:id])

    iva = Iva.find_by(year: @convenio.year, month: @convenio.month)

    @v1_uf     = @convenio.v1
    @v1_clp    = iva ? (@convenio.v1 * iva.valor).round(0) : nil
    @total_clp   = iva ? (@convenio.total * iva.valor).round(0) : nil
    @iva_missing = iva.nil?

    @empresa_nombre = @convenio.empresa&.nombre || "—"
  end

  # GET /convenios/new
  def new
    @convenio = Convenio.new(
      year:  [params[:year].to_i, Date.current.year].find(&:positive?) || Date.current.year,
      month: params[:month] || Date.current.month
    )
  end

  def create
    empresa_nombre = params[:convenio].delete(:empresa_nombre_hidden).to_s.strip

    empresa = Empresa.find_or_create_by(nombre: empresa_nombre) if empresa_nombre.present?
    @convenio = Convenio.new(convenio_params)
    @convenio.empresa = empresa if empresa

    if @convenio.save
      redirect_to @convenio, notice: "Registro creado con éxito."
    else
      render :new, status: :unprocessable_entity
    end
  end



  # GET /convenios/1/edit
  def edit; end

  # POST /convenios


  # PATCH/PUT /convenios/1
  def update
    if @convenio.update(convenio_params)
      redirect_to @convenio, notice: "Convenio actualizado con éxito."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /convenios/1
  def destroy
    @convenio.destroy
    redirect_to convenios_path, notice: "Convenio eliminado con éxito."
  end

  private

  def set_convenio
    @convenio = Convenio.find(params[:id])
  end

  def convenio_params
    params.require(:convenio).permit(:fecha_venta, :n1, :v1)
  end

  def authorize_user
    authorize!
  end
end
