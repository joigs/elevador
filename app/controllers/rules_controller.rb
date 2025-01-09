class RulesController < ApplicationController
  before_action :authorize!

  def index
    @q = Rule.ransack(params[:q])
    @rules = @q.result(distinct: true).merge(Rule.ordered_by_code)
    @pagy, @rules = pagy_countless(@rules, items: 50)
  end

  def show
    rule
  end





  #hay unos New y Create especiales, esos son para que al añadir un defecto nuevo, este se añada con el mismo codigo que el anterior cuando comparten código, o con el mismo código +1

  def new
    @rule = Rule.new
    authorize! @rule
    @with_new_code = params[:with_new_code]
    @with_same_code = params[:with_same_code]
    @last_used_rule = Rule.last&.ruletype_id
    @placeholder_id = Ruletype.where('LOWER(rtype) = ?', 'placeholder'.downcase).first.id
  end

  def new_with_new_code
    @rule = Rule.new
    authorize! @rule
    @with_new_code = true
    @last_used_rule = Rule.last&.ruletype_id
    @placeholder_id = Ruletype.where('LOWER(rtype) = ?', 'placeholder'.downcase).first.id

    render :new
  end


  def new_with_same_code
    @rule = Rule.new
    authorize! @rule
    @with_same_code = true
    @last_used_rule = Rule.last&.ruletype_id
    @placeholder_id = Ruletype.where('LOWER(rtype) = ?', 'placeholder'.downcase).first.id

    render :new
  end
  def create
    @rule = Rule.new(rule_params)

    authorize! @rule


    if params[:with_same_code]
      last_rule = Rule.where(ruletype_id: @rule.ruletype_id).last
      @rule.code = last_rule.code if last_rule
    end
    ruletype = Ruletype.find(@rule.ruletype_id)

    if ruletype.rtype.downcase == "placeholder"

      groups = Group.where(id: rule_params[:group_ids])
      if groups.empty?
        flash.now[:alert] = "No se seleccionó ningún grupo"
        render :new and return
      end
      if groups.any? { |group| group.type_of == "ascensor" }
        flash.now[:alert] =  "Si se selecciona un grupo de ascensores, se debe seleccionar una comprobación"
        render :new and return
      end
      @rule.code = "100.1.1"

    end


      if @rule.save
        flash[:notice] = "Defecto añadido con éxito"
        redirect_to rules_url
      else
        render :new, status: :unprocessable_entity
      end
  end
  def create_with_new_code
    @rule = Rule.new(rule_params)

    authorize! @rule
    @with_new_code = true
    @last_used_rule = Rule.last&.ruletype_id
    @placeholder_id = Ruletype.where('LOWER(rtype) = ?', 'placeholder'.downcase).first.id

    ruletype = Ruletype.find(@rule.ruletype_id)

    if ruletype.rtype.downcase == "placeholder"

      groups = Group.where(id: rule_params[:group_ids])
      if groups.empty?
        flash.now[:alert] = "No se seleccionó ningún grupo"
        render :new and return
      end

      @rule.code = "100.1.1"

    end

      if @rule.save
        flash[:notice] = "Se definió defecto con éxito"
        redirect_to rules_url
      else
        render :new, status: :unprocessable_entity
      end
  end

  def create_with_same_code
    @rule = Rule.new(rule_params)

    authorize! @rule
    @with_same_code = true
    @last_used_rule = Rule.last&.ruletype_id
    @placeholder_id = Ruletype.where('LOWER(rtype) = ?', 'placeholder'.downcase).first.id

    last_rule = Rule.where(ruletype_id: @rule.ruletype_id).last
    @rule.code = last_rule.code if last_rule
    ruletype = Ruletype.find(@rule.ruletype_id)

    if ruletype.rtype.downcase == "placeholder"

      groups = Group.where(id: rule_params[:group_ids])
      if groups.empty?
        flash.now[:alert] = "No se seleccionó ningún grupo"
        render :new and return
      end
      if groups.any? { |group| group.type_of == "ascensor" }
        flash.now[:alert] =  "Si se selecciona un grupo de ascensores, se debe seleccionar una comprobación"
        render :new and return
      end
      @rule.code = "100.1.1"

    end
      if @rule.save
        flash[:notice] = "Se definió defecto con mismo código que el anterior"
        redirect_to rules_url
      else
        render :new, status: :unprocessable_entity
      end
  end



  def edit
    authorize! rule
    @cosa_edit_combobox = rule.ruletype_id
    @placeholder_id = Ruletype.where('LOWER(rtype) = ?', 'placeholder'.downcase).first.id

  end

  def update
    authorize! rule
    ruletype = Ruletype.find(@rule.ruletype_id)

    if ruletype.rtype.downcase == "placeholder"

      groups = Group.where(id: rule_params[:group_ids])
      if groups.empty?
        flash.now[:alert] = "No se seleccionó ningún grupo"
        render :new and return
      end
      if groups.any? { |group| group.type_of == "ascensor" }
        flash.now[:alert] =  "Si se selecciona un grupo de ascensores, se debe seleccionar una comprobación"
        render :new and return
      end
      @rule.code = "100.1.1"

    end
    old_point = @rule.point # guardamos el point antes de update
    if rule.update(rule_params)
      # --- 2) Si el point cambió, avanzamos con la lógica ---
      if old_point != rule.point
        # Parte anterior al primer punto del rule.code, para “filtro rápido”
        rule_code_first_segment = rule.code.to_s.split(".").first

        # Obtenemos los grupos asociados a la regla
        rule_group_ids = rule.groups.pluck(:id)
        # (si la regla se acaba de actualizar con nuevos group_ids, podría ser
        #  `rule.reload.groups.pluck(:id)` para asegurar que estén sincronizados)

        # --- 3) Actualizar RevisionColor ---
        revision_colors = RevisionColor
                            .joins(revision: { item: :group })
                            .where(revision_type: "Revision")
                            .where(groups: { id: rule_group_ids })

        revision_colors.find_each do |rev_color|
          next if rev_color.codes.blank?

          # Filtro rápido con el primer code
          first_code = rev_color.codes.first
          next if first_code.blank?

          first_code_first_segment = first_code.split(".").first
          next unless first_code_first_segment == rule_code_first_segment

          updated = false
          rev_color.codes.each_with_index do |rev_code, idx|
            next if rev_code.blank?

            # Si coincide el code completo
            if rev_code == rule.code
              # Verificamos si points[idx] es igual al old_point
              if rev_color.points[idx] == old_point
                rev_color.points[idx] = rule.point
                updated = true
              end
            end
          end

          rev_color.save if updated
        end

        # --- 4) Actualizar RevisionNull ---
        #     Mismo filtro por grupo => joins(revision: { item: :group })
        revision_nulls = RevisionNull
                           .joins(revision: { item: :group })
                           .where(revision_type: "Revision")
                           .where(groups: { id: rule_group_ids })

        revision_nulls.find_each do |rev_null|
          next if rev_null.point.blank?

          # Separar en 2 partes usando '_'
          # ejemplo: "0.1.4_Declaración jurada..."
          # => rev_null_code = "0.1.4"
          #    rev_null_point = "Declaración jurada..."
          rev_null_code, rev_null_point = rev_null.point.split("_", 2)
          next if rev_null_code.blank? || rev_null_point.blank?

          # Filtro rápido: parte antes del primer punto
          rev_null_code_first_segment = rev_null_code.split(".").first
          next unless rev_null_code_first_segment == rule_code_first_segment

          # Comparamos el code completo con rule.code
          if rev_null_code == rule.code
            # Verificamos si coincide la parte "después del _" con el old_point
            if rev_null_point == old_point
              # Actualizamos la string combinando el nuevo rule.code + nuevo rule.point
              rev_null.point = "#{rule.code}_#{rule.point}"
              rev_null.save
            end
          end
        end
      end

      flash[:notice] = "Defecto actualizado"
      redirect_to rule_path(rule)
    else
      flash[:alert] = "No se pudo actualizar el defecto"
      redirect_to edit_rule_path(rule)
    end
  end

  def destroy
    authorize! rule
    rule.destroy
    flash[:notice] = "Defecto eliminado"
    respond_to do |format|
      format.html { redirect_to rules_path }
      format.turbo_stream { head :no_content }
    end
  end


  def new_import
  end

  def import
    if params[:file].nil?
      flash[:alert] = "No se seleccionó ningún archivo"
      redirect_to new_import_rules_path
      return

    end
    if params[:group_id].nil? || params[:group_id] == ""
      flash[:alert] = "No se seleccionó ningún archivo"
      redirect_to new_import_rules_path
      return

    end
    if Ruleset.find_by(group_id: params[:group_id])
      flash[:alert] = "El grupo seleccionado ya tiene reglas asociadas"
      redirect_to new_import_rules_path
      return
    end

    RulesImporter.import(params[:file].path, params[:group_id])
    flash[:notice] = "Se importaron los defectos con éxito"
    redirect_to rules_path
  end


  private

  def rule_params
    params.require(:rule).permit(:point, :ruletype_id, :code, { ins_type: [] }, { level: [] }, group_ids: [] )
  end

  def rule
    @rule = Rule.find(params[:id])
  end
end
