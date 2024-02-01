class MinorsController < ApplicationController

  # GET /minors or /minors.json
  def index
    @minors = Minor.all
    @pagy, @minors = pagy_countless(@minors, items: 10)
  end

  # GET /minors/1 or /minors/1.json
  def show
    minor
  end

  # GET /minors/new
  def new
    authorize! @minor = Minor.new
  end

  # GET /minors/1/edit
  def edit
    authorize! minor
  end

  # POST /minors or /minors.json
  def create
    authorize! @minor = Minor.new(minor_params)
    if @minor.save
      redirect_to minors_path, notice: "Empresa menor agregada exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /minors/1 or /minors/1.json
  def update
    authorize! minor
    if @minor.update(minor_params)
      redirect_to minors_path, notice: 'Empresa menor modificada'
    else
      render :edit, status: :unprocessable_entity
    end

  end

  # DELETE /minors/1 or /minors/1.json
  def destroy
    authorize! @minor.destroy!
    redirect_to minors_path, notice: "Empresa menor eliminada"
  end


  private
    def minor
      @minor = Minor.find(params[:id])
    end

    def minor_params
      params.require(:minor).permit(:rut, :name, :business_name, :contact_name, :email, :phone, :cellphone, :principal_id)
    end
end
