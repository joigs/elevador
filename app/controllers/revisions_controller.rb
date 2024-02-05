class RevisionsController < ApplicationController


def index
    @revisions = Revision.all
end
  def new
    authorize! @revision = Revision.new
  end

def create
  @revision = Revision.new(revision_params)
  @revision.inspection_id = params[:inspection_id]
  @inspection = Inspection.find(params[:inspection_id])
  @item = @inspection.item
  @group = @item.group
  @rules = @group.rules

  params[:codes].each_with_index do |code, index|
    if params["rule_#{index}"] == '1' # if the checkbox was checked
      @revision.codes << code
      @revision.level << params[:level][index]
      @revision.flaws << params[:flaws][index]
    end
  end

  if @revision.save
    redirect_to revision_path(@revision), notice: "Revisión realizada exitosamente"
  else
    render :new, status: :unprocessable_entity
  end
end

def update
  @revision = Revision.find_by!(inspection_id: params[:inspection_id])
  @inspection = Inspection.find(params[:inspection_id])
  @item = @revision.item
  @group = @item.group
  @rules = @group.rules

  params[:codes].each_with_index do |code, index|
    if params["rule_#{index}"] == '1' # if the checkbox was checked
      @revision.codes << code
      @revision.level << params[:level][index]
      @revision.flaws << params[:flaws][index]
    end
  end

  if @revision.update(revision_params)
    @revision.save
    redirect_to revision_path(inspection_id: @inspection.id), notice: 'Revisión actualizada'
  else
    render :edit, status: :unprocessable_entity
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
    params.require(:revision).permit(:inspection_id, :group_id, :item_id, codes: [], flaws: [], level: [])
  end

end
