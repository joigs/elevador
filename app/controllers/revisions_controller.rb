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


  redirect_to revisions_path, notice: "Revisions created successfully"
end

def update
  @revision = Revision.find(params[:id])
  @inspection = Inspection.find(params[:inspection_id])
  @item = @inspection.item
  @group = @item.group
  @rules = @group.rules

  # Get the checked rule IDs from the form parameters
  checked_rule_ids = params[:flaw_checkboxes].map(&:to_i)

  # For each checked rule, create a new flaw
  checked_rule_ids.each do |rule_id|
    rule = Rule.find(rule_id)
    @revision.flaws.create(point: rule.point, code: rule.code, level: rule.level.join(","))
  end

  if @revision.update(revision_params)
    redirect_to revision_path(@revision), notice: 'Revisions updated' # Redirect to the show action
  else
    render :edit
  end
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
