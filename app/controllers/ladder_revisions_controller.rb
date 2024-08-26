class LadderRevisionsController < ApplicationController

  require "ostruct"



  def edit


    unless params[:section].present?
      redirect_to edit_ladder_revision_path(inspection_id: params[:inspection_id], section: 0)
      return
    end

    @inspection = Inspection.find_by(id: params[:inspection_id])


    if @inspection.nil?
      redirect_to(home_path, alert: "No se encontró la inspección para el activo.")
      return
    end

    @revision_base = LadderRevision.find_by(inspection_id: @inspection.id)
    if @revision_base.nil?
      redirect_to(home_path, alert: "Checklist no disponible.")
      return
    end

    authorize! @revision_base

    if @inspection.state == "Cerrado"
      redirect_to(inspection_path(@inspection), alert: "La inspección fué cerrada.")
      return
    end


    @report = Report.find_by(inspection: @inspection)
    if @report.cert_ant == "Si"
      @black_inspection = Inspection.find_by(number: @inspection.number*-1)
      if @black_inspection
        @black_revision_base = LadderRevision.find_by(inspection_id: @black_inspection.id)
        @last_revision_base = nil
      end

    elsif @report.cert_ant == "sistema"
      @last_revision_base = LadderRevision.where(item_id: @item.id).order(created_at: :desc).offset(1).first

    elsif @report.cert_ant == "No"
      @last_revision_base = nil

    end

    #acceder a los objetos asociados a la revision
    @item = @revision.item
    @revision_nulls = RevisionNull.where(revision_id: @revision_base.id)
    @group = Group.where("name LIKE ?", "%Escala%").first
    @detail = LadderDetail.find_by(item_id: @item.id)
    @colors = @revision.revision_colors.select(:section, :color)

    @nombres = ['. DOCUMENTAL CARPETA 0',
                '. Requisitos generales',
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
      @color = @revision_base.revision_colors.select(:section, :color).find_by(section: section_code_start.to_i)
      @section = params[:section]
      @revision = @revision_base.revision_colors.find_by(section: @section)


    end

    @revision_map = {}
    @revision.codes.each_with_index do |code, index|
      point = @revision.points[index]
      @revision_map[code] ||= {}
      @revision_map[code][point] = index
    end
    if @black_revision_base
      @black_revision = @black_revision_base.revision_colors.find_by(section: @section)
    end
    if @last_revision_base
      @last_revision = @last_revision_base&.revision_colors&.find_by(section: @section)
    end


    @numbers = [0,1,2,3,4,5,6,7,8,11, 12, 13, 14, 15]






  rescue ActiveRecord::RecordNotFound
    redirect_to(home_path, alert: "No se encontró inspección")
  end



  def show
    @revision_base = LadderRevision.find_by!(inspection_id: params[:inspection_id])
    @inspection = Inspection.find_by(id: params[:inspection_id])
    @revision_photos = @revision_base.revision_photos

    if @inspection.nil?
      redirect_to(home_path, alert: "No se encontró la inspección para el activo.")
      return
    end


    @revision = OpenStruct.new(codes: [], points: [], levels: [], comment: [], number: [], priority: [])

    @revision_base.revision_colors.order(:section).each do |revision_color|
      @revision.codes.concat(revision_color.codes || [])
      @revision.points.concat(revision_color.points || [])
      @revision.levels.concat(revision_color.levels || [])
      @revision.comment.concat(revision_color.comment || [])
      @revision.number.concat(revision_color.number || [])
      @revision.priority.concat(revision_color.priority || [])
    end

    @revision_codes = []

    @revision.codes.each_with_index do |code, index|
      @revision_codes << "#{code} #{@revision.points[index]}"
    end

    # hashmap para agrupar las fotos por código
    @photos_by_code = @revision_photos.each_with_object({}) do |photo, hash|
      if photo.photo.attached?
        (hash[photo.code] ||= []) << photo
      end
    end
  end


  def update
    @revision_base = LadderRevision.find_by!(inspection_id: params[:inspection_id])
    @inspection = Inspection.find_by(id: params[:inspection_id])


    # inicializa arreglos para guardar informacion de la revisión
    codes, points, levels, comment, number, priority, fail_statuses = [], [], [], [], [], [], []

    counter = 0

    current_section = params[:section]


    @revision = @revision_base.revision_colors.find_by(section: current_section)


    @black_inspection = Inspection.find_by(number: @inspection.number*-1)

    if @black_inspection
      @black_revision_base = Revision.find_by(inspection_id: @black_inspection.id)
      if @black_revision_base
        @black_revision = @black_revision_base.revision_colors.find_by(section: current_section)
      end
      if ladder_revision_params[:past_revision].present?

        black_params = ladder_revision_params[:past_revision]
      end
    end
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



        if @black_inspection and black_params.present?
          codes.each_with_index do |code, index|
            if black_params[:codes].include?(code)
              black_index_c = black_params[:codes].index(code)

              if black_params[:points].include?(points[index])

                black_index_p = black_params[:points].index(points[index])
                if black_index_c == black_index_p
                  levels[index] = "G"
                end
              end
            end
          end
        end



        if params[:ladder_revision][:null_condition].present?
          params[:ladder_revision][:null_condition].each do |null_condition|
            @revision_base.revision_nulls.create(point: null_condition)
          end
        end


      end






    end


    counter = 0



    black_codes, black_points, black_levels, black_fail_statuses = [], [], [], []

    if black_params.present?

      black_params[:fail].each do |fail_status|
        if fail_status == "1"  # Verefica si ocurre la falla
          # pasa la informacion de los campos a los arreglos
          black_codes << black_params[:codes][counter]
          black_points << black_params[:points][counter]
          black_levels << black_params[:levels][counter]
          black_fail_statuses << true
          counter = counter + 1
        end
      end
    end




    current_section_num = current_section.to_i

    if params[:color].present? && params[:color] == "1"
      color = true
    else
      color = false
    end



    if @black_revision
      @black_revision&.update(color: color, codes: black_codes, points: black_points, levels: black_levels)
    end









    @revision_nulls = @revision_base.revision_nulls
    @revision_photos = @revision_base.revision_photos


    if params[:ladder_revision].present?


      @revision_nulls.each do |null|
        code_start = null.point.split('.')[1].first.to_i

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
        code_start = photo.code.split('.')[1].to_i
        if code_start == current_section_num
          if params[:ladder_revision][:codes].present?
            code_first_part = photo.code.split(' ').first

            if params[:revision][:codes].include?(code_first_part)
              index = params[:revision][:codes].index(code_first_part)
              constructed_code = "#{params[:revision][:codes][index]} #{params[:revision][:points][index]}"
            else
              constructed_code = nil
            end
            if constructed_code != photo.code
              photo.destroy
            end
          else
            photo.destroy
          end
        end

      end

    else


      @revision_nulls.each do |null|
        code_start = null.point.split('.')[1].first.to_i
        if code_start == current_section_num
          null.destroy
        end
      end

      @revision_photos.each do |photo|
        code_start = photo.code.split('.')[1].to_i
        if code_start == current_section_num
          photo.destroy
        end
      end
    end




    if params.dig(:revision_photos, :photo).present? && params.dig(:revision_photos, :photo).reject(&:blank?).any?
      params[:revision_photos][:photo].each_with_index do |photo, index|
        if photo.present?

          code = params[:revision_photos][:code][index]
          @revision_base.revision_photos.create(photo: photo, code: code)
        end
      end
    end



    if @revision.update(color: color, codes: codes, points: points, levels: levels, comment: comment, number: number, priority: priority)
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
    params.fetch(:ladder_revision, {}).permit(
      :inspection_id, :group_id, :item_id, :color, :section, :id,
      codes: [], points: [], levels: [], fail: [], comment: [], priority: [], number: [], null_condition: []
    ).merge(revision_photos_params).merge(past_revision: past_revision_params)
  end

  #agrega los parametros de las fotos a la revision
  def revision_photos_params
    params.permit(revision_photos: {photo: [], code: []})[:revision_photos] || {}
  end

  def past_revision_params
    params.permit(past_revision: {fail: [], codes: [], points: [], levels: []})[:past_revision] || {}
  end


end