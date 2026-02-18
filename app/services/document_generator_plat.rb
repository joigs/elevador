require 'docx_replace'
require 'omnidocx'
require 'fileutils'
require 'mini_magick'
require 'tempfile'
require 'securerandom'
require 'open3'

class DocumentGeneratorPlat
  RevisionEntry = Struct.new(:code, :point, :level, :comment)

  def self.generate_document(inspection_id, principal_id, plat_revision_id, item_id, admin_id)
    inspection      = Inspection.find(inspection_id)
    principal       = Principal.find(principal_id)
    revision_base   = PlatRevision.find(plat_revision_id)
    item            = Item.find(item_id)
    group           = item.group
    detail          = item.detail
    report          = Report.find_by(inspection_id: inspection.id)
    admin           = User.find(admin_id)
    inspectors      = inspection.users



    base_rules = RulesPlat.where(group_id: group.id).to_a

    anothers = Another.where(item_id: item.id)

    additional_rules = anothers.map do |another|
      RulesPlat.new(
        point:    another.point,
        level:    another.level,
        code:     another.code,
        group_id: group.id
      )
    end
    rules = (base_rules + additional_rules)

    rules.sort_by! do |rule|
      code_parts = rule.code.to_s.split('.')
      [
        code_parts[0].to_i,
        code_parts[1].to_i,
        code_parts[2].to_i,
        code_parts[3].to_i
      ]
    end

    rules_for_table = base_rules.sort_by do |rule|
      code_parts = rule.code.to_s.split('.')
      [
        code_parts[0].to_i,
        code_parts[1].to_i,
        code_parts[2].to_i,
        code_parts[3].to_i
      ]
    end


    rels = revision_base.plat_revision_rules_plats.includes(:rules_plat).to_a
    rels.sort_by! do |rel|
      code_parts = rel.rules_plat.code.to_s.split('.')
      [
        code_parts[0].to_i,
        code_parts[1].to_i,
        code_parts[2].to_i,
        code_parts[3].to_i,
        rel.rules_plat.point.to_s
      ]
    end

    revision_entries = rels.map do |rel|
      rule = rel.rules_plat
      RevisionEntry.new(rule.code, rule.point, rel.level, rel.comment)
    end

    revision_by_code_point = {}
    revision_entries.each do |e|
      revision_by_code_point[[e.code, e.point]] = e
    end

    revision_pairs_set = revision_entries.map { |e| [e.code, e.point] }.to_set


    errors_graves = []
    errors_leves  = []
    errors_all    = []

    revision_entries.each do |e|
      level   = e.level.to_s
      comment = e.comment.to_s
      code    = e.code
      point   = e.point

      etiqueta =
        if level.include?('G')
          'defecto grave'
        elsif level.include?('L')
          'defecto leve'
        else
          nil
        end
      next unless etiqueta

      comment_text =
        if comment.blank?
          '(No se hizo ningún comentario)'
        else
          "(#{comment})"
        end

      text_simple = "#{code} #{point} #{comment_text}"
      text_full   = "Defecto: #{code} #{point} #{etiqueta}. #{comment_text}"

      if level.include?('G')
        errors_graves << text_simple
      else
        errors_leves << text_simple
      end
      errors_all << text_full
    end


    item_rol = item.identificador.to_s.chars.last(4).join

    if inspection.rerun == true
      item_rol << "-RI"
    end
    template_path = Rails.root.join('app', 'templates', 'template_1_plat.docx')
    output_path   = Rails.root.join('tmp', "Informe N°#{inspection.number}-#{inspection.ins_date&.strftime('%m')}-#{inspection.ins_date&.strftime('%Y')}-#{item_rol}.docx")

    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")

    doc.replace('{{XXX}}', inspection.number.to_s)
    doc.replace('{{MM}}', inspection.ins_date&.strftime('%m') || '')
    doc.replace('{{XX}}', inspection.ins_date&.strftime('%Y') || '')
    doc.replace('{{rol}}', item_rol)

    doc.replace('{{principal_name}}',           principal.name)
    doc.replace('{{principal_business_name}}', principal.business_name)
    doc.replace('{{principal_rut}}',           principal.rut)

    doc.replace('{{principal_contact_name}}',  principal.contact_name.presence  || 'S/I')
    doc.replace('{{principal_email}}',         principal.email)
    doc.replace('{{principal_phone}}',         principal.phone.presence         || 'S/I')
    doc.replace('{{principal_cellphone}}',     principal.cellphone.presence     || 'S/I')
    doc.replace('{{principal_contact_email}}', principal.contact_email.presence || 'S/I')
    doc.replace('{{principal_place}}',         principal.place.presence         || 'S/I')

    doc.replace('{{inspection_place}}', inspection.place)
    doc.replace('{{ins_date}}',         inspection.ins_date&.strftime('%d/%m/%Y') || '')

    inspector_names = inspection.users.map(&:real_name).join(' / ')
    doc.replace('{{inspector}}', inspector_names)

    doc.replace('{{admin}}',    admin.real_name)
    doc.replace('{{inf_date}}', inspection.inf_date&.strftime('%d/%m/%Y') || '')

    doc.replace('{{inspection_validation}}', report.ending&.strftime('%d/%m/%Y') || '')

    if report.cert_ant == 'Si' || report.cert_ant == 'sistema'
      cert_ant_real =
        case report.cert_ant_real
        when 'Si' then 'Si'
        when 'No' then 'No'
        else            'S/I'
        end
      doc.replace('{{cert_ant}}', cert_ant_real)
      doc.replace('{{report_fecha}}', report.fecha&.strftime('%d/%m/%Y') || 'S/I')
    elsif report.cert_ant == 'No'
      doc.replace('{{cert_ant}}', 'No')
      doc.replace('{{report_fecha}}', '')
    else
      doc.replace('{{cert_ant}}', 'S/I')
      doc.replace('{{report_fecha}}', 'S/I')
    end

    doc.replace('{{instalation_number}}', item.identificador.to_s)

    first_code = revision_entries.first&.code
    if first_code == '0.1.1'
      doc.replace('{{certificado_minvu}}', 'No cumple')
    else
      doc.replace('{{certificado_minvu}}', report.certificado_minvu.to_s)
    end

    doc.replace('{{empresa_anterior}}', report.empresa_anterior.presence || 'S/I')
    doc.replace('{{ea_rol}}',           report.ea_rol.presence           || 'S/I')
    doc.replace('{{ea_rut}}',           report.ea_rut.presence           || 'S/I')

    doc.replace('{{empresa_mantenedora}}', report.empresa_mantenedora)
    doc.replace('{{em_rol}}',              report.em_rol)
    doc.replace('{{em_rut}}',              report.em_rut)

    aux_date = report.vi_co_man_ini&.strftime('%d/%m/%Y') || 'S/I'
    doc.replace('{{vi_co_man_ini}}', aux_date)
    aux_date = report.vi_co_man_ter&.strftime('%d/%m/%Y') || 'S/I'
    doc.replace('{{vi_co_man_ter}}', aux_date)

    doc.replace('{{nom_tec_man}}', report.nom_tec_man)
    doc.replace('{{tm_rut}}',      report.tm_rut)

    doc.replace('{{ul_reg_man}}', report.ul_reg_man.presence || 'S/I')
    aux_date = report.urm_fecha&.strftime('%d/%m/%Y') || 'S/I'
    doc.replace('{{urm_fecha}}', aux_date)

    doc.replace('{{item_identificador}}', item.identificador.to_s)
    doc.replace('{{detail_detalle}}',     detail.detalle.to_s)
    doc.replace('{{detail_marca}}',       detail.marca.to_s)
    doc.replace('{{detail_modelo}}',      detail.modelo.to_s)
    doc.replace('{{detail_n_serie}}',     detail.n_serie.to_s)

    if detail.velocidad
      doc.replace('{{detail_velocidad}}', "#{detail.velocidad} m/s")
    else
      doc.replace('{{detail_velocidad}}', 'S/I')
    end

    doc.replace('{{detail_rol_n}}', detail.rol_n.to_s)

    if detail.numero_permiso
      doc.replace('{{detail_numero_permiso}}', "N°#{detail.numero_permiso}")
    else
      doc.replace('{{detail_numero_permiso}}', 'S/I')
    end

    if detail.fecha_permiso
      doc.replace('{{detail_fecha_permiso}}', detail.fecha_permiso&.strftime('%d/%m/%Y'))
    else
      doc.replace('{{detail_fecha_permiso}}', 'S/I')
    end

    doc.replace('{{detail_destino}}', detail.destino.to_s)
    doc.replace('{{detail_recepcion}}', detail.recepcion.presence || 'S/I')

    doc.replace('{{detail_empresa_instaladora}}', detail.empresa_instaladora.to_s)
    doc.replace('{{detail_empresa_instaladora_rut}}', detail.empresa_instaladora_rut.presence || 'S/I')

    if detail.porcentaje
      doc.replace('{{detail_porcentaje}}', "#{detail.porcentaje}%")
    else
      doc.replace('{{detail_porcentaje}}', 'S/I')
    end

    doc.replace('{{detail_descripcion}}', detail.descripcion.to_s)

    case group.number
    when 1 then doc.replace('{{grupo}}', 'Grupo 1')
    when 2 then doc.replace('{{grupo}}', 'Grupo 2')
    when 3 then doc.replace('{{grupo}}', 'Grupo 3')
    else       doc.replace('{{grupo}}', 'S/I')
    end

    doc.replace('{{detail_mm_marca}}',  detail.mm_marca.to_s)
    doc.replace('{{detail_mm_n_serie}}', detail.mm_n_serie.to_s)

    if detail.potencia
      doc.replace('{{detail_potencia}}', "#{detail.potencia} Kw")
    else
      doc.replace('{{detail_potencia}}', 'S/I')
    end

    if detail.capacidad
      doc.replace('{{detail_capacidad}}', "#{detail.capacidad} Kg")
    else
      doc.replace('{{detail_capacidad}}', 'S/I')
    end

    doc.replace('{{detail_personas}}', detail.personas.presence || 'S/I')

    doc.replace('{{detail_ct_marca}}', detail.ct_marca.to_s)
    if detail.ct_cantidad
      doc.replace('{{detail_ct_cantidad}}', "#{detail.ct_cantidad} unidades")
    else
      doc.replace('{{detail_ct_cantidad}}', 'S/I')
    end

    if detail.ct_diametro
      doc.replace('{{detail_ct_diametro}}', "#{detail.ct_diametro} mm")
    else
      doc.replace('{{detail_ct_diametro}}', 'S/I')
    end

    if detail.medidas_cintas
      doc.replace('{{detail_medidas_cintas}}', "#{detail.medidas_cintas} mm")
    else
      doc.replace('{{detail_medidas_cintas}}', 'S/I')
    end

    if detail.medidas_cintas_espesor
      doc.replace('{{detail_medidas_cintas_espesor}}', "#{detail.medidas_cintas_espesor} mm")
    else
      doc.replace('{{detail_medidas_cintas_espesor}}', 'S/I')
    end

    doc.replace('{{detail_rv_marca}}',  detail.rv_marca.to_s)
    doc.replace('{{detail_rv_n_serie}}', detail.rv_n_serie.to_s)

    doc.replace('{{detail_paradas}}',   detail.paradas.presence   || 'S/I')
    doc.replace('{{detail_embarques}}', detail.embarques.presence || 'S/I')
    doc.replace('Sala de máquinas:', "")
    doc.replace("{{detail_sala_maquinas}}","")
    doc.replace('{{grupo_en_titulo}}', group.name)







      doc.replace('{{item_group}}', group.name.to_s)


    doc.commit(output_path)


    sorted_inspections = item.inspections.sort_by do |ins|
      [-ins.number.abs, ins.number < 0 ? 1 : 0]
    end
    last_inspection = sorted_inspections[1]

    last_revision_base    = nil
    last_revision_entries = []

    if last_inspection
      last_revision_base = PlatRevision.find_by(inspection_id: last_inspection.id)
    end

    if last_revision_base
      last_rels = last_revision_base.plat_revision_rules_plats.includes(:rules_plat).to_a
      last_rels.sort_by! do |rel|
        code_parts = rel.rules_plat.code.to_s.split('.')
        [
          code_parts[0].to_i,
          code_parts[1].to_i,
          code_parts[2].to_i,
          code_parts[3].to_i,
          rel.rules_plat.point.to_s
        ]
      end

      last_revision_entries = last_rels.map do |rel|
        rule = rel.rules_plat
        RevisionEntry.new(rule.code, rule.point, rel.level, rel.comment)
      end
    end

    last_by_code_point = {}
    last_revision_entries.each do |e|
      last_by_code_point[[e.code, e.point]] = e
    end


    last_errors       = []
    last_errors_lift  = []
    exists_last_levels = last_revision_entries.any?

    if report.cert_ant == 'Si' || report.cert_ant == 'sistema'
      if last_revision_base.nil? && report.past_number.nil? && report.past_date.nil?
        if report.fecha
          doc_text = "Con respecto al informe anterior con fecha #{report.fecha&.strftime('%d/%m/%Y')}:"
        else
          doc_text = "Con respecto al informe anterior con fecha desconocida:"
        end

        doc2 = DocxReplace::Doc.new(output_path, "#{Rails.root}/tmp")
        doc2.replace('{{informe_anterior}}',               doc_text)
        doc2.replace('{{revision_past_errors_level}}',     '')
        doc2.replace('{{revision_past_errors_level_lift}}', '')
        doc2.commit(output_path)
      elsif !exists_last_levels && report.past_number.nil? && report.past_date.nil?
        doc2 = DocxReplace::Doc.new(output_path, "#{Rails.root}/tmp")
        doc2.replace('{{informe_anterior}}',                'Informe anterior sin defectos registrados')
        doc2.replace('{{revision_past_errors_level}}',     '')
        doc2.replace('{{revision_past_errors_level_lift}}','')
        doc2.commit(output_path)
      else
        control_leves = false

        last_revision_entries.each do |e|
          if e.level.to_s.strip == 'L'
            control_leves = true
            if revision_pairs_set.include?([e.code, e.point])
              last_errors << "#{e.code} #{e.point}"
            else
              last_errors_lift << "#{e.code} #{e.point}"
            end
          end
        end

        formatted_errors_lift = last_errors_lift.map do |le|
          "• #{le}\n                                                                                        "
        end.join("\n")

        doc2 = DocxReplace::Doc.new(output_path, "#{Rails.root}/tmp")

        if last_errors.blank?
          if control_leves
            if last_inspection
              texto_numero = "#{last_inspection.number.to_s}-#{last_inspection.ins_date&.strftime('%m')}-#{last_inspection.ins_date&.strftime('%Y')}-#{item_rol}"
              text = "Se levantan todas las conformidades Defectos leves, indicadas en informe anterior N°#{texto_numero} de fecha:#{last_inspection.inf_date&.strftime('%d/%m/%Y')}, las cuales se detallan a continuación:"
            else
              text = 'Informe anterior: defectos leves levantados.'
            end
            doc2.replace('{{informe_anterior}}', text)
          else
            texto_empresa_anterior =
              if report.empresa_anterior
                "Realizado por #{report.empresa_anterior} "
              else
                ''
              end

            if last_inspection&.inf_date
              text = "Informe anterior N°#{last_inspection.number} de fecha: #{last_inspection.inf_date&.strftime('%d/%m/%Y')} #{texto_empresa_anterior}no presenta Defectos leves"
            elsif report.past_date
              text = "Informe anterior N°#{last_inspection&.number} de fecha: #{report.past_date&.strftime('%d/%m/%Y')} #{texto_empresa_anterior}no presenta Defectos leves"
            else
              text = "Informe anterior N°#{last_inspection&.number} de fecha desconocida #{texto_empresa_anterior}no presenta Defectos leves"
            end
            doc2.replace('{{informe_anterior}}', text)
          end

          doc2.replace('{{revision_past_errors_level}}',      '')
          doc2.replace('{{revision_past_errors_level_lift}}', formatted_errors_lift)
        else
          formatted_errors = last_errors.map do |le|
            "• #{le}\n                                                                                        "
          end.join("\n")

          last_inspection_obj = last_inspection || (last_revision_base && Inspection.find(last_revision_base.inspection_id))

          if last_inspection_obj&.number.to_i > 0
            texto_numero = "#{last_inspection_obj.number.to_s}-#{last_inspection_obj.ins_date&.strftime('%m')}-#{last_inspection_obj.ins_date&.strftime('%Y')}-#{item_rol}"
            text = "Se mantienen las no conformidades indicadas en informe anterior N°#{texto_numero} de fecha:#{last_inspection_obj.inf_date&.strftime('%d/%m/%Y')}, las cuales se detallan a continuación:"
            doc2.replace('{{informe_anterior}}', text)
            doc2.replace('{{revision_past_errors_level}}',     formatted_errors)
            doc2.replace('{{revision_past_errors_level_lift}}', formatted_errors_lift)
          else
            texto_posible_past = ''
            if report.cert_ant == 'Si'
              if report.past_number
                texto_posible_past = " N°#{report.past_number} con fecha "
              else
                texto_posible_past = ' de número desconocido con fecha '
              end

              if report.past_date
                texto_posible_past += report.past_date&.strftime('%d/%m/%Y')
              else
                texto_posible_past += 'desconocida'
              end

              if report.past_number.nil? && report.past_date.nil?
                texto_posible_past = ' de número y fecha desconocida'
              end
            end

            if report.empresa_anterior == 'S/I'
              doc2.replace('{{informe_anterior}}', "Se mantienen las no conformidades indicadas en informe anterior#{texto_posible_past} realizado por empresa sin identificar, las cuales se detallan a continuación:")
            else
              doc2.replace('{{informe_anterior}}', "Se mantienen las no conformidades indicadas en informe anterior#{texto_posible_past} realizado por #{report.empresa_anterior}, las cuales se detallan a continuación:")
            end
            doc2.replace('{{revision_past_errors_level}}',     formatted_errors)
            doc2.replace('{{revision_past_errors_level_lift}}', formatted_errors_lift)
          end
        end

        doc2.commit(output_path)
      end
    else
      doc2 = DocxReplace::Doc.new(output_path, "#{Rails.root}/tmp")
      doc2.replace('{{informe_anterior}}',               'No existe información de informe anterior')
      doc2.replace('{{revision_past_errors_level}}',     '')
      doc2.replace('{{revision_past_errors_level_lift}}','')
      doc2.commit(output_path)
    end



    carpetas = rules.map(&:code).select { |c| c.to_s.start_with?('0.') }.uniq.sort

    revision_nulls = RevisionNull.where(revision_id: revision_base.id, revision_type: 'PlatRevision')
                                 .where('point LIKE ?', '0%')
    revision_nulls_total = RevisionNull.where(revision_id: revision_base.id, revision_type: 'PlatRevision')
                                       .where('point NOT LIKE ?', '0%')

    comments_hash = {}

    revision_entries.each do |e|
      if carpetas.include?(e.code)
        comments_hash[e.code] = e.comment
      end
    end

    revision_nulls.each do |null|
      numeric_code = null.point.to_s.split('_').first
      comments_hash[numeric_code] = null.comment if carpetas.include?(numeric_code)
    end

    ordered_comments = carpetas.map { |code| comments_hash[code] || '' }

    carpetas.each_with_index do |carpeta, index|
      entry = revision_entries.find { |e| e.code == carpeta }

      doc3 = DocxReplace::Doc.new(output_path, "#{Rails.root}/tmp")

      if entry
        doc3.replace('{{carpeta_si}}',         'No')
        doc3.replace('{{carpeta_no_aplica}}',  '')
        if entry.level.to_s.strip == 'L'
          doc3.replace('{{carpeta_f}}', 'FL')
        else
          doc3.replace('{{carpeta_f}}', 'FG')
        end
        doc3.replace('{{carpeta_comentario}}', ordered_comments[index])
      elsif revision_nulls.any? { |null| null.point.to_s.start_with?("#{carpeta}_") }
        doc3.replace('{{carpeta_si}}',         '')
        doc3.replace('{{carpeta_f}}',          '')
        doc3.replace('{{carpeta_comentario}}', ordered_comments[index])
        doc3.replace('{{carpeta_no_aplica}}',  'X')
      else
        doc3.replace('{{carpeta_si}}',         'Si')
        doc3.replace('{{carpeta_no_aplica}}',  '')
        doc3.replace('{{carpeta_f}}',          '')
        doc3.replace('{{carpeta_comentario}}', '')
      end

      doc3.commit(output_path)
    end


    section_labels =
      case group.secondary_type
      when 'plataforma'
        [
          '•0.  Caja del elevador y cerramiento.',
          '•1.  Plataforma.',
          '•2.  Carga y velocidad.',
          '•3.  Sistemas de seguridad.',
          '•4.  Puertas de piso.',
          '•5.  Instalación eléctrica.',
          '•6.  Señalización e información.',
          '•7.  Verificaciones finales.',
          '•8.  Tracción y Mantenimiento.'
        ]
      when 'salvaescala'
        [
          '•0.  Diseño general y construcción.',
          '•1.  Rieles guía y topes mecánicos.',
          '•2.  Paracaídas y detección de exceso de velocidad.',
          '•3.  Sistema de accionamiento y frenado.',
          '•4.  Instalación eléctrica y controles.',
          '•5.  Vehículo (silla, plataforma).',
          '•6.  Señalización y marcado.'
        ]
      else
        []
      end

    section_indices = (0...section_labels.length).to_a

    sections_with_fail = revision_entries.map do |e|
      e.code.to_s.split('.').first.to_i
    end.to_set

    cumple    = []
    no_cumple = []

    section_indices.each do |idx|
      if sections_with_fail.include?(idx)
        no_cumple << idx
      else
        cumple << idx
      end
    end

    aux = section_labels
    cumple_text = cumple.map { |index| "#{aux[index]}\n                                                                                        " }.join("\n")
    no_cumple_text = no_cumple.map { |index| "#{aux[index]}\n                                                                                         " }.join("\n")

    if revision_nulls.count == carpetas.size
      cumple_text.gsub!(/^•0\..*$/, '')
      no_cumple_text.gsub!(/^•0\..*$/, '')
    end

    aux[1..-1].each do |item_text|
      match = item_text.match(/•(\d+)\./)
      next unless match
      number = match[1]
      rules_count = rules_for_table.select { |rule| rule.code.to_s.start_with?(number) }.count
      revision_nulls_count = revision_nulls_total.select { |rev| rev.point.to_s.start_with?(number) }.count

      if rules_count > 0 && rules_count == revision_nulls_count
        cumple_text.gsub!(item_text, '')
        no_cumple_text.gsub!(item_text, '')
      end
    end

    doc_1_1_template = Rails.root.join('app', 'templates', 'template_1.1.docx')
    doc_1_1          = DocxReplace::Doc.new(doc_1_1_template, "#{Rails.root}/tmp")

    doc_1_1.replace('{{inspection_place}}', inspection.place)
    doc_1_1.replace('{{ins_place}}',        inspection.place)

    if inspection.result == 'Aprobado'
      doc_1_1.replace('{{buen/mal}}', 'buen')
    elsif inspection.result == 'Rechazado'
      doc_1_1.replace('{{buen/mal}}', 'mal')
    end

    if cumple.any?
      doc_1_1.replace('{{lista_comprobacion_cumple}}', cumple_text)
      doc_1_1.replace('{{texto_comprobacion_cumple}}', 'De acuerdo a esta inspección, CUMPLE, con los requisitos normativos evaluados:')
    else
      doc_1_1.replace('{{lista_comprobacion_cumple}}', '')
      doc_1_1.replace('{{texto_comprobacion_cumple}}', 'De acuerdo a esta inspección, NO CUMPLE con ningún requisito normativo')
    end

    if no_cumple.any?
      doc_1_1.replace('{{lista_comprobacion_no_cumple}}', no_cumple_text)
      doc_1_1.replace('{{texto_comprobacion_no_cumple}}', "El equipo inspeccionado, identificado en el ítem II, ubicado en #{inspection.place}, NO CUMPLE, con los siguientes requisitos normativos, detectándose no-conformidades:")
    else
      doc_1_1.replace('{{lista_comprobacion_no_cumple}}', '')
      doc_1_1.replace('{{texto_comprobacion_no_cumple}}', 'No se encontraron no conformidades en la inspección.')
    end

    if errors_graves.any?
      doc_1_1.replace('{{si_las_hubiera_grave}}', 'Las no conformidades, Defectos Graves, encontradas en la inspección son las siguientes:')
    else
      doc_1_1.replace('{{si_las_hubiera_grave}}', 'No se encontraron defectos graves en la inspección.')
    end

    if errors_leves.any?
      doc_1_1.replace('{{si_las_hubiera_leve}}', 'Las no conformidades, Defectos Leves, encontradas en la inspección son las siguientes:')
    else
      doc_1_1.replace('{{si_las_hubiera_leve}}', 'No se encontraron defectos leves en la inspección.')
    end

    output_path_1_1 = Rails.root.join('tmp', "#{inspection.number}_part1.1.docx")
    doc_1_1.commit(output_path_1_1)

    Omnidocx::Docx.merge_documents([output_path, output_path_1_1], output_path, false)

    if errors_graves.any?
      template_2_path = Rails.root.join('app', 'templates', 'template_2.docx')
      errors_graves.each_with_index do |error, index|
        doc_g = DocxReplace::Doc.new(template_2_path, "#{Rails.root}/tmp")
        doc_g.replace('{{revision_errors}}', error)
        out_g = Rails.root.join('tmp', "#{inspection.number}_grave_#{index}.docx")
        doc_g.commit(out_g)
        Omnidocx::Docx.merge_documents([output_path, out_g], output_path, false)
        File.delete(out_g) if File.exist?(out_g)
      end
    end

    if errors_leves.any?
      template_2_path = Rails.root.join('app', 'templates', 'template_2.docx')
      errors_leves.each_with_index do |error, index|
        doc_l = DocxReplace::Doc.new(template_2_path, "#{Rails.root}/tmp")
        doc_l.replace('{{revision_errors}}', error)
        out_l = Rails.root.join('tmp', "#{inspection.number}_leve_#{index}.docx")
        doc_l.commit(out_l)
        Omnidocx::Docx.merge_documents([output_path, out_l], output_path, false)
        File.delete(out_l) if File.exist?(out_l)
      end
    end



    month_number = report.ending&.month
    months = {
      1  => 'Enero',   2  => 'Febrero', 3  => 'Marzo',
      4  => 'Abril',   5  => 'Mayo',    6  => 'Junio',
      7  => 'Julio',   8  => 'Agosto',  9  => 'Septiembre',
      10 => 'Octubre', 11 => 'Noviembre', 12 => 'Diciembre'
    }
    month_name = month_number ? months[month_number] : ''

    condicion =
      if inspectors.second
        admin.real_name == inspectors.first.real_name ||
          admin.real_name == inspectors.second.real_name ||
          (admin.email.present? && inspectors.first.email.present? && admin.email == inspectors.first.email) ||
          (admin.email.present? && inspectors.second.email.present? && admin.email == inspectors.second.email)
      else
        admin.real_name == inspectors.first.real_name ||
          (admin.email.present? && inspectors.first.email.present? && admin.email == inspectors.first.email)
      end

    template_3_path =
      if inspectors.second && !condicion
        Rails.root.join('app', 'templates', 'template_3.docx')
      elsif !inspectors.second && condicion
        Rails.root.join('app', 'templates', 'template_3_0user.docx')
      else
        Rails.root.join('app', 'templates', 'template_3_1user.docx')
      end

    doc_3 = DocxReplace::Doc.new(template_3_path, "#{Rails.root}/tmp")

    if revision_entries.all? { |e| e.level.to_s.blank? }
      doc_3.replace('{{cumple/parcial/no_cumple}}', 'cumple')
      doc_3.replace('{{esta/no_esta}}',             'está')
      doc_3.replace('{{texto_grave}}',              '')
      doc_3.replace('{{texto_leve}}',               '')
    elsif errors_graves.any?
      doc_3.replace('{{cumple/parcial/no_cumple}}', 'no cumple')
      doc_3.replace('{{esta/no_esta}}',             'no está')
      doc_3.replace('{{texto_grave}}',
                    'Las No Conformidades evaluadas como Defectos Graves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas dentro de 90 días desde la fecha del informe de inspección.')

      if errors_leves.any?
        doc_3.replace('{{texto_leve}}',
                      "Las No Conformidades evaluadas como Defectos Leves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas antes de la próxima CERTIFICACION en #{month_name} del año #{report.ending&.year}.")
      else
        doc_3.replace('{{texto_leve}}', '')
      end
    else # sólo leves
      doc_3.replace('{{cumple/parcial/no_cumple}}', 'cumple parcialmente')
      doc_3.replace('{{esta/no_esta}}',             'está')
      doc_3.replace('{{texto_grave}}',              '')
      doc_3.replace('{{texto_leve}}',
                    "Las No Conformidades evaluadas como Defectos Leves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas antes de la próxima CERTIFICACION en #{month_name} del año #{report.ending&.year}.")
    end

    doc_3.replace('{{admin}}',              admin.real_name)
    doc_3.replace('{{admin_profesion}}',    admin.profesion.to_s)
    doc_3.replace('{{inspector}}',          inspectors.first.real_name)
    doc_3.replace('{{inspector_profesion}}', inspectors.first.profesion.to_s)

    if inspectors.second
      doc_3.replace('{{inspector}}',          inspectors.second.real_name)
      doc_3.replace('{{inspector_profesion}}', inspectors.second.profesion.to_s)
    end

    doc_3.replace('{{y_inspector}}', condicion ? 'Inspector y ' : '')

    output_path_3 = Rails.root.join('tmp', "#{inspection.number}_part3.docx")
    doc_3.commit(output_path_3)

    Omnidocx::Docx.merge_documents([output_path, output_path_3], output_path, false)
    File.delete(output_path_3) if File.exist?(output_path_3)





    if group.secondary_type == 'plataforma'

      tabla_path = Rails.root.join('app', 'templates', 'tabla_plataforma.docx')

    elsif group.secondary_type == "salvaescala"

      tabla_path = Rails.root.join('app', 'templates', 'tabla_salvaescala.docx')

    end


    Omnidocx::Docx.merge_documents([output_path, tabla_path], output_path, true)

    doc_table = DocxReplace::Doc.new(output_path, "#{Rails.root}/tmp")

    rules_table_final = rules_for_table.reject { |r| r.code.to_s.start_with?('0.') }

    rules_table_final.each do |rule|
      entry = revision_by_code_point[[rule.code, rule.point]]
      last_entry = last_by_code_point[[rule.code, rule.point]]

      if entry
        doc_table.replace('{{tabla_si}}', 'NO')

        if entry.level.to_s.strip == 'L'
          doc_table.replace('{{tabla_l}}', 'Leve')
        else
          if last_entry && last_entry.level.to_s.strip != 'L'
            doc_table.replace('{{tabla_l}}', 'Grave (repite)')
          else
            doc_table.replace('{{tabla_l}}', 'Grave')
          end
        end

        if entry.comment.present?
          doc_table.replace('{{tabla_comentario}}', "(#{entry.comment})")
        else
          doc_table.replace('{{tabla_comentario}}', '')
        end
      elsif revision_nulls_total.any? { |null| null.point == "#{rule.code}_#{rule.point}" }
        doc_table.replace('{{tabla_si}}', 'N/A')
        doc_table.replace('{{tabla_l}}', '')
        doc_table.replace('{{tabla_comentario}}', '')
      else
        doc_table.replace('{{tabla_si}}', 'SI')
        doc_table.replace('{{tabla_l}}', '')
        doc_table.replace('{{tabla_comentario}}', '')
      end
    end

    doc_table.replace('{{tabla_aplica1}}', '')
    doc_table.replace('{{tabla_aplica2}}', '')
    doc_table.replace('{{tabla_aplica3}}', '')


    sections_present = rules_for_table.map { |r| r.code.to_s.split('.').first.to_i }.uniq.sort - [0]

    sections_present.each do |section_number|

      matching_rules = additional_rules.select do |rule|
        rule.code.to_s.split('.').first.to_i == section_number
      end

      if matching_rules.any?
        doc_table.replace('{{another_si}}', 'No')

        final_level_text = 'Leve'
        has_grave = false
        has_repite = false

        matching_rules.each do |rule|
          entry = revision_by_code_point[[rule.code, rule.point]]
          last_entry = last_by_code_point[[rule.code, rule.point]]

          if entry
            if entry.level.to_s.strip != 'L'
              has_grave = true
              if last_entry && last_entry.level.to_s.strip != 'L'
                has_repite = true
              end
            end
          end
        end

        if has_repite
          final_level_text = 'Grave (repite)'
        elsif has_grave
          final_level_text = 'Grave'
        end

        doc_table.replace('{{another_l}}', final_level_text)

        comentarios_concatenados = matching_rules.map do |rule|
          entry = revision_by_code_point[[rule.code, rule.point]]
          if entry && entry.comment.present?
            "(#{rule.point}: #{entry.comment})"
          else
            "(#{rule.point}: Sin comentario)"
          end
        end.join(" ")

        doc_table.replace('{{another_comentario}}', comentarios_concatenados)

      else

        doc_table.replace('{{another_si}}', 'Si')
        doc_table.replace('{{another_l}}', '')
        doc_table.replace('{{another_comentario}}', '')
      end
    end

    doc_table.commit(output_path)

    Dir.glob("#{Rails.root}/tmp/#{inspection.number}_part*").each do |file_path|
      File.delete(file_path) if File.exist?(file_path)
    end

    general_photos    = revision_base.revision_photos.ordered_by_code.select { |photo| photo.code.to_s.start_with?('GENERALCODE') }
    non_general_photos = revision_base.revision_photos.ordered_by_code.reject { |photo| photo.code.to_s.start_with?('GENERALCODE') }

    revision_photos = general_photos + non_general_photos

    Omnidocx::Docx.replace_footer_content(
      { '{{month}}' => inspection.ins_date&.strftime('%m'),
        '{{year}}'  => inspection.ins_date&.strftime('%Y'),
        '{{rol}}'   => item_rol },
      output_path, output_path
    )

    Omnidocx::Docx.replace_footer_content(
      { '{{XXX}}' => inspection.number.to_s },
      output_path, output_path
    )

    if revision_photos.any?
      dir_name = "imagenes_#{inspection.number}"
      dir_path = File.join(Rails.root, 'tmp', dir_name)
      FileUtils.mkdir_p(dir_path)

      docx_basename = File.basename(output_path)
      docx_new_path = File.join(dir_path, docx_basename)
      FileUtils.mv(output_path, docx_new_path)

      photos_mapping = []
      counter        = 1

      revision_photos.each do |photo|
        next unless photo.photo.attached?

        original_ext = File.extname(photo.photo.blob.filename.to_s)
        ext          = original_ext.empty? ? '.jpg' : original_ext

        new_filename  = "#{counter}#{ext}"
        new_file_path = File.join(dir_path, new_filename)

        File.open(new_file_path, 'wb') do |file|
          file.write(photo.photo.download)
        end

        text_imagen_comment = nil
        unless photo.code.to_s.start_with?('GENERALCODE')
          temp_code, temp_point = photo.code.to_s.split(' ', 2)
          entry = revision_by_code_point[[temp_code, temp_point]]
          text_imagen_comment = entry&.comment
        end

        final_code_text = photo.code.to_s.sub('GENERALCODE', '')
        final_text =
          if text_imagen_comment.present?
            "#{final_code_text} #{text_imagen_comment}"
          else
            final_code_text
          end

        photos_mapping << {
          'filename' => new_filename,
          'text'     => final_text.strip
        }

        counter += 1
      end

      mapping_json_path = File.join(dir_path, 'mapping.json')
      File.write(mapping_json_path, photos_mapping.to_json)

      venv_python = Rails.root.join('ascensor', 'bin', 'python').to_s
      script_path = Rails.root.join('app', 'scripts', 'insertar_imagenes.py').to_s
      token       = 'CODIGO IMAGEN 24123123'

      cmd = "#{venv_python} \"#{script_path}\" --folder \"#{dir_path}\" --docx \"#{docx_basename}\" --token \"#{token}\""
      system(cmd)

      FileUtils.mv(docx_new_path, output_path)
      FileUtils.rm_rf(dir_path)
    else
      doc_final = DocxReplace::Doc.new(output_path, "#{Rails.root}/tmp")
      doc_final.replace('CODIGO IMAGEN 24123123', '')
      doc_final.commit(output_path)
    end

    output_path
  end

  private

  def self.prepare_images_for_document(plat_revision_id, code)
    revision_photos = RevisionPhoto.where(revision_id: plat_revision_id,
                                          code: code,
                                          revision_type: 'PlatRevision')

    max_width_per_image = 400

    revision_photos.map do |revision_photo|
      next unless revision_photo.photo.attached?

      temp_path = save_temp_image(revision_photo.photo)
      {
        path:   temp_path,
        height: 250,
        width:  max_width_per_image
      }
    end.compact
  end

  def self.save_temp_image(attachment)
    temp_dir = Rails.root.join('tmp', 'images')
    FileUtils.mkdir_p(temp_dir) unless Dir.exist?(temp_dir)

    temp_path = File.join(temp_dir, attachment.filename.to_s)

    File.open(temp_path, 'wb') do |file|
      file.write(attachment.download)
    end

    temp_path
  end

  def self.cleanup_temporary_images(images_to_write)
    images_to_write.each do |image|
      File.delete(image[:path]) if File.exist?(image[:path])
    end
  end
end