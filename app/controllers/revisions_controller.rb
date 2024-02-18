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
      redirect_to(home_path, alert: "No se encontró la inspección para el activo.") and return
    end

    @revision = Revision.find_by(inspection_id: @inspection.id)
    if @revision.nil?
      redirect_to(home_path, alert: "Checklist no disponible.") and return
    end

    authorize! @revision

    #acceder a los objetos asociados a la revision
    @item = @revision.item
    @group = @revision.group
    @rules = @group.rules.includes(:ruletype).ordered_by_code
    if params[:section].present?
      section_code_start = params[:section]
      @rules = @rules.select { |rule| rule.code.starts_with?(section_code_start.to_s) }
    end

    #@bag = Bag.find_by(revision_id: @revision.id)
    #@bag.cumple = Array.new(11, "") if @bag.cumple.blank?
    #@bag.falla = Array.new(11, false) if @bag.falla.blank?
    #@bag.comentario = Array.new(11, "") if @bag.comentario.blank?


    @last_revision = Revision.where(item_id: @item.id).order(created_at: :desc).offset(1).first

  rescue ActiveRecord::RecordNotFound
    # This rescue block might be redundant if you are handling the nil cases above
    redirect_to(home_path, alert: "Revision or Inspection not found.")
  end



  def show
    @revision = Revision.find_by!(inspection_id: params[:inspection_id])
    @revision_photos = @revision.revision_photos

    # hashmap para agrupar las fotos por código
    @photos_by_code = @revision_photos.each_with_object({}) do |photo, hash|
      if photo.photo.attached?
        (hash[photo.code] ||= []) << photo
      end
    end
  end


  def update
    @revision = Revision.find_by!(inspection_id: params[:inspection_id])
    @inspection = Inspection.find_by(id: params[:inspection_id])
    #@bag = Bag.find_by(revision_id: @revision.id)

    # inicializa arreglos para guardar informacion de la revisión
    codes, points, levels, comment, fail_statuses = [], [], [], [], []

    counter = 0

    if params[:revision].present?
      # Revisar la información de cada campo donde hubo una falla
      params[:revision][:fail].each do |fail_status|
        if fail_status == "1"  # Verefica si ocurre la falla
          # pasa la informacion de los campos a los arreglos
          codes << params[:revision][:codes][counter]
          points << params[:revision][:points][counter]
          levels << params[:revision][:levels][counter]
          comment << params[:revision][:comment][counter]
          fail_statuses << true
          counter = counter + 1
        end
      end
      # Actualiza la información de los objetos
      @revision.codes = codes
      @revision.points = points
      @revision.levels = levels
      @revision.comment = comment
      @revision.fail = fail_statuses


      # Maneja la subida de fotos
      if params.dig(:revision_photos, :photo).present? && params.dig(:revision_photos, :photo).reject(&:blank?).any?
        params[:revision_photos][:photo].each_with_index do |photo, index|
          if photo.present?
            code = params[:revision_photos][:code][index]
            @revision.revision_photos.create(photo: photo, code: code)
          end
        end
      end


      # # Maneja la carpeta 0 (bags)
      # cumple, falla, comentario = [], [], []
      # if params[:revision][:bags_attributes].present?
      #   params[:revision][:bags_attributes].each do |bag_attrs|
      #     cumple << bag_attrs[:cumple]
      #     falla << bag_attrs[:falla].to_s == 'true'
      #     comentario << bag_attrs[:comentario]
      #   end
      # end
      #
      # @bag.cumple = cumple
      # @bag.falla = falla
      # @bag.comentario = comentario

    end

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


    def revision_params
    params.require(:revision).permit(
      :inspection_id, :group_id, :item_id,
      codes: [], points: [], levels: [], fail: [], comment: [] #,bags_attributes: [:id, { number: [] }, { cumple: [] }, { falla: [] }, { comentario: [] }, :_destroy]
    ).merge(revision_photos_params)
  end

  #agrega los parametros de las fotos a la revision
  def revision_photos_params
    params.permit(revision_photos: {photo: [], code: []})[:revision_photos] || {}
  end



end