class GroupsController < ApplicationController
  before_action :authorize!
  # GET /groups or /groups.json
  def index
    @groups = Group.where.not(type_of: 'libre').order(number: :asc)
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  def show
    group
    if group == Group.where("name LIKE ?", "%Escala%").first
      @rules = Ladder.all
    else
      @rules = group.rules.ordered_by_code
    end
    if group.type_of == "libre"
      rules1 = @rules.limit(11)
      rules2 = @rules.offset(11)
      rules2.each_with_index do |rule, index|
        rule.code = (index + 1).to_s + "."
      end
      @rules = rules1 + rules2
    end
  end

  # POST /groups or /groups.json
  def create
    @group = Group.new(group_params)

    if @group.type_of == 'escala' && Group.exists?(type_of: 'escala')
      redirect_to new_group_url, alert: "Ya existe un grupo con el tipo 'escala'."
    else
      respond_to do |format|
        if @group.save
          grupo1 = Group.find_by(number: 1)
          rules = grupo1.rules.ordered_by_code.limit(11)
          rules.each do |rule|
            Ruleset.create(group: @group, rule: rule)
          end
          format.html { redirect_to groups_url, notice: "Se creó la clasificación con éxito." }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end
  end



  # DELETE /groups/1 or /groups/1.json
  def destroy
    group.destroy!

    respond_to do |format|
      format.html { redirect_to groups_url, notice: "Se eliminó la clasificación" }
      format.json { head :no_content }
    end
  end



  def libre
    @groups = Group.where(type_of: 'libre').order(number: :asc)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def group
    @group = Group.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.require(:group).permit(:number, :name, :type_of, rules_attributes: [:point])
  end
end
