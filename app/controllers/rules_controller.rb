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
    @with_new_code = params[:with_new_code]
    @with_same_code = params[:with_same_code]
    @last_used_rule = Rule.last&.ruletype_id
    @placeholder_id = Ruletype.where('LOWER(rtype) = ?', 'placeholder'.downcase).first.id
  end

  def new_with_new_code
    @rule = Rule.new
    @with_new_code = true
    @last_used_rule = Rule.last&.ruletype_id
    @placeholder_id = Ruletype.where('LOWER(rtype) = ?', 'placeholder'.downcase).first.id

    render :new
  end


  def new_with_same_code
    @rule = Rule.new
    @with_same_code = true
    @last_used_rule = Rule.last&.ruletype_id
    @placeholder_id = Ruletype.where('LOWER(rtype) = ?', 'placeholder'.downcase).first.id

    render :new
  end
  def create
    @rule = Rule.new(rule_params)



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


      respond_to do |format|
      if @rule.save
        format.html { redirect_to rules_url, notice: 'Rule was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end
  def create_with_new_code
    @rule = Rule.new(rule_params)
    ruletype = Ruletype.find(@rule.ruletype_id)

    if ruletype.rtype.downcase == "placeholder"

      groups = Group.where(id: rule_params[:group_ids])
      if groups.empty?
        flash.now[:alert] = "No se seleccionó ningún grupo"
        render :new and return
      end

      @rule.code = "100.1.1"

    end

    respond_to do |format|
      if @rule.save
        format.html { redirect_to rules_url, notice: 'Rule was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def create_with_same_code
    @rule = Rule.new(rule_params)


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
    respond_to do |format|
      if @rule.save
        format.html { redirect_to rules_url, notice: 'Rule was successfully created with the same code.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end



  def edit
    authorize! rule
    rule
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
    respond_to do |format|
      if rule.update(rule_params)
        format.html { redirect_to rules_url, notice: 'Rule was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! rule
    rule.destroy

    respond_to do |format|
      format.html { redirect_to rules_url, notice: 'Rule was successfully destroyed.', status: :see_other }
      format.json { head :no_content }
    end
  end


  def new_import
  end

  def import
    if params[:file].nil?
      redirect_to new_import_rules_path, alert: "No se seleccionó ningún archivo"
      return

    end
    if params[:group_id].nil? || params[:group_id] == ""
      redirect_to new_import_rules_path, alert: "No se seleccionó ningún grupo"
      return

    end
    if Ruleset.find_by(group_id: params[:group_id])
      redirect_to new_import_rules_path, alert: "El grupo seleccionado ya tiene reglas asociadas"
      return
    end

    RulesImporter.import(params[:file].path, params[:group_id])
    redirect_to rules_path, notice: "Se importaron las fallas con exito"
  end


  private

  def rule_params
    params.require(:rule).permit(:point, :ruletype_id, :code, { ins_type: [] }, { level: [] }, group_ids: [] )
  end

  def rule
    @rule = Rule.find(params[:id])
  end
end
