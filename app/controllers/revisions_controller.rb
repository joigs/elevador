class RevisionsController < ApplicationController




  def edit

    unless params[:section].present?
      redirect_to edit_revision_path(inspection_id: params[:inspection_id], section: 0)
      return
    end

    @inspection = Inspection.find_by(id: params[:inspection_id])


    if @inspection.nil?
      redirect_to(home_path, alert: "No se encontró la inspección para el activo.")
      return
    end

    @revision_base = Revision.find_by(inspection_id: @inspection.id)
    if @revision_base.nil?
      redirect_to(home_path, alert: "Checklist no disponible.")
      return
    end

    authorize! @revision_base




    @item = @revision_base.item


    if @inspection.state == "Cerrado"
      redirect_to(inspection_path(@inspection), alert: "La inspección fué cerrada.")
      return
    end

    @report = Report.find_by(inspection: @inspection)
    if @report.cert_ant == "Si"
      @black_inspection = Inspection.find_by(number: @inspection.number*-1)
      if @black_inspection
        @black_revision_base = Revision.find_by(inspection_id: @black_inspection.id)
        @last_revision_base = nil
      end

    elsif @report.cert_ant == "sistema"
      @last_revision_base = Revision.where(item_id: @item.id).order(created_at: :desc).offset(1).first

    elsif @report.cert_ant == "No"
      @last_revision_base = nil

    end



    #acceder a los objetos asociados a la revision
    @revision_nulls = RevisionNull.where(revision_id: @revision_base.id)
    @group = @item.group
    @detail = Detail.find_by(item_id: @item.id)
    @colors = @revision_base.revision_colors.select(:section, :color)

    @nombres = ['. DOCUMENTAL CARPETA 0',
               '. CAJA DE ELEVADORES.',
               '. ESPACIO DE MÁQUINAS Y POLEAS (para ascensores sin cuarto de máquinas aplica cláusula 9).',
               '. PUERTA DE PISO.',
               '. CABINA, CONTRAPESO Y MASA DE EQUILIBRIO.',
               '. SUSPENSIÓN, COMPENSACIÓN, PROTECCIÓN CONTRA LA SOBRE VELOCIDAD Y PROTECCIÓN CONTRA EL MOVIMIENTO INCONTROLADO DE LA CABINA.',
               '. GUÍAS, AMORTIGUADORES Y DISPOSITIVOS DE SEGURIDAD DE FINAL DE RECORRIDO.',
               '. HOLGURAS ENTRE CABINA Y PAREDES DE LOS ACCESOS, ASÍ COMO ENTRE CONTRAPESO O MASA DE EQUILIBRADO.',
               '. MÁQUINA.',
               '. ASCENSORES SIN SALA DE MÁQUINAS.',
               '. ESPACIO DE MÁQUINAS.',
               '. ASCENSORES SIN SALA DE MÁQUINAS, CON MÁQUINA EN LA PARTE SUPERIOR DE LA CAJA DE ELEVADORES.',
               '. ASCENSORES CON MÁQUINAS EN FOSO.',
               '. MAQUINARIA FUERA DE LA CAJA DE ELEVADORES.',
               '. PROTECCIÓN CONTRA DEFECTOS ELÉCTRICOS, MANDOS Y PRIORIDADES.',
               '. ASCENSORES CON EXCEPCIONES AUTORIZADAS, EN LOS QUE SE HAYAN REALIZADO MODIFICACIONES IMPORTANTES, O QUE CUMPLAN NORMATIVA PARTICULAR']

    if @detail.sala_maquinas == "Responder más tarde"
      @rules = @group.rules.includes(:ruletype).where.not('code LIKE ?', '2%').where.not('code LIKE ?', '9%').ordered_by_code

      indices= [10, 11, 12, 13]


    elsif @detail.sala_maquinas == "Si"
      @rules = @group.rules.includes(:ruletype).where('code NOT LIKE ?', '9%').ordered_by_code
      @nope = 9
      indices= [10, 11, 12, 13]


    elsif @detail.sala_maquinas == "No. Máquina en la parte superior"
      @rules = @group.rules.includes(:ruletype).where('code NOT LIKE ?', '2%').where.not('code LIKE ?', '9.3%').where.not('code LIKE ?', '9.4%').ordered_by_code
      @nope = 2
      indices= [10, 9, 12, 13]


    elsif @detail.sala_maquinas == "No. Máquina en foso"
      @rules = @group.rules.includes(:ruletype).where('code NOT LIKE ?', '2%').where.not('code LIKE ?', '9.2%').where.not('code LIKE ?', '9.4%').ordered_by_code
      @nope = 2
      indices= [10, 11, 9, 13]


    elsif @detail.sala_maquinas == "No. Maquinaria fuera de la caja de elevadores"
      @rules = @group.rules.includes(:ruletype).where('code NOT LIKE ?', '2%').where.not('code LIKE ?', '9.2%').where.not('code LIKE ?', '9.3%').ordered_by_code
      @nope = 2
      indices= [10, 11, 12, 9]


    end
    elementos = @nombres.values_at(*indices)

    elementos.each { |elemento| @nombres.delete(elemento) }


    if params[:section].present?
      section_code_start = "#{params[:section]}."
      @rules = @rules.select { |rule| rule.code.starts_with?(section_code_start) }
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



  rescue ActiveRecord::RecordNotFound
    # This rescue block might be redundant if you are handling the nil cases above
    redirect_to(home_path, alert: "Error al guardar la inspección")
  end








  def edit_libre

    unless params[:section].present?
      redirect_to edit_libre_revision_path(inspection_id: params[:inspection_id], section: 0)
      return
    end

    @inspection = Inspection.find_by(id: params[:inspection_id])


    if @inspection.nil?
      redirect_to(home_path, alert: "No se encontró la inspección para el activo.")
      return
    end

    @revision_base = Revision.find_by(inspection_id: @inspection.id)
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
        @black_revision_base = Revision.find_by(inspection_id: @black_inspection.id)
        @last_revision_base = nil
      end

    elsif @report.cert_ant == "sistema"
      @last_revision_base = Revision.where(item_id: @item.id).order(created_at: :desc).offset(1).first

    elsif @report.cert_ant == "No"
      @last_revision_base = nil

    end





    #acceder a los objetos asociados a la revision
    @item = @revision.item
    @revision_nulls = RevisionNull.where(revision_id: @revision_base.id)
    @group = @item.group
    @detail = Detail.find_by(item_id: @item.id)
    @colors = @revision_base.revision_colors.select(:section, :color)

    @nombres = ['. DOCUMENTAL CARPETA 0',
               '. Defectos libres.',]

    @rules = @group.rules.ordered_by_code
    if params[:section].present?
      section_code_start = "#{params[:section]}."
      @rules = @rules.select { |rule| rule.code.starts_with?(section_code_start) }
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



  rescue ActiveRecord::RecordNotFound
    # This rescue block might be redundant if you are handling the nil cases above
    redirect_to(home_path, alert: "Error al guardar la inspección")
  end

















  def show
    @revision_base = Revision.find_by!(inspection_id: params[:inspection_id])
    @inspection = Inspection.find_by(id: params[:inspection_id])
    @revision_photos = @revision_base.revision_photos
    @group = @revision_base.item.group
    if @inspection.nil?
      redirect_to(home_path, alert: "No se encontró la inspección para el activo.")
      return
    end






    @revision = OpenStruct.new(codes: [], points: [], levels: [], comment: [])

    @revision_base.revision_colors.order(:section).each do |revision_color|
      @revision.codes.concat(revision_color.codes || [])
      @revision.points.concat(revision_color.points || [])
      @revision.levels.concat(revision_color.levels || [])
      @revision.comment.concat(revision_color.comment || [])
    end


    @revision_codes = []

    @revision.codes.each_with_index do |code, index|
      @revision_codes << "#{code} #{@revision.points[index]}"
    end



    if @group.type_of == "ascensor"
      # hashmap para agrupar las fotos por código
      @photos_by_code = @revision_photos.each_with_object({}) do |photo, hash|
        if photo.photo.attached?
          (hash[photo.code] ||= []) << photo
        end
      end
    elsif @group.type_of == "libre"
      @photos_by_reason = @revision_photos.each_with_object({}) do |photo, hash|
        if photo.photo.attached?
          reason = photo.code.split('|||').last
          (hash[reason] ||= []) << photo
        end
      end
    end

  end


  def update
    @revision_base = Revision.find_by!(inspection_id: params[:inspection_id])
    @inspection = Inspection.find_by(id: params[:inspection_id])


    # inicializa arreglos para guardar informacion de la revisión
    codes, points, levels, comment, fail_statuses = [], [], [], [], []

    counter = 0

    current_section = params[:section]

    @revision = @revision_base.revision_colors.find_by(section: current_section)


    @black_inspection = Inspection.find_by(number: @inspection.number * -1)
    if @black_inspection
      @black_revision_base = Revision.find_by(inspection_id: @black_inspection.id)
      if @black_revision_base
        @black_revision = @black_revision_base.revision_colors.find_by(section: current_section)
      end
      if revision_params[:past_revision].present?
        black_params = revision_params[:past_revision]
      end
    end

    if params[:revision].present?
      if params[:revision][:fail].present?
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


      if params[:revision][:null_condition].present?
        params[:revision][:null_condition].each do |null_condition|
          @revision_base.revision_nulls.create(point: null_condition)
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
    if params[:revision].present?

      @revision_nulls&.each do |null|
        code_start = null.point.split('.').first.to_i


        if code_start == current_section_num
          if params[:revision][:null_condition].present?

            if !params[:revision][:null_condition].include?(null.point)
              null.destroy
            end
          else
            null.destroy
          end
        end

      end

      if @revision_base.item.group.type_of == "ascensor"
        @revision_photos&.each do |photo|
          code_start = photo.code.split('.').first.to_i
          if code_start == current_section_num
            if params[:revision][:codes].present?
              constructed_code = "#{params[:revision][:codes][params[:revision][:codes].index(photo.code.split(' ').first)]} #{params[:revision][:points][params[:revision][:codes].index(photo.code.split(' ').first)]}"

              if constructed_code != photo.code
                photo.destroy
              end
            else
              photo.destroy
            end
          end
        end
      else
        @revision_photos&.each do |photo|
          code_start = photo.code.split('.').first.to_i
          if code_start == current_section_num
            if params[:revision][:codes].present?
              if params[:revision][:codes].exclude?(photo.code.split('|||').first)
                photo.destroy
              end
            else
              photo.destroy
            end
          end

        end
      end




    else
      @revision_nulls&.each do |null|
        code_start = null.point.split('.').first.to_i
        if code_start == current_section_num
          null.destroy
        end
      end
      @revision_photos&.each do |photo|
        code_start = photo.code.split('.').first.to_i
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


    if @revision.update(color: color, codes: codes, points: points, levels: levels, comment: comment)
      redirect_to revision_path(inspection_id: @inspection.id), notice: 'Revisión actualizada'
    else
      render :edit, status: :unprocessable_entity
    end
  end



  def new_rule

    @inspection = Inspection.find_by(id: params[:inspection_id])


    if @inspection.nil?
      redirect_to(home_path, alert: "No se encontró la inspección para el activo.")
      return
    end

    @revision = Revision.find_by(inspection_id: @inspection.id)
    if @revision.nil?
      redirect_to(home_path, alert: "Checklist no disponible.")
      return
    end

    authorize! @revision


    if @inspection.state == "Cerrado"
      redirect_to(inspection_path(@inspection), alert: "La inspección fué cerrada.")
      return
    end
    @rule = Rule.new
  end

  def create_rule
    @revision = Revision.find_by(inspection_id: params[:inspection_id])

    authorize! @revision
    @rule = Rule.new(rule_params)
    @group = @revision.item.group
    @rule.code="100.1.1"
    ruletype = Ruletype.find_by('LOWER(rtype) = ?', "placeholder".downcase)
    @rule.ruletype = ruletype
    if @rule.save
      Ruleset.create(rule: @rule, group: @group)
      redirect_to edit_libre_revision_path(inspection_id: @revision.inspection_id, section: 100), notice: 'Defecto creado.'
    else
      render :new_rule
    end
  end

  private

  def revision
    @revision = Revision.find(params[:id])
  end


  def revision_params
    params.fetch(:revision, {}).permit(
      :inspection_id, :group_id, :item_id, :color, :section, :id,
      codes: [], points: [], levels: [], fail: [], comment: [], priority: [], number: [], null_condition: []
    ).merge(revision_photos_params).merge(past_revision: past_revision_params)
  end

  def revision_photos_params
    params.permit(revision_photos: {photo: [], code: []})[:revision_photos] || {}
  end

  def past_revision_params
    params.permit(past_revision: {fail: [], codes: [], points: [], levels: []})[:past_revision] || {}
  end

  def rule_params
    params.require(:rule).permit(:point, { ins_type: [] }, { level: [] })
  end

end