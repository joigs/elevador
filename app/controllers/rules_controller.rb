class RulesController < ApplicationController
  before_action :authorize!

  def index
    @rules = Rule.all
  end

  def show
    rule
  end

  def new
    @rule = Rule.new
  end

  def create
    @rule = Rule.new(rule_params)

    respond_to do |format|
      if @rule.save
        format.html { redirect_to rules_url, notice: 'Rule was successfully created.' }
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
