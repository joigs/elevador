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
  @revision = Revision.new(revision_params)
  @revision.inspection_id = params[:inspection_id]
  @item = @revision.item
  @group = @item.group
  @rules = @group.rules
  if @revision.save
    redirect_to revision_path(@revision), notice: "Revisión realizada exitosamente"
  else
    render :new, status: :unprocessable_entity
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


def update
  params[:revision][:flaws].reject!(&:blank?) if params[:revision][:flaws].is_a?(Array)
  @revision = Revision.find_by!(inspection_id: params[:inspection_id])
  @inspection = Inspection.find(params[:inspection_id])
  @item = @revision.item
  @group = @item.group
  @rules = @group.rules




  if @revision.update(revision_params)
    @revision.save
    redirect_to revision_path(inspection_id: @inspection.id), notice: 'Revisión actualizada'
  else
    render :edit, status: :unprocessable_entity
  end
end


  private

  def revision
    @revision = Principal.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def revision_params
    params.require(:revision).permit(:inspection_id, :group_id, :item_id, :codes, :flaws, :level)
  end

end
