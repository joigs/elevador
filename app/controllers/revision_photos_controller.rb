class RevisionPhotosController < ApplicationController
  before_action :set_revision_photo, only: [:destroy]

  def destroy
    authorize! @revision_photo
    @revision_photo.photo.purge_later
    @revision_photo.destroy
    respond_to do |format|
      format.html { redirect_back(fallback_location: home_path, notice: 'La foto ha sido eliminada exitosamente.') }
      format.json { head :no_content }
    end
  end

  private

  def set_revision_photo
    @revision_photo = RevisionPhoto.find(params[:id])
    @revision = @revision_photo.revision

    if @revision.respond_to?(:inspection)
      @inspection = @revision.inspection
    else
      # Handle cases where @revision does not have an inspection
      @inspection = nil
    end
  end
end
