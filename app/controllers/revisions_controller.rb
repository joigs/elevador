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

    unless params[:section].present?
      redirect_to edit_revision_path(inspection_id: params[:inspection_id], section: 0) and return
    end

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
    @group = @item.group
    @detail = Detail.find_by(item_id: @item.id)

    if @detail.sala_maquinas == "Responder más tarde"
      @rules = @group.rules.includes(:ruletype).where.not('code LIKE ?', '2%').where.not('code LIKE ?', '9%').ordered_by_code


    elsif @detail.sala_maquinas == "Si"
      @rules = @group.rules.includes(:ruletype).where('code NOT LIKE ?', '9%').ordered_by_code

    elsif @detail.sala_maquinas == "No. Máquina en la parte superior"
      @rules = @group.rules.includes(:ruletype).where('code NOT LIKE ?', '2%').where.not('code LIKE ?', '9.3%').where.not('code LIKE ?', '9.4%').ordered_by_code

    elsif @detail.sala_maquinas == "No. Máquina en foso"
      @rules = @group.rules.includes(:ruletype).where('code NOT LIKE ?', '2%').where.not('code LIKE ?', '9.2%').where.not('code LIKE ?', '9.4%').ordered_by_code

    elsif @detail.sala_maquinas == "No. Maquinaria fuera de la caja de elevadores"
      @rules = @group.rules.includes(:ruletype).where('code NOT LIKE ?', '2%').where.not('code LIKE ?', '9.2%').where.not('code LIKE ?', '9.3%').ordered_by_code

    end
    if params[:section].present?
      section_code_start = params[:section]
      @rules = @rules.select { |rule| rule.code.starts_with?(section_code_start.to_s) }
    end




    @last_revision = Revision.where(item_id: @item.id).order(created_at: :desc).offset(1).first

  rescue ActiveRecord::RecordNotFound
    # This rescue block might be redundant if you are handling the nil cases above
    redirect_to(home_path, alert: "Revision or Inspection not found.")
  end



  def show
    @revision = Revision.find_by!(inspection_id: params[:inspection_id])
    @inspection = Inspection.find_by(id: params[:inspection_id])
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


    # inicializa arreglos para guardar informacion de la revisión
    codes, points, levels, comment, fail_statuses = [], [], [], [], []

    counter = 0

    current_section = params[:section]


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
    end

      control = true

      codes2, points2, levels2, comment2, fail_statuses2 = [], [], [], [], []


      current_section_num = current_section.to_i

      @revision.codes.each_with_index do |code, index|
        code_start = code.split('.').first.to_i
        if code_start >= current_section_num and control
            control = false
            codes.each_with_index do |code2, index2|
              codes2 << codes[index2]
              points2 << points[index2]
              levels2 << levels[index2]
              comment2 << comment[index2]
              fail_statuses2 << fail_statuses[index2]
            end
            if code_start > current_section_num
              codes2 << code
              points2 << @revision.points[index]
              levels2 << @revision.levels[index]
              comment2 << @revision.comment[index]
              fail_statuses2 << @revision.fail[index]
            end
        else
          if code_start != current_section_num

          codes2 << code
          points2 << @revision.points[index]
          levels2 << @revision.levels[index]
          comment2 << @revision.comment[index]
          fail_statuses2 << @revision.fail[index]
          end

        end
      end
      if control
        codes.each_with_index do |code2, index2|
          codes2 << codes[index2]
          points2 << points[index2]
          levels2 << levels[index2]
          comment2 << comment[index2]
          fail_statuses2 << fail_statuses[index2]
        end
      end


      if @revision.codes.blank?
        @revision.codes = codes
        @revision.points = points
        @revision.levels = levels
        @revision.comment = comment
        @revision.fail = fail_statuses
      else
        @revision.codes = codes2
        @revision.points = points2
        @revision.levels = levels2
        @revision.comment = comment2
        @revision.fail = fail_statuses2
      end




      # Maneja la subida de fotos
      if params.dig(:revision_photos, :photo).present? && params.dig(:revision_photos, :photo).reject(&:blank?).any?
        params[:revision_photos][:photo].each_with_index do |photo, index|
          if photo.present?
            code = params[:revision_photos][:code][index]
            @revision.revision_photos.create(photo: photo, code: code)
          end
        end
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