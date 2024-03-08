class LadderRevisionsController < ApplicationController




  def edit

    unless params[:section].present?
      redirect_to edit_ladder_revision_path(inspection_id: params[:inspection_id], section: 1)
      return
    end

    @inspection = Inspection.find_by(id: params[:inspection_id])


    if @inspection.nil?
      redirect_to(home_path, alert: "No se encontró la inspección para el activo.")
      return
    end

    @revision = LadderRevision.find_by(inspection_id: @inspection.id)
    if @revision.nil?
      redirect_to(home_path, alert: "Checklist no disponible.")
      return
    end

    authorize! @revision

    #acceder a los objetos asociados a la revision
    @item = @revision.item
    @revision_nulls = RevisionNull.where(revision_id: @revision.id)
    @group = Group.where("name LIKE ?", "%Escalera%").first
    @detail = LadderDetail.find_by(item_id: @item.id)
    @colors = @revision.revision_colors
    @nombres = ['. Requisitos generales',
                '. Estructura de soporte (bastidor) y cerramiento',
                '. Escalones, placa, banda',
                '. Unidad de almacenamiento',
                '.  Balaustrada',
                '.  Pasamanos',
                '.  Rellanos',
                '.  Cuartos de maquinaria, estaciones de accionamiento y de retorno',
                '. Instalaciones y aparatos eléctricos',
                '. Protección contra fallos eléctricos-maniobra',
                '. Interfaces con el edificio',
                '. Señales de seguridad para los usuarios',
                '. Utilización de carros de compra y de carros de equipaje'
    ]


    @rules = Ladder.all

    if params[:section].present?
      section_code_start = "#{params[:section]}."
      @rules = @rules.select { |rule| rule.code.starts_with?("5.#{section_code_start}") }
      @color = @revision.revision_colors.find_by(number: section_code_start.to_i)
    end


    @numbers = [1,2,3,4,5,6,7,8,11, 12, 13, 14, 15]



    @last_revision = LadderRevision.where(item_id: @item.id).order(created_at: :desc).offset(1).first

    if section_code_start == "1."
      puts("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")

    end

  rescue ActiveRecord::RecordNotFound
    redirect_to(home_path, alert: "No se encontró inspección")
  end



  def show
    @revision = LadderRevision.find_by!(inspection_id: params[:inspection_id])
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
    @revision = LadderRevision.find_by!(inspection_id: params[:inspection_id])
    @inspection = Inspection.find_by(id: params[:inspection_id])


    # inicializa arreglos para guardar informacion de la revisión
    codes, points, levels, comment, number, priority, fail_statuses = [], [], [], [], [], [], []

    counter = 0

    current_section = params[:section]


    if params[:ladder_revision].present?
      if params[:ladder_revision][:fail].present?
        # Revisar la información de cada campo donde hubo una falla
        params[:ladder_revision][:fail].each do |fail_status|
          if fail_status == "1"  # Verefica si ocurre la falla
            # pasa la informacion de los campos a los arreglos
            codes << params[:ladder_revision][:codes][counter]
            points << params[:ladder_revision][:points][counter]
            levels << params[:ladder_revision][:levels][counter]
            comment << params[:ladder_revision][:comment][counter]
            number << params[:ladder_revision][:number][counter]
            priority << params[:ladder_revision][:priority][counter]
            fail_statuses << true
            counter = counter + 1
          end
        end
      end


      if params[:ladder_revision][:null_condition].present?
        params[:ladder_revision][:null_condition].each do |null_condition|
          @revision.revision_nulls.create(point: null_condition)
        end
      end



    end





    control = true

    codes2, points2, levels2, comment2, number2, priority2, fail_statuses2 = [], [], [], [], [], [], []


    current_section_num = current_section.to_i

    @color = @revision.revision_colors.find_by(number: current_section_num)
    if params[:color].present? && params[:color] == "1"
      @color.update!(color: true)
    else
      @color.update!(color: false)
    end

    @revision.codes.each_with_index do |code, index|
      code_start = code.split('.').first.to_i
      if code_start >= current_section_num && control
        control = false
        codes.each_with_index do |code2, index2|
          codes2 << codes[index2]
          points2 << points[index2]
          levels2 << levels[index2]
          comment2 << comment[index2]
          number2 << number[index2]
          priority2 << priority[index2]
          fail_statuses2 << fail_statuses[index2]
        end
        if code_start > current_section_num
          codes2 << code
          points2 << @revision.points[index]
          levels2 << @revision.levels[index]
          comment2 << @revision.comment[index]
          number2 << @revision.number[index]
          priority2 << @revision.priority[index]
          fail_statuses2 << @revision.fail[index]
        end
      else
        if code_start != current_section_num

          codes2 << code
          points2 << @revision.points[index]
          levels2 << @revision.levels[index]
          comment2 << @revision.comment[index]
          number2 << @revision.number[index]
          priority2 << @revision.priority[index]
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
        number2 << number[index2]
        priority2 << priority[index2]
        fail_statuses2 << fail_statuses[index2]
      end
    end


    if @revision.codes.blank?
      @revision.codes = codes
      @revision.points = points
      @revision.levels = levels
      @revision.comment = comment
      @revision.number = number
      @revision.priority = priority
      @revision.fail = fail_statuses
    else
      @revision.codes = codes2
      @revision.points = points2
      @revision.levels = levels2
      @revision.comment = comment2
      @revision.number = number2
      @revision.priority = priority2
      @revision.fail = fail_statuses2
    end


    @revision_nulls = @revision.revision_nulls
    @revision_photos = @revision.revision_photos
    if params[:ladder_revision].present?

      @revision_nulls.each do |null|
        code_start = null.point.split('.').first.to_i


        if code_start == current_section_num
          if params[:ladder_revision][:null_condition].present?

            if !params[:ladder_revision][:null_condition].include?(null.point)
              null.destroy
            end
          else
            null.destroy
          end
        end

      end

      @revision_photos.each do |photo|
        code_start = photo.code.split('.').first.to_i
        if code_start == current_section_num
          if params[:ladder_revision][:codes].present?
            if params[:ladder_revision][:codes].exclude?(photo.code)
              photo.destroy
            end
          else
            photo.destroy
          end
        end

      end

    else
      @revision_nulls.each do |null|
        code_start = null.point.split('.').first.to_i
        if code_start == current_section_num
          null.destroy
        end
      end
      @revision_photos.each do |photo|
        code_start = photo.code.split('.').first.to_i
        if code_start == current_section_num
          photo.destroy
        end
      end
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
      redirect_to ladder_revision_path(inspection_id: @inspection.id), notice: 'Revisión actualizada'
    else
      render :edit, status: :unprocessable_entity
    end
  end



  private

  def ladder_revision
    @revision = LadderRevision.find(params[:id])
  end


  def ladder_revision_params
    params.require(:ladder_revision).permit(
      :inspection_id, :item_id, :color,
      codes: [], points: [], levels: [], fail: [], comment: [], number:[], priority:[], null_condition: []
    ).merge(revision_photos_params)
  end

  #agrega los parametros de las fotos a la revision
  def revision_photos_params
    params.permit(revision_photos: {photo: [], code: []})[:revision_photos] || {}
  end



end