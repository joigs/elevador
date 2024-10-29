class ItemsController < ApplicationController
  def index
    @q = Item.ransack(params[:q])
    @items = @q.result(distinct: true).order(created_at: :desc)

    if Current.user.tabla
      @pagy, @items = pagy(@items, items: 10)  # Paginación tradicional para la tabla
    else
      @pagy, @items = pagy_countless(@items, items: 10)  # Paginación infinita para las tarjetas
    end

    duplicate_identifiers = Item.group(:identificador).having('count(identificador) > 1').pluck(:identificador)
    @duplicate_items = Item.where(identificador: duplicate_identifiers).group_by(&:identificador)
  end


  def show
    item
    @inspection = Inspection.where(item: @item).order(number: :desc).first
    @condicion =  Current.user.admin || @item.inspections.where("number > 0").last.users.exists?(id: Current.user&.id)

  end

  def new
    authorize! @item = Item.new
  end

  def edit
    authorize! item
  end

  def create
    ActiveRecord::Base.transaction do
      authorize! @item = Item.new(item_params)

      # Eliminar espacios en blanco de identificador
      item_params[:identificador] = item_params[:identificador].gsub(/\s+/, "") if item_params[:identificador].present?

      # Validación de grupo
      if item_params[:group_id] == "bad"
        flash.now[:alert] = "Seleccione un grupo válido"
        render :new, status: :unprocessable_entity
        return
      end

      # Validación de empresa
      if item_params[:principal_id].blank? || !Principal.exists?(item_params[:principal_id])
        flash.now[:alert] = "Seleccione una empresa válida"
        render :new, status: :unprocessable_entity
        return
      else
        @principal = Principal.find(item_params[:principal_id])
      end

      # Si el identificador está en blanco, generamos uno basado en la empresa y otros datos
      if item_params[:identificador].blank?
        item_params[:identificador] = "CAMBIAME(Empresa: #{item_params[:principal_id]}. #{SecureRandom.hex(10)})"
      end

      if Item.find_by(identificador: item_params[:identificador], principal_id: @principal.id, group_id: item_params[:group_id])
        flash.now[:alert] = "El activo con id #{item_params[:identificador]} ya existe en la empresa #{Item.find_by(identificador: item_params[:identificador]).principal.name}"
        render :new, status: :unprocessable_entity
        return
      end

      # Verificación de duplicados
      @item = Item.where(identificador: item_params[:identificador], principal_id: @principal.id).first_or_initialize
      current_group = @item.group&.id.to_s
      @item.assign_attributes(item_params)
      is_new_item = @item.new_record?

      if @item.new_record? && Item.exists?(identificador: item_params[:identificador])
        flash.now[:alert] = "El activo con id #{item_params[:identificador]} ya existe en la empresa #{Item.find_by(identificador: item_params[:identificador]).principal.name}"
        render :new, status: :unprocessable_entity
        return
      end

      if !@item.new_record? && current_group != item_params[:group_id]
        flash.now[:alert] = "El activo con identificador #{@item.identificador} pertenece a otro grupo. Seleccione el grupo correcto."
        render :new, status: :unprocessable_entity
        return
      end

      @item.save!

      # Crear detalles adicionales según el tipo de grupo
      if @item.group.type_of == "escala"
        @detail = LadderDetail.create!(item: @item)
      elsif @item.group.type_of == "ascensor"
        @detail = Detail.create!(item: @item)
      end

      flash[:notice] = "Activo añadido con éxito"
      redirect_to items_path
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.join(', ')
    render :new, status: :unprocessable_entity
  end


  def update
    authorize! item
    if @item.update(item_params)
      @inspections = Inspection.where(item_id: item.id)
      @principal = Principal.find(item_params[:principal_id])
      @inspections.each do |inspection|
        inspection.update(principal_id: @principal.id)
      end
      flash[:notice] = "Se modificarion los datos del activo"
      redirect_to items_path
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
      flash[:notice] = "Identificador actualizado"
      redirect_to items_path
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
      flash[:notice] = "Empresa actualizada"
      redirect_to items_path
    else
      render :edit_empresa, status: :unprocessable_entity
    end
  end


  def edit_group
    authorize! item
  end


  def update_group
    authorize! @item

    # Verificar que el activo sea de tipo 'ascensor'
    unless @item.group.type_of == 'ascensor'
      flash[:alert] = "El activo no es de tipo ascensor."
      render :edit_group and return
    end

    # Verificar si el usuario es admin o inspector asignado a la última inspección
    is_admin = Current.user.admin
    last_inspection = @item.inspections.order(number: :desc).first
    is_inspector = last_inspection&.users&.exists?(id: Current.user&.id)

    unless is_admin || is_inspector
      flash[:alert] = "No tienes permisos para cambiar el grupo de este activo."
      render :edit_group and return
    end

    # Verificar que el activo tenga 1 o menos inspecciones con número positivo
    positive_inspections_count = @item.inspections.where('number > 0').count
    if positive_inspections_count > 1
      flash[:alert] = "El activo tiene más de una inspección con número positivo."
      render :edit_group and return
    end

    # Verificar que las revisiones normales y black estén vacías
    revisions_empty = revisions_empty?(@item)
    black_revisions_empty = black_revisions_empty?(@item)

    unless revisions_empty && black_revisions_empty
      @revisions_not_empty = true
      if params[:force_delete_revisions] == '1'
        # Eliminar todas las revisiones y sus datos asociados
        delete_revisions(@item)
      else
        flash.now[:alert] = "Las revisiones no están vacías. ¿Deseas eliminarlas? Esta acción es irreversible."
        render :edit_group and return
      end
    end

    # Actualizar el grupo
    if @item.update(item_group_params)
      # Forzar el cierre de la última inspección
      if last_inspection
        last_inspection.update(state: 'Cerrado', result: 'Creado')
      end
      flash[:notice] = "Grupo actualizado y la inspección ha sido cerrada."
      redirect_to items_path
    else
      render :edit_group, status: :unprocessable_entity
    end
  end


  def destroy
    authorize! item.destroy
    flash[:notice] = "Activo eliminado"

    respond_to do |format|
      format.html { redirect_to items_path }
      format.turbo_stream { head :no_content }
    end
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

  def item_group_params
    params.require(:item).permit(:group_id)
  end
  def revisions_empty?(item)
    revisions = item.revisions
    revisions.all? do |rev|
      rev.revision_colors.empty? && rev.revision_nulls.empty? && rev.revision_photos.empty?
    end
  end

  def black_revisions_empty?(item)
    black_inspections = item.inspections.where('number < 0')
    black_revisions = Revision.where(item: item, inspection: black_inspections)
    black_revisions.all? do |rev|
      rev.revision_colors.empty? && rev.revision_nulls.empty? && rev.revision_photos.empty?
    end
  end

  def delete_revisions(item)
    item.revisions.each do |rev|
      rev.revision_colors.destroy_all
      rev.revision_nulls.destroy_all
      rev.revision_photos.destroy_all
      rev.destroy
    end

    black_inspections = item.inspections.where('number < 0')
    black_revisions = Revision.where(item: item, inspection: black_inspections)
    black_revisions.each do |rev|
      rev.revision_colors.destroy_all
      rev.revision_nulls.destroy_all
      rev.revision_photos.destroy_all
      rev.destroy
    end
  end
end