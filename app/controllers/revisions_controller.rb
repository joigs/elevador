class RevisionsController < ApplicationController

  require "ostruct"



  def edit

    unless params[:section].present?
      redirect_to edit_revision_path(inspection_id: params[:inspection_id], section: 0)
      return
    end

    @inspection = Inspection.find_by(id: params[:inspection_id])


    if @inspection.nil?
      flash[:alert] = "No se encontró la inspección para el activo."
      redirect_to(home_path)
      return
    end

    @revision_base = Revision.find_by(inspection_id: @inspection.id)
    if @revision_base.nil?
      flash[:alert] = "Checklist no disponible."
      redirect_to(home_path)
      return
    end

    authorize! @revision_base




    @item = @revision_base.item


    if @inspection.state == "Cerrado"
      flash[:alert] = "la inspección fué cerrada."
      redirect_to(inspection_path(@inspection))
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

    @emergent_text = []

    if @black_revision_base
      @black_revision = @black_revision_base.revision_colors.find_by(section: @section)


      @black_revision_base.revision_colors.each do |revision_color|
        revision_color.codes.each_with_index do |code, index|
          @emergent_text << "#{code} #{revision_color.points[index]}"
        end
      end

    end

    if @last_revision_base
      @last_revision = @last_revision_base&.revision_colors&.find_by(section: @section)

      @last_revision_base&.revision_colors&.each do |revision_color|
        revision_color.codes.each_with_index do |code, index|
          @emergent_text << "#{code} #{revision_color.points[index]}"
        end
      end

    end


    if @item.inspections.size >= 3
      sorted_inspections = @item.inspections.sort_by do |inspection|
        [-inspection.number.abs, inspection.number < 0 ? 1 : 0]
      end

      # Selecciona la tercera inspección en el orden deseado
      @third_inspection = sorted_inspections[2]

      if @third_inspection
        @third_revision_base = Revision.find_by(inspection_id: @third_inspection.id)
        @third_revision = @third_revision_base.revision_colors.find_by(section: @section)
      end
    end
    @original_rules_count = @rules.size

    @anothers = Another.where(item_id: @item.id, section: @section)

    @another_ids = []

    additional_rules = @anothers.map do |another|
      @another_ids << another.id

      Rule.new(
        point: another.point,
        level: another.level,
        code: another.code,
        ins_type: another.ins_type,
        ruletype: another.ruletype
      )
    end

    # Combina las reglas existentes con las nuevas
    @rules += additional_rules

  rescue ActiveRecord::RecordNotFound
    # This rescue block might be redundant if you are handling the nil cases above
    flash[:alert] = "Error al guardar la inspección"
    redirect_to(home_path)
  end








  def edit_libre

    unless params[:section].present?
      redirect_to edit_libre_revision_path(inspection_id: params[:inspection_id], section: 0)
      return
    end

    @inspection = Inspection.find_by(id: params[:inspection_id])


    if @inspection.nil?
      flash[:alert] = "No se encontró la inspección para el activo."
      redirect_to(home_path)
      return
    end

    @revision_base = Revision.find_by(inspection_id: @inspection.id)
    if @revision_base.nil?
      flash[:alert] = "Checklist no disponible."
      redirect_to(home_path)
      return
    end

    authorize! @revision_base


    if @inspection.state == "Cerrado"
      flash[:alert] = "la inspección fué cerrada."
      redirect_to(inspection_path(@inspection))
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
    flash[:alert] = "Error al guardar la inspección"
    redirect_to(home_path)
  end

















  def show
    @revision_base = Revision.find_by!(inspection_id: params[:inspection_id])
    @inspection = Inspection.find_by(id: params[:inspection_id])
    @revision_photos = @revision_base.revision_photos
    @general_revision_photos = @revision_photos.select { |photo| photo.code.start_with?('GENERALCODE') }

    @group = @revision_base.item.group
    if @inspection.nil?
      flash[:alert] = "No se encontró la inspección para el activo."
      redirect_to(home_path)
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

    real_codes_fail, real_codes_null, real_numbers, real_priority, real_comment_fail, real_comment_null = [], [], [], [], [], []



    if current_section == "0"



      #Obtener los códigos de fail y null_condition
      fails = revision_params["codes"]
      nulls = revision_params["null_condition"]&.map { |nc| nc.split('_').first } # Solo el código numérico


      carpetas = [
        '0.1.1',
        '0.1.2',
        '0.1.3',
        '0.1.4',
        '0.1.5',
        '0.1.6',
        '0.1.7',
        '0.1.8',
        '0.1.9',
        '0.1.10',
        '0.1.11'
      ]

      #Recorrer los 'codes' e identificar los que deben mantenerse
      carpetas.each_with_index do |numeric_code, index|

        #Si no es ni fail ni null, se debe eliminar este código
        if fails&.include?(numeric_code)


          real_codes_fail << numeric_code
          real_comment_fail << revision_params["comment"][index]



        end
        if nulls&.include?(numeric_code)
          real_codes_null << numeric_code
          real_comment_null << revision_params["comment"][index]

        end

      end

      #seccion que no es carpeta 0
    else

      if params[:revision]&.dig(:null_condition).present?
        real_codes_null = revision_params["null_condition"]&.map { |nc| nc.split('_').first }
      end


    end





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
            if current_section == "0"
              comment << real_comment_fail[counter]
            else
              comment << params[:revision][:comment][counter]

            end

            fail_statuses << true
            counter = counter + 1
            end
          end
      end

      @item = @revision_base.item
      if @item.inspections.size >= 3
        sorted_inspections = @item.inspections.sort_by do |inspection|
          [-inspection.number.abs, inspection.number < 0 ? 1 : 0]
        end

        # Selecciona la tercera inspección en el orden deseado
        @third_inspection = sorted_inspections[2]

        if @third_inspection
          @third_revision_base = Revision.find_by(inspection_id: @third_inspection.id)
          @third_revision = @third_revision_base.revision_colors.find_by(section: @section)
        end
      end

      if @black_inspection and black_params.present?
        codes.each_with_index do |code, index|


          if @inspection.rerun == false || @third_revision&.points&.include?(points[index])
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
      end


      if params[:revision][:null_condition].present?
        params[:revision][:null_condition].each_with_index do |null_condition, index|
          # Extraer el código numérico (antes del "_") para comparar con real_codes_null
          numeric_code = null_condition.split('_').first

          # Extraer el código numérico del valor en real_codes_null
          real_code_numeric = real_codes_null[index]

          if real_code_numeric == numeric_code
            # Obtener el comentario correspondiente (puede ser vacío)
            comment_null = real_comment_null&.fetch(index, "") || ""

            # Verificar si el point ya existe
            existing_revision_null = @revision_base.revision_nulls.find_by(point: null_condition)

            if existing_revision_null
              # Si el comentario es diferente, actualizarlo
              if existing_revision_null.comment != comment_null
                existing_revision_null.update(comment: comment_null)
              end
            else
              # Si no existe, crear uno nuevo con point y comment
              @revision_base.revision_nulls.create(point: null_condition, comment: comment_null)
            end

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
    @revision_photos = @revision_base.revision_photos.reject { |photo| photo.code.start_with?('GENERALCODE') }

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
              code_first_part = photo.code.split(' ').first

              matching_indices = params[:revision][:codes].each_index.select { |i| params[:revision][:codes][i] == code_first_part }
              matched = false

              matching_indices.each do |i|
                constructed_code = "#{params[:revision][:codes][i]} #{params[:revision][:points][i]}"
                if constructed_code == photo.code
                  matched = true
                  break
                end
              end

              photo.destroy unless matched
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



      if params[:imagen_general].present?
        @revision_base.revision_photos.create(photo: params[:imagen_general], code: "GENERALCODE#{params[:imagen_general_comment]}")
      end


    if @revision.update(color: color, codes: codes, points: points, levels: levels, comment: comment)

      if @revision_base.item.group.type_of == "ascensor"
          @revision_photos&.each do |photo|
            code_start = photo.code.split('.').first.to_i
            if code_start == current_section_num
              code_first_part = photo.code.split(' ').first

              matching_indices = @revision.codes.each_index.select { |i| @revision.codes[i] == code_first_part }
              matched = false

              matching_indices.each do |i|
                constructed_code = "#{@revision.codes[i]} #{@revision.points[i]}"
                if constructed_code == photo.code
                  matched = true
                  break
                end
              end

              photo.destroy unless matched
            end
          end

      else
        @revision_photos&.each do |photo|
          code_start = photo.code.split('.').first.to_i
          if code_start == current_section_num
              if @revision.codes.exclude?(photo.code.split('|||').first)
                photo.destroy
              end
          end

        end
      end

      flash[:notice] = "Checklist actualizada"
      redirect_to revision_path(inspection_id: @inspection.id)
    else
      render :edit, status: :unprocessable_entity
    end
  end



  def new_rule

    @inspection = Inspection.find_by(id: params[:inspection_id])


    if @inspection.nil?
      flash[:alert] = "No se encontró la inspección para el activo."
      redirect_to(home_path)
      return
    end

    @revision = Revision.find_by(inspection_id: @inspection.id)
    if @revision.nil?
      flash[:alert] = "Checklist no disponible."
      redirect_to(home_path)
      return
    end

    authorize! @revision
    @section = params[:section]

      if @inspection.state == "Cerrado"
      flash[:alert] = "la inspección fué cerrada."
      redirect_to(inspection_path(@inspection))
      return
    end
    @another = Another.new
  end

  def create_rule
    @revision = Revision.find_by(inspection_id: params[:inspection_id])

    authorize! @revision
    @another = Another.new(another_params)
    @inspection = Inspection.find(params[:inspection_id])


    @section = another_params[:section]
    point = another_params[:point]
    ins_type = another_params[:ins_type]
    level = Array(params[:another][:level])

    item = @inspection.item
    detail = Detail.find_by(item_id: item.id)

    if @section == '9'
      case detail.sala_maquinas
      when "No. Máquina en la parte superior"
        code_prefix = "9.2"
      when "No. Máquina en foso"
        code_prefix = "9.3"
      when "No. Maquinaria fuera de la caja de elevadores"
        code_prefix = "9.4"
      else
        code_prefix = nil
      end

      if code_prefix
        ruletype_candidates = Ruletype.where('gygatype_number LIKE ?', "#{code_prefix}%")
        ruletype = ruletype_candidates.max_by do |rt|
          rt.gygatype_number.split('.')[2].to_i
        end
      end
    else
      ruletype_candidates = Ruletype.where('gygatype_number LIKE ?', "#{@section}%")
      ruletype = ruletype_candidates.max_by do |rt|
        rt.gygatype_number.split('.')[1].to_i
      end
    end
    code = "#{ruletype.gygatype_number}.1"


    if Another.create(ruletype: ruletype, point: point, ins_type: ins_type, level: level, item: item, code: code, section: @section)
      flash[:notice] = "Defecto definido"
      redirect_to edit_revision_path(inspection_id: @revision.inspection_id, section: @section)
    else
      render :new_rule
    end
  end


  def edit_rule
    @inspection = Inspection.find(params[:inspection_id])
    # Asegúrate de tener @revision_base, etc. si lo requieres

    @another = Another.find(params[:another_id])
    @section = params[:section]

    @revision_base = Revision.find_by(inspection_id: @inspection.id)
    authorize! @revision_base  # O como manejes tu pundit/cancancan

    # Renderizar una vista "edit_rule.html.erb" muy similar a tu "new_rule" pero con @another cargado
  end

  def update_rule
    @inspection = Inspection.find(params[:inspection_id])
    @another = Another.find(params[:another][:id])
    @section = params[:another][:section]
    @revision_base = Revision.find_by(inspection_id: @inspection.id)

    authorize! @revision_base

    past_text = @another.point

    if @another.update(another_params)

      @revision_bases_ids = Revision.where(item_id: @inspection.item_id).pluck(:id)

      @revisions = []
      @revision_bases_ids.each do |revision_id|
        @revisions << RevisionColor.find_by(revision_id: revision_id, section: @section)
      end

      @revisions.each do |revision|
        revision.codes.each_with_index do |code, index|
          if code == @another.code && revision.points[index] == past_text




            if revision.levels[index] == "G"
              puts(another_params.inspect)
              if @another.level == ["L"]
                revision.levels[index] = "L"
              end
            elsif revision.levels[index] == "L"
              if @another.level == ["G"]
                revision.levels[index] = "G"
              end
            end


            revision.points[index] = @another.point
            revision.save
          end
        end
      end

      flash[:notice] = "Defecto personalizado actualizado."
      redirect_to edit_revision_path(inspection_id: @inspection.id, section: @section)
    else
      flash[:alert] = "Error al actualizar."
      render :edit_rule
    end
  end



  private

  def revision
    @revision = Revision.find(params[:id])
  end


  def revision_params
    params.fetch(:revision, {}).permit(
      :inspection_id, :group_id, :item_id, :color, :section, :imagen_general, :imagen_general_comment, :id,
      codes: [], points: [], levels: [], fail: [], comment: [], priority: [], number: [], null_condition: [], garbage: []
    ).merge(revision_photos_params).merge(past_revision: past_revision_params)
  end

  def revision_photos_params
    params.permit(revision_photos: {photo: [], code: []})[:revision_photos] || {}
  end

  def past_revision_params
    params.permit(past_revision: {fail: [], codes: [], points: [], levels: []})[:past_revision] || {}
  end

  def another_params
    params.require(:another).permit(:point, :section, { ins_type: [] }, { level: [] })
  end

end