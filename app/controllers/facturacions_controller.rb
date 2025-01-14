class FacturacionsController < ApplicationController
  before_action :set_facturacion, only: %i[ show edit update destroy ]

  # GET /facturacions or /facturacions.json
  def index
    @facturacions = Facturacion.all
  end

  # GET /facturacions/1 or /facturacions/1.json
  def show
  end

  # GET /facturacions/new
  def new
    @facturacion = Facturacion.new
  end

  # GET /facturacions/1/edit
  def edit
  end

  # POST /facturacions or /facturacions.json
  def create
    @facturacion = Facturacion.new(facturacion_params)

    respond_to do |format|
      if @facturacion.save
        format.html { redirect_to facturacion_url(@facturacion), notice: "Facturacion was successfully created." }
        format.json { render :show, status: :created, location: @facturacion }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @facturacion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /facturacions/1 or /facturacions/1.json
  def update
    respond_to do |format|
      if @facturacion.update(facturacion_params)
        format.html { redirect_to facturacion_url(@facturacion), notice: "Facturacion was successfully updated." }
        format.json { render :show, status: :ok, location: @facturacion }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @facturacion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /facturacions/1 or /facturacions/1.json
  def destroy
    @facturacion.destroy!

    respond_to do |format|
      format.html { redirect_to facturacions_url, notice: "Facturacion was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_facturacion
      @facturacion = Facturacion.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def facturacion_params
      params.fetch(:facturacion, {})
    end
end
