class RevisionsController < ApplicationController


def index
    @revisions = Revision.all
end
def new
  @revision = Revision.new
  @revision.inspection_id = params[:inspection_id]
  @inspection = Inspection.find(params[:inspection_id])
  @item = @inspection.item
  @group = @item.group
  @rules = @group.rules

  authorize! @revision
end

def create
  @inspection = Inspection.find(params[:inspection_id])
  @item = @inspection.item
  @group = @item.group
  @rules = @group.rules

  params[:codes].each_with_index do |code, index|
    if params["rule_#{index}"] == '1' # if the checkbox was checked
      @revision = Revision.new
      @revision.inspection_id = params[:inspection_id]
      @revision.item_id = @item.id
      @revision.group_id = @group.id
      @revision.codes = code
      @revision.level = params[:level][index]
      @revision.flaws = params[:flaws][index]
      unless @revision.save
        render :new, status: :unprocessable_entity and return
      end
    end
  end

  redirect_to revisions_path, notice: "Revisions created successfully"
end

def update
  @inspection = Inspection.find(params[:inspection_id])
  @item = @inspection.item
  @group = @item.group
  @rules = @group.rules

  params[:codes].each_with_index do |code, index|
    if params["rule_#{index}"] == '1' # if the checkbox was checked
      @revision = Revision.find_by(inspection_id: params[:inspection_id], item_id: @item.id, group_id: @group.id)
      @revision.codes = code
      @revision.level = params[:level][index]
      @revision.flaws = params[:flaws][index]
      unless @revision.update(revision_params)
        render :edit, status: :unprocessable_entity and return
      end
    end
  end

  redirect_to revisions_path, notice: 'Revisions updated'
end
def edit
  @revision = Revision.find_by!(inspection_id: params[:inspection_id])
  @inspection = Inspection.find(params[:inspection_id])
  @item = @revision.item
  @group = @item.group
  @rules = @group.rules
  authorize! @revision

end

def show
  @revision = Revision.find_by!(inspection_id: params[:inspection_id])
end

  private

  def revision
    @revision = Principal.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def revision_params
    params.require(:revision).permit(:inspection_id, :group_id, :item_id, flaws_attributes: [:id, :_destroy, :revision_id, :flaw, :code, :level]   )
  end

end
