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
    if group.type_of == "escala"
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
      flash[:alert] = "Ya existe un grupo con el tipo 'escala'."
      redirect_to new_group_url
    else
        if @group.save
          if @group.type_of == 'libre'
            grupo1 = Group.joins(:rules)
                          .group('groups.id')
                          .having('COUNT(rules.id) >= 11')
                          .find_by(type_of: 'ascensor')
            if grupo1
              rules = grupo1.rules.ordered_by_code.limit(11)
              rules.each do |rule|
                Ruleset.create(group: @group, rule: rule)
              end
            end

          end
          flash[:notice] = "Se creó la clasificación con éxito."
          redirect_to groups_url
        else
          flash.now[:alert] = "No se pudo crear la clasificación."
          render :new, status: :unprocessable_entity
        end
    end
  end



  # DELETE /groups/1 or /groups/1.json
  def destroy

    if group.items.exists?
      flash[:alert] = "No se pudo eliminar el grupo porque tiene elementos asociados."
      redirect_to group_path(group)
    else
      rules = group.rules.to_a

      if group.destroy

        rules.each_with_index do |rule, index|

          if rule.groups.count == 0

            rule.destroy
          end

        end

        flash[:notice] = "Grupo eliminado con éxito."
        respond_to do |format|
          format.html { redirect_to groups_path }
          format.turbo_stream { head :no_content }
        end
      else
        flash[:alert] = "No se pudo eliminar el grupo por un motivo desconocido."
        redirect_to group_path(group)
      end
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
