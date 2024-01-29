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
    authorize! revision
  end

def show
  @revision = Revision.find_by!(inspection_id: params[:inspection_id])
end


  def update
    authorize!
    @revision = Revision.find_by!(inspection_id: params[:inspection_id])
    @inspection = Inspection.find(params[:inspection_id])
    @item = @revision.item
    @group = @item.group
    @rules = @group.rules


  end


  private

  def revision
    @revision = Principal.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def revision_params
    params.require(:revision).permit(:inspection_id, :group_id, :item_id, { codes: [] }, { flaws: [] })
  end

end
