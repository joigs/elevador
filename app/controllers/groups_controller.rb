class GroupsController < ApplicationController
  before_action :authorize!
  # GET /groups or /groups.json
  def index
    @groups = Group.all.order(number: :asc)
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  def show
    group
  end

  # POST /groups or /groups.json
  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to groups_url, notice: "Group was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /groups/1 or /groups/1.json
  def destroy
    group.destroy!

    respond_to do |format|
      format.html { redirect_to groups_url, notice: "Group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def group
    @group = Group.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.require(:group).permit(:number, rules_attributes: [:point])
  end
end
