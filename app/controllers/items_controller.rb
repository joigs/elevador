class ItemsController < ApplicationController
  def index
    if params[:query_text].present?
      @items = Item.search_full_text(params[:query_text])
    else
      @items = Item.all.order(created_at: :desc)
    end
    @pagy, @items = pagy_countless(@items, items: 10)
  end

  def show
    item
    @inspection = Inspection.where(item_id: item.id).order(updated_at: :desc).first
  end

  def new
    authorize! @item = Item.new
  end

  def edit
    authorize! item
  end

  def create
    authorize! @item = Item.new(item_params)
    if @item.save
      redirect_to items_path, notice: "Activo añadido"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize! item
    if @item.update(item_params)
      @inspections = Inspection.where(item_id: item.id)
      @principal = Principal.find(item_params[:principal_id])
      @inspections.each do |inspection|
        inspection.update(principal_id: @principal.id)
      end
      redirect_to items_path, notice: 'Se modificaron los datos del activo'
    else
      render :edit, status: :unprocessable_entity
    end

  end


  def destroy
    authorize! item.destroy
    redirect_to items_path, notice: "Activo eliminado"
  end
  
  private
  def item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:identificador, :group_id, :principal_id)
  end
end