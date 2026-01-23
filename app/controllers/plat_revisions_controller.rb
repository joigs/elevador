class PlatRevisionsController < ApplicationController



  def edit
    unless params[:section].present?
      redirect_to edit_plat_revision_path(inspection_id: params[:inspection_id], section: 0)
      return
    end

    @inspection = Inspection.find_by(id: params[:inspection_id])
    if @inspection.nil?
      flash[:alert] = "No se encontró la inspección para el activo."
      redirect_to(home_path)
      return
    end

    @revision_base = PlatRevision.find_by(inspection_id: @inspection.id)
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

    @black_inspection    = nil
    @black_revision_base = nil
    @last_revision_base  = nil

    case @report&.cert_ant
    when "Si"
      @black_inspection = Inspection.find_by(number: @inspection.number * -1)
      if @black_inspection
        @black_revision_base = PlatRevision.find_by(inspection_id: @black_inspection.id)
      end
    when "sistema"
      @last_revision_base = PlatRevision.where(item_id: @item.id).order(created_at: :desc).offset(1).first
    when "No"
      @last_revision_base = nil
    end

    @revision_nulls = RevisionNull
                        .where(revision_type: "PlatRevision", revision_id: @revision_base.id)
                        .to_a
    @group          = @item.group
    @detail         = Detail.find_by(item_id: @item.id)

    @colors = @revision_base.plat_revision_sections.select(:section, :color)

    if @group.secondary_type == "plataforma"
      @nombres = [
        '. Carpeta 0',
        '. Caja del elevador y cerramiento',
        '. Plataforma',
        '. Carga y velocidad',
        '. Sistemas de seguridad',
        '. Puertas de piso',
        '. Instalación eléctrica',
        '. Señalización e información',
        '. Verificaciones finales',
        '. Tracción y Mantenimiento'
      ]
    elsif @group.secondary_type == "salvaescala"
      @nombres = [
        '. Carpeta 0',
        '. Diseño general y construcción',
        '. Rieles guía y topes mecánicos',
        '. Paracaídas y detección de exceso de velocidad',
        '. Sistema de accionamiento y frenado',
        '. Instalación eléctrica y controles',
        '. Vehículo (silla, plataforma)',
        '. Señalización y marcado'
      ]
    else
      @nombres = []
    end

    @copy          = Conexion.find_by(copy_inspection_id: @inspection.id)
    @inspection_og = @copy.present? ? Inspection.find_by(id: @copy.original_inspection_id) : nil

    section_number     = params[:section].to_i
    section_code_start = "#{section_number}."
    @section           = section_number.to_s

    @rules = RulesPlat.where(group_id: @group.id).order(:code)
    @rules = @rules.select { |rule| rule.code.to_s.starts_with?(section_code_start) }

    @revision_section = @revision_base.plat_revision_sections
                                      .select(:id, :section, :color)
                                      .find_by(section: section_number)
    @color = @revision_section

    revision_data_class = Struct.new(:id, :codes, :points, :levels, :comment)

    build_revision_for_section = lambda do |plat_revision|
      next unless plat_revision

      rels = plat_revision.plat_revision_rules_plats
                          .includes(:rules_plat)
                          .select { |rel| rel.rules_plat.code.to_s.starts_with?(section_code_start) }

      codes    = rels.map { |rel| rel.rules_plat.code }
      points   = rels.map { |rel| rel.rules_plat.point }
      levels   = rels.map(&:level)
      comments = rels.map(&:comment)

      revision_data_class.new(plat_revision.id, codes, points, levels, comments)
    end

    @revision = build_revision_for_section.call(@revision_base)

    @comparison_text = []

    if @inspection_og.present?
      @revision_og = PlatRevision.find_by(inspection_id: @inspection_og.id)

      if @revision_og.present?
        curr_by_section = Hash.new { |h, k| h[k] = [] }
        @revision_base.plat_revision_rules_plats.includes(:rules_plat).each do |rel|
          code  = rel.rules_plat.code
          point = rel.rules_plat.point
          sec   = code.to_s.split('.').first.to_i
          curr_by_section[sec] << [code, point]
        end

        og_by_section = Hash.new { |h, k| h[k] = [] }
        @revision_og.plat_revision_rules_plats.includes(:rules_plat).each do |rel|
          code  = rel.rules_plat.code
          point = rel.rules_plat.point
          sec   = code.to_s.split('.').first.to_i
          og_by_section[sec] << [code, point]
        end

        numero_de_secciones = 11
        sections = (0..numero_de_secciones).to_a

        sections.each do |sec|
          pairs_c = curr_by_section[sec].uniq
          pairs_o = og_by_section[sec].uniq
          common  = pairs_c & pairs_o

          common.each do |code, point|
            next if code.blank? && point.blank?
            @comparison_text << "Sección #{sec} — #{code} #{point}"
          end
        end
      end
    end

    @revision_map = {}

    if @revision
      @revision.codes.each_with_index do |code, index|
        point = @revision.points[index]
        @revision_map[code] ||= {}
        @revision_map[code][point] = index
      end
    end

    @emergent_text = []

    if @black_revision_base
      @black_revision = build_revision_for_section.call(@black_revision_base)

      @black_revision_base.plat_revision_rules_plats.includes(:rules_plat).each do |rel|
        @emergent_text << "#{rel.rules_plat.code} #{rel.rules_plat.point}"
      end
    end

    if @last_revision_base
      @last_revision = build_revision_for_section.call(@last_revision_base)

      @last_revision_base.plat_revision_rules_plats.includes(:rules_plat).each do |rel|
        @emergent_text << "#{rel.rules_plat.code} #{rel.rules_plat.point}"
      end
    end

    @third_inspection    = nil
    @third_revision_base = nil
    @third_revision      = nil

    if @item.inspections.size >= 3
      sorted_inspections = @item.inspections.sort_by do |inspection|
        [-inspection.number.abs, inspection.number < 0 ? 1 : 0]
      end

      @third_inspection = sorted_inspections[2]

      if @third_inspection
        @third_revision_base = PlatRevision.find_by(inspection_id: @third_inspection.id)
        @third_revision      = build_revision_for_section.call(@third_revision_base) if @third_revision_base
      end
    end

    @original_rules_count = @rules.size

    @anothers    = Another.where(item_id: @item.id, section: @section)
    @another_ids = []

    additional_rules = @anothers.map do |another|
      @another_ids << another.id

      RulesPlat.new(
        point:    another.point,
        level:    another.level,
        code:     another.code,
        ref:      another.ref,
        group_id: @group.id
      )
    end

    @rules += additional_rules

    @copy_match_lookup = {}

    if @inspection_og.present?
      @revision_og ||= PlatRevision.find_by(inspection_id: @inspection_og.id)
      if @revision_og
        og_rels = @revision_og.plat_revision_rules_plats
                              .includes(:rules_plat)
                              .select { |rel| rel.rules_plat.code.to_s.starts_with?(section_code_start) }

        og_rels.each do |rel|
          code  = rel.rules_plat.code
          point = rel.rules_plat.point
          next if code.blank? && point.blank?
          @copy_match_lookup["#{code}||#{point}"] = true
        end
      end
    end

  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Error al guardar la inspección"
    redirect_to(home_path)
  end




  def show
    @inspection = Inspection.find_by(id: params[:inspection_id])
    if @inspection.nil?
      flash[:alert] = "No se encontró la inspección para el activo."
      redirect_to(home_path)
      return
    end

    @revision_base = PlatRevision.find_by!(inspection_id: @inspection.id)
    @group         = @revision_base.item.group

    @revision_photos = @revision_base.revision_photos.includes(photo_attachment: :blob)
    @general_revision_photos = @revision_photos.select { |photo| photo.code.to_s.start_with?("GENERALCODE") }

    @defects = @revision_base
                 .plat_revision_rules_plats
                 .joins(:rules_plat)
                 .includes(:rules_plat)
                 .order("rules_plats.code ASC, rules_plats.point ASC")

    @photos_by_code = @revision_photos.each_with_object(Hash.new { |h, k| h[k] = [] }) do |photo, hash|
      next unless photo.photo.attached?
      next if photo.code.to_s.start_with?("GENERALCODE")
      hash[photo.code] << photo
    end
  end
  def update
    @inspection    = Inspection.find(params[:inspection_id])
    @revision_base = PlatRevision.find_by!(inspection_id: @inspection.id)
    authorize! @revision_base if respond_to?(:authorize!)

    section_str  = params[:section].to_s
    section_num  = section_str.to_i
    section_code = "#{section_num}."

    @item  = @revision_base.item
    @group = @item.group

    @revision_section = @revision_base.plat_revision_sections.find_or_initialize_by(section: section_num)

    @report             = Report.find_by(inspection: @inspection)
    @black_inspection   = nil
    @black_revision_base = nil
    @last_revision_base  = nil

    case @report&.cert_ant
    when "Si"
      @black_inspection   = Inspection.find_by(number: @inspection.number * -1)
      @black_revision_base = PlatRevision.find_by(inspection_id: @black_inspection.id) if @black_inspection
    when "sistema"
      @last_revision_base = PlatRevision.where(item_id: @item.id).order(created_at: :desc).offset(1).first
    when "No"
      @last_revision_base = nil
    end

    @third_inspection    = nil
    @third_revision_base = nil

    if @item.inspections.size >= 3
      sorted_inspections = @item.inspections.sort_by do |insp|
        [-insp.number.abs, insp.number < 0 ? 1 : 0]
      end
      @third_inspection = sorted_inspections[2]
      @third_revision_base = PlatRevision.find_by(inspection_id: @third_inspection.id) if @third_inspection
    end

    plat_rules      = plat_rules_params
    null_conditions = plat_revision_null_params # Esto trae un array ej: ["1.1_1", "1.2_3"]
    past_params     = plat_past_revision_params

    # 1. PRECARGAR REGLAS DE LA DB PARA EVITAR USAR PARAMS VACIOS
    # Recolectamos todos los IDs que vienen del formulario
    rule_ids = plat_rules.values.map { |r| r[:rules_plat_id] }.compact
    # Creamos un hash para buscar rápido: { 120 => #<RulesPlat id:120...>, ... }
    rules_lookup = RulesPlat.where(id: rule_ids).index_by(&:id)


    # --- LOGICA DEFECTOS ANTERIORES (BLACK PAIRS) ---
    black_pairs = Set.new
    if @black_revision_base && past_params.present?
      fails  = past_params[:fail]  || []
      codes  = past_params[:codes] || []
      points = past_params[:points] || []
      levels = past_params[:levels] || []

      target_map = {}

      fails.each_with_index do |flag, idx|
        next unless flag == "1"
        code  = codes[idx].to_s
        point = points[idx].to_s
        level = levels[idx].presence || "L"
        next unless code.start_with?(section_code)

        key = [code, point]
        target_map[key] = level
        black_pairs << key
      end

      existing_rels = @black_revision_base.plat_revision_rules_plats.includes(:rules_plat).select { |rel| rel.rules_plat.code.to_s.start_with?(section_code) }
      existing_by_pair = existing_rels.index_by { |rel| [rel.rules_plat.code, rel.rules_plat.point] }

      target_map.each do |(code, point), level|
        rel = existing_by_pair[[code, point]]
        rules_plat = rel&.rules_plat || RulesPlat.find_by(code: code, point: point, group_id: @group.id)
        next unless rules_plat

        if rel
          rel.update(level: level)
        else
          @black_revision_base.plat_revision_rules_plats.create!(rules_plat: rules_plat, level: level)
        end
      end

      existing_rels.each do |rel|
        pair = [rel.rules_plat.code, rel.rules_plat.point]
        rel.destroy unless target_map.key?(pair)
      end

      # Actualizar color si corresponde
      black_section = @black_revision_base.plat_revision_sections.find_by(section: section_num)
      @black_revision_section = black_section if black_section
    end


    # --- LOGICA 3RA INSPECCION ---
    third_points = Set.new
    if @third_revision_base
      @third_revision_base.plat_revision_rules_plats.includes(:rules_plat).each do |rel|
        code = rel.rules_plat.code.to_s
        next unless code.start_with?(section_code)
        third_points << rel.rules_plat.point.to_s
      end
    end

    # --- LOGICA REVISIÓN ACTUAL (NO CUMPLE) ---
    current_rels = @revision_base.plat_revision_rules_plats.includes(:rules_plat).select { |rel| rel.rules_plat.code.to_s.start_with?(section_code) }
    current_by_rule_id = current_rels.index_by(&:rules_plat_id)

    existing_photos = @revision_base.revision_photos.reject { |p| p.code.to_s.start_with?("GENERALCODE") }
    existing_photos_by_code = existing_photos.index_by(&:code)

    keep_rule_ids   = Set.new
    keep_photo_code = Set.new

    plat_rules.each_value do |row|
      # Buscamos la regla real usando el ID
      rules_plat_id = row[:rules_plat_id].to_i
      rules_plat = rules_lookup[rules_plat_id]

      # Si no hay ID (ej: defect new), intentamos fallback (poco probable en este flujo)
      unless rules_plat
        rules_plat = RulesPlat.find_by(code: row[:code], point: row[:point], group_id: @group.id)
      end
      next unless rules_plat

      code = rules_plat.code
      point = rules_plat.point
      next unless code.start_with?(section_code)

      fail_val = ActiveModel::Type::Boolean.new.cast(row[:fail])
      level    = row[:level].presence || "L"
      comment  = row[:comment].presence
      photo_file = row[:photo]

      # Lógica de gravedad automática por repetición
      if fail_val && @black_inspection && black_pairs.include?([code, point]) && (@inspection.rerun == false || third_points.include?(point))
        level = "G"
      end

      if fail_val
        rel = current_by_rule_id[rules_plat.id] || @revision_base.plat_revision_rules_plats.build(rules_plat: rules_plat)
        rel.level   = level
        rel.comment = comment
        rel.save!

        keep_rule_ids << rules_plat.id
        photo_code = "#{code} #{point}"
        keep_photo_code << photo_code

        if photo_file.present?
          if (existing = existing_photos_by_code[photo_code])
            existing.update(photo: photo_file)
          else
            @revision_base.revision_photos.create!(photo: photo_file, code: photo_code)
          end
        end
      end
    end

    # Borrar defectos que se desmarcaron
    current_rels.each do |rel|
      rel.destroy unless keep_rule_ids.include?(rel.rules_plat_id)
    end


    # =========================================================
    # LOGICA REVISION NULLS (CORREGIDA)
    # =========================================================
    # 1. Mapear checkbox "code_point" -> Comentario ingresado en la fila correspondiente

    nulls_scope = RevisionNull.where(revision_type: "PlatRevision", revision_id: @revision_base.id)

    # Hash temporal: { "1.1_1" => "Comentario escrito por el usuario", ... }
    null_data_to_save = {}

    plat_rules.each_value do |row|
      # Usamos el ID para reconstruir la clave "code_point" de forma segura
      r_id = row[:rules_plat_id].to_i
      rule_db = rules_lookup[r_id]
      next unless rule_db

      # Construimos la llave tal cual la genera el check_box_tag en la vista
      generated_key = "#{rule_db.code}_#{rule_db.point}"

      # Si esta llave está presente en el array de checkboxes marcados (null_conditions)
      if null_conditions.include?(generated_key)
        # Guardamos la llave y el comentario asociado a esa fila
        null_data_to_save[generated_key] = row[:comment].to_s
      end
    end

    # 2. Actualizar o Eliminar existentes
    # Filtramos solo los nulls que pertenecen a ESTA sección para no borrar los de otras secciones
    existing_nulls_for_section = nulls_scope.select do |rn|
      c_part = rn.point.to_s.split('_').first
      c_part.present? && c_part.split('.').first.to_i == section_num
    end

    existing_nulls_for_section.each do |rn|
      if null_data_to_save.key?(rn.point)
        # Existe y sigue marcado: Actualizamos comentario si cambió
        new_comment = null_data_to_save[rn.point]
        rn.update(comment: new_comment) if rn.comment != new_comment
        # Lo sacamos del hash para no volver a crearlo
        null_data_to_save.delete(rn.point)
      else
        # Ya no está marcado en el formulario: Borrar
        rn.destroy
      end
    end

    # 3. Crear nuevos (los que quedaron en el hash)
    null_data_to_save.each do |point_str, comment|
      # Doble check para no duplicar (aunque el paso 2 debió limpiar)
      next if nulls_scope.exists?(point: point_str)

      nulls_scope.create!(
        point:         point_str,
        comment:       comment,
        revision_type: "PlatRevision",
        revision_id:   @revision_base.id
      )
    end
    # =========================================================


    # Limpiar fotos huerfanas de esta sección
    existing_photos.each do |photo|
      code_part  = photo.code.to_s.split(' ').first
      section_of = code_part.to_s.split('.').first.to_i
      next unless section_of == section_num
      photo.destroy unless keep_photo_code.include?(photo.code)
    end

    # Imagen general
    if params[:imagen_general].present?
      @revision_base.revision_photos.create!(
        photo: params[:imagen_general],
        code:  "GENERALCODE#{params[:imagen_general_comment]}"
      )
    end

    # Guardar color (marcar como revisado)
    color_flag = params[:color].present? && params[:color] == "1"
    @revision_section.color = color_flag
    @revision_section.save!

    if defined?(@black_revision_section) && @black_revision_section
      @black_revision_section.update(color: color_flag)
    end

    flash[:notice] = "Checklist actualizada"
    redirect_to plat_revision_path(inspection_id: @inspection.id)

  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    puts "ERROR SAVING: #{e.message}" # Debug en consola
    flash[:alert] = "Error al guardar la inspección"
    redirect_to(home_path)
  end


  def new_rule

    @inspection = Inspection.find_by(id: params[:inspection_id])


    if @inspection.nil?
      flash[:alert] = "No se encontró la inspección para el activo."
      redirect_to(home_path)
      return
    end

    @revision = PlatRevision.find_by(inspection_id: @inspection.id)
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
    @revision = PlatRevision.find_by(inspection_id: params[:inspection_id])

    authorize! @revision
    @another = Another.new(another_params)
    @inspection = Inspection.find(params[:inspection_id])


    @section = another_params[:section]
    point = another_params[:point]
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


    if Another.create(point: point,  level: level, item: item, code: code, section: @section)
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

  # Para encontrar la plat_revision (equivalente a def revision)
  def plat_revision
    @plat_revision = PlatRevision.find(params[:id])
  end

  # Reglas de la revisión (cada fila de la tabla principal)
  def plat_rules_params
    params
      .permit(
        plat_rules: [
          :rules_plat_id,
          :another_id,
          :code,
          :point,
          :fail,
          :level,
          :comment,
          :photo
        ]
      )[:plat_rules] || {}
  end

  # Solo los null_condition (N/A), vienen en params[:revision][:null_condition]
  def plat_revision_null_params
    params
      .fetch(:revision, {})
      .permit(null_condition: [])[:null_condition] || []
  end

  # Pasado / defecto anterior (columna "Defecto anterior")
  def plat_past_revision_params
    params
      .permit(past_revision: { fail: [], codes: [], points: [], levels: [] })[:past_revision] || {}
  end

  # Si quieres algo equivalente a revision_params, pero para la cabecera de plat_revision:
  # (ahora solo usas color/imagen_general directamente desde params, así que es opcional)
  def plat_revision_params
    params
      .fetch(:plat_revision, {})
      .permit(
        :inspection_id,
        :item_id,
        :group_id,
        :section,
        :color,
        :imagen_general,
        :imagen_general_comment
      )
  end

  # Para "another" puedes seguir usando el mismo:
  def another_params
    params.require(:another).permit(:point, :section, { ins_type: [] }, { level: [] })
  end


end