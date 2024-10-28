class RevisionPhotosController < ApplicationController
  before_action :set_revision_photo, only: [:destroy]

  def destroy
    authorize! @revision_photo
    @revision_photo.photo.purge_later  # Remove the attached photo
    @revision_photo.destroy            # Delete the RevisionPhoto record
    respond_to do |format|
      format.html { redirect_back(fallback_location: home_path  , notice: 'La foto ha sido eliminada exitosamente.') }
      format.json { head :no_content }
    end
  end

  private

  def set_revision_photo
    @revision_photo = RevisionPhoto.find(params[:id])
    @revision = @revision_photo.revision
    @inspection = @revision.inspection
  end


end
