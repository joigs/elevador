class RulesController < ApplicationController
  before_action :authorize!

  def index
    @rules = Rule.ordered_by_code
    @pagy, @rules = pagy_countless(@rules, items: 10)
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
  end

  def new_with_new_code
    @rule = Rule.new
    @with_new_code = true
    @last_used_rule = Rule.last&.ruletype_id
    render :new
  end


  def new_with_same_code
    @rule = Rule.new
    @with_same_code = true
    @last_used_rule = Rule.last&.ruletype_id
    render :new
  end
  def create
    @rule = Rule.new(rule_params)
    if params[:with_same_code]
      last_rule = Rule.where(ruletype_id: @rule.ruletype_id).last
      @rule.code = last_rule.code if last_rule
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
  end

  def update
    authorize! rule

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

  private

  def rule_params
    params.require(:rule).permit(:point, :ruletype_id, :code, { ins_type: [] }, { level: [] }, group_ids: [] )
  end

  def rule
    @rule = Rule.find(params[:id])
  end
end
