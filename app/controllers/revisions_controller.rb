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
  params[:revision][:flaws].reject!(&:blank?) if params[:revision][:flaws].is_a?(Array)
  @revision = Revision.find_by!(inspection_id: params[:inspection_id])
  @inspection = Inspection.find(params[:inspection_id])
  @item = @revision.item
  @group = @item.group
  @rules = @group.rules

  params[:revision][:codes] ||= []
  params[:revision][:level] ||= []

  params[:revision][:flaws].each_with_index do |flaw, index|
    rule = @rules.find_by(point: flaw)
    if rule
      params[:revision][:codes][index] = rule.code
      params[:revision][:level][index] = params[:revision][:level].include?(rule.point)
    end
  end

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
    params.require(:revision).permit(:inspection_id, :group_id, :item_id, codes: [], flaws: [], level: [])
  end

end
