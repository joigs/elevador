class FlawsController < ApplicationController

  def index
    @flaws = Flaw.all
  end

  def show
    flaw
  end

  def new
    @flaw = Flaw.new
  end

  def create
    @flaw = Flaw.new(flaw_params)
    if @flaw.save
      redirect_to @flaw, notice: "Defecto creado exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    flaw
  end

  def update
    if @flaw.update(flaw_params)
      redirect_to @flaw, notice: "Defecto modificado exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @flaw.destroy!
    redirect_to flaws_path, notice: "Defecto eliminado"
  end

  private

  def flaw_params
    params.require(:flaw).permit(:revision_id, :code, :point, :level)
  end

  def flaw
    @flaw = Flaw.find(params[:id])
  end

end
