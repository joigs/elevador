# app/controllers/revision_photos_controller.rb
class RevisionPhotosController < ApplicationController
  before_action :set_revision_photo, only: [:destroy, :rotate]

  def destroy
    authorize! @revision_photo
    @revision_photo.photo.purge_later
    @revision_photo.destroy
    respond_to do |format|
      format.html { redirect_back(fallback_location: home_path, notice: 'La foto ha sido eliminada exitosamente.') }
      format.json { head :no_content }
    end
  end

  def rotate
    authorize! @revision_photo

    degrees = params[:degrees].to_i

    if @revision_photo.photo.attached?
      rotated_image = MiniMagick::Image.read(@revision_photo.photo.download)
      rotated_image.rotate(degrees)

      # Create a Tempfile to save the rotated image
      temp_file = Tempfile.new(["rotated_image", ".jpg"])
      rotated_image.write(temp_file.path)

      # Attach the rotated image, replacing the original
      @revision_photo.photo.attach(io: File.open(temp_file.path), filename: @revision_photo.photo.filename.to_s, content_type: @revision_photo.photo.content_type)

      temp_file.close
      temp_file.unlink

      respond_to do |format|
        format.json { render json: { success: true } }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, error: 'No se encontro imagen' }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_revision_photo
    @revision_photo = RevisionPhoto.find(params[:id])
    @revision = @revision_photo.revision

    if @revision.respond_to?(:inspection)
      @inspection = @revision.inspection
    else
      @inspection = nil
    end
  end
end
