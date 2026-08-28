class ItemsController < ApplicationController
  def index
    @q = Item.ransack(params[:q])
    @items = @q.result(distinct: true).order(created_at: :desc)

    unless Current.user.tabla
      @pagy, @items = pagy_countless(@items, items: 10)  # Paginación infinita para las tarjetas
    end

    duplicate_identifiers = Item.group(:identificador).having('count(identificador) > 1').pluck(:identificador)
    @duplicate_items = Item.where(identificador: duplicate_identifiers).group_by(&:identificador)
  end


  def show
    item

    @q = item.inspections.where("number > 0").ransack(params[:q])
    @inspections = @q.result(distinct: true).order(number: :desc)

    unless Current.user.tabla

      @pagy, @inspections = pagy_countless(@inspections, items: 10)  # Paginación infinita para las tarjetas
    end



    @inspection = Inspection.where(item: @item).order(number: :desc).first
    @condicion =  Current.user.admin || @item.inspections.where("number > 0").last&.users&.exists?(id: Current.user&.id) || Current.user.crear
  end

  def new
    authorize! @item = Item.new
  end

  def edit
    authorize! item
  end

  def create
    ActiveRecord::Base.transaction do
      authorize! @item = Item.new(item_create_params)

      attrs = item_create_params.to_h

      # Eliminar espacios en blanco de identificador
      attrs["identificador"] = attrs["identificador"].gsub(/\s+/, "") if attrs["identificador"].present?

      # Validación de grupo
      if attrs["group_id"] == "bad"
        flash.now[:alert] = "Seleccione un grupo válido"
        render :new, status: :unprocessable_entity
        return
      end

      # Validación de empresa
      if attrs["principal_id"].blank? || !Principal.exists?(attrs["principal_id"])
        flash.now[:alert] = "Seleccione una empresa válida"
        render :new, status: :unprocessable_entity
        return
      else
        @principal = Principal.find(attrs["principal_id"])
      end

      # Si el identificador está en blanco, generamos uno basado en la empresa y otros datos
      if attrs["identificador"].blank?
        attrs["identificador"] = "CAMBIAME(Empresa: #{attrs["principal_id"]}. #{SecureRandom.hex(10)})"
      end

      if Item.find_by(identificador: attrs["identificador"], principal_id: @principal.id, group_id: attrs["group_id"])
        flash.now[:alert] = "El activo con id #{attrs["identificador"]} ya existe en la empresa #{Item.find_by(identificador: attrs["identificador"]).principal.name}"
        render :new, status: :unprocessable_entity
        return
      end

      # Verificación de duplicados
      @item = Item.where(identificador: attrs["identificador"], principal_id: @principal.id).first_or_initialize
      current_group = @item.group&.id.to_s
      @item.assign_attributes(attrs)
      is_new_item = @item.new_record?

      if @item.new_record? && Item.exists?(identificador: attrs["identificador"])
        flash.now[:alert] = "El activo con id #{attrs["identificador"]} ya existe en la empresa #{Item.find_by(identificador: attrs["identificador"]).principal.name}"
        render :new, status: :unprocessable_entity
        return
      end

      if !@item.new_record? && current_group != attrs["group_id"]
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

    nuevo  = params.dig(:item, :identificador).to_s.gsub(/\s+/, "")
    motivo = params[:motivo].to_s

    if nuevo.blank?
      @item.errors.add(:identificador, "no puede estar en blanco")
      render :edit_identificador, status: :unprocessable_entity
      return
    end

    if nuevo == @item.identificador
      flash[:notice] = "El identificador no cambió"
      redirect_to items_path
      return
    end

    otro = Item.where.not(id: @item.id).find_by(identificador: nuevo)
    if otro
      @item.errors.add(:identificador, "ya existe en la empresa #{otro.principal&.name}")
      render :edit_identificador, status: :unprocessable_entity
      return
    end

    motivo = "typo" if @item.identificador_provisorio?

    case motivo
    when "typo"
      @item.corregir_identificador!(nuevo)
      flash[:notice] = "Identificador corregido. Se actualizaron las inspecciones que tenían el valor erróneo."
    when "cambio"
      @item.cambiar_identificador!(nuevo)
      flash[:notice] = "Identificador actualizado. Las inspecciones anteriores conservan el identificador con el que se emitieron."
    else
      @item.errors.add(:base, "Indique si se trata de una corrección de tipeo o de un cambio real de identificador")
      render :edit_identificador, status: :unprocessable_entity
      return
    end

    redirect_to items_path
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.join(', ')
    render :edit_identificador, status: :unprocessable_entity
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
    item
    authorize! @item

    is_admin = Current.user.admin
    last_inspection = @item.inspections.order(number: :desc).first
    is_inspector = last_inspection&.users&.exists?(id: Current.user&.id)

    unless is_admin || is_inspector
      flash[:alert] = "No tienes permisos para cambiar el grupo de este activo."
      render :edit_group, status: :unprocessable_entity and return
    end

    if item_group_params[:group_id] == @item.group_id.to_s
      flash[:alert] = "El activo ya pertenece a este grupo."
      redirect_to item_path(@item) and return
    end

    if @item.update(item_group_params)
      group = @item.group
      group_type = group.type_of
      inspections = @item.inspections

      @item.revisions.destroy_all if @item.respond_to?(:revisions)
      @item.ladder_revisions.destroy_all if @item.respond_to?(:ladder_revisions)
      @item.plat_revisions.destroy_all if @item.respond_to?(:plat_revisions)

      case group_type
      when "escala"
        inspections.each do |inspection|
          revision = LadderRevision.create!(inspection: inspection, item: @item)

          numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 11, 12, 13, 14, 15]
          numbers.each do |number|
            revision.revision_colors.create!(section: number, color: false, points: [], levels: [], fail: [], comment: [], number: [], priority: [])
          end
        end

        LadderDetail.find_or_create_by(item: @item)

      when "ascensor"
        inspections.each do |inspection|
          revision = Revision.create!(inspection: inspection, item: @item, group: group)

          (0..11).each do |number|
            revision.revision_colors.create!(section: number, color: false, points: [], levels: [], fail: [], comment: [], number: [], priority: [])
          end
        end

        Detail.find_or_create_by(item: @item)

      when "plat"
        inspections.each do |inspection|
          revision = PlatRevision.create!(inspection: inspection, item: @item, group: group)

          limit = group.secondary_type == "plataforma" ? 9 : 7
          (0..limit).each do |number|
            revision.plat_revision_sections.create!(section: number, color: false)
          end
        end

        Detail.find_or_create_by(item: @item)
      end

      flash[:notice] = "Grupo actualizado"
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
    params.require(:item).permit(:group_id, :principal_id)
  end

  def item_create_params
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




end