class ItemsController < ApplicationController
  def index
    @items = Item.all.order(name: :asc)
  end

  def new
    @item = Item.new
  end

  def edit

  end

  def create
    @item = Item.new(item_params)

    if @item.save
      redirect_to items_url, notice: "Ascensor añadido"
    else
      render :new, status: :unprocessable_entity
    end
  end


  def destroy
    item.destroy

    redirect_to items_url, notice: "Ascensor eliminado"
  end

  private
  def category
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:identificador, :group_id)
  end
end