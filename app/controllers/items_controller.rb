class ItemsController < ApplicationController
  def index
    @items = Item.all.order(group_id: :asc)
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
    params.require(:item).permit(:identificador, :group_id, :minor_id)
  end
end