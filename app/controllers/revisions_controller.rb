class RevisionsController < ApplicationController


def index
    @revisions = Revision.all
end
  def new
    authorize! @revision = Revision.new
  end

  def create
    authorize! @revision = Revision.new(revision_params)
    if @revision.save
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
  @revision = Revision.find_by!(inspection_id: params[:inspection_id])
  @inspection = Inspection.find(params[:inspection_id])
  @item = @revision.item
  @group = @item.group
  @rules = @group.rules

  if @revision.update(revision_params)
    @revision.flaws.map!(&:to_i)
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
    params.require(:revision).permit(:inspection_id, :group_id, :item_id, { codes: [] }, flaws: [])
  end

end
