User
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
    @inspection = Inspection.find_by(id: params[:inspection_id])
    if @inspection.nil?
      redirect_to(home_path, alert: "Inspection not found.") and return
    end

    @revision = Revision.find_by(inspection_id: @inspection.id)
    if @revision.nil?
      redirect_to(home_path, alert: "Revision not found for the provided Inspection.") and return
    end

    # Assuming you have authorization logic in place
    authorize! @revision

    # Directly access item and group through the revision if you're not using them independently in the view.
    @item = @revision.item
    @group = @revision.group
    @rules = @group.rules
  rescue ActiveRecord::RecordNotFound
    # This rescue block might be redundant if you are handling the nil cases above
    redirect_to(home_path, alert: "Revision or Inspection not found.")
  end



  def show
    @revision = Revision.find_by!(inspection_id: params[:inspection_id])
    @revision_photos = @revision.revision_photos
  end


  def update
    @revision = Revision.find_by!(inspection_id: params[:inspection_id])
    @inspection = Inspection.find_by(id: params[:inspection_id])
    puts params.inspect
    # Initialize arrays to store the values for failed rules
    codes, points, levels, fail_statuses = [], [], [], []
    gap = 0
    # Iterate through each rule's fail status from the form submission
    params[:revision][:fail].each_with_index do |fail_status, index|
      if fail_status == "1"  # Checks if the rule is marked as failed
        # For failed rules, add their code, point, level, and fail status to the arrays
        codes << params[:revision][:codes][index-gap]
        points << params[:revision][:points][index-gap]
        levels << params[:revision][:levels][index-gap]
        gap = gap + 1
        fail_statuses << true
      end
    end
    # Update the revision with the collected data from failed rules
    @revision.codes = codes
    @revision.points = points
    @revision.levels = levels
    @revision.fail = fail_statuses

    if @revision.save
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
    params.require(:revision).permit(
      :inspection_id, :group_id, :item_id,
      codes: [], points: [], levels: [], fail: [],
      revision_photos_attributes: [:id, :photo, :code, :_destroy])
  end

end