class ItemsController < ApplicationController
  def index
    @q = Item.ransack(params[:q])
    @items = @q.result(distinct: true).order(created_at: :desc)
    @pagy, @items = pagy_countless(@items, items: 10)
    duplicate_identifiers = Item.group(:identificador).having('count(identificador) > 1').pluck(:identificador)
    @duplicate_items = Item.where(identificador: duplicate_identifiers).group_by(&:identificador)

  end

  def show
    item
    @inspection = Inspection.where(item_id: item.id).order(updated_at: :desc).first
    @condicion =  Current.user.admin || @item.inspections.where("number > 0").last.users.exists?(id: Current.user&.id)

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


  # Nuevo método para editar identificador
  def edit_identificador
    authorize! item
  end

  # Nuevo método para actualizar identificador
  def update_identificador
    authorize! item
    if @item.update(item_identificador_params)
      redirect_to items_path, notice: 'Identificador actualizado'
    else
      render :edit_identificador, status: :unprocessable_entity
    end
  end


  # Nuevo método para editar empresa (principal)
  def edit_empresa
    authorize! item
  end

  # Nuevo método para actualizar empresa (principal)
  def update_empresa
    authorize! item
    if @item.update(item_empresa_params)
      @inspections = Inspection.where(item_id: item.id)
      @principal = Principal.find(item_empresa_params[:principal_id])
      @inspections.each do |inspection|
        inspection.update(principal_id: @principal.id)
      end
      redirect_to items_path, notice: 'Empresa actualizada'
    else
      render :edit_empresa, status: :unprocessable_entity
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

  def item_identificador_params
    params.require(:item).permit(:identificador)
  end

  def item_empresa_params
    params.require(:item).permit(:principal_id)
  end
end