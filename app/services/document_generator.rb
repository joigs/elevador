
require 'docx_replace'
require 'omnidocx'
require 'fileutils'
require 'mini_magick'
require 'tempfile'
require 'securerandom'
require 'fileutils'
require 'open3'
require "ostruct"



class DocumentGenerator
  def self.generate_document(inspection_id, principal_id, revision_id, item_id, admin_id)
    inspection = Inspection.find(inspection_id)
    principal = Principal.find(principal_id)
    revision_base = Revision.find(revision_id)
    item = Item.find(item_id)
    group = item.group
    detail = item.detail
    report = Report.find_by(inspection_id: inspection.id)
    admin = User.find(admin_id)
    inspectors = inspection.users

    rules = group.rules.to_a


    anothers = Another.where(item_id: item.id)

    additional_rules = anothers.map do |another|
      Rule.new(
        point: another.point,
        level: another.level,
        code: another.code,
        ins_type: another.ins_type,
        ruletype: another.ruletype
      )
    end


    rules += additional_rules


    rules.sort_by! do |rule|

      code_parts = rule.code.split('.')
      [
        code_parts[0].to_i,
        code_parts[1].to_i,
        code_parts[2].to_i,
        code_parts[3].to_i
      ]
    end

    rules = rules.drop(11)





    item_rol = item.identificador.chars.last(4).join


    revision = OpenStruct.new(codes: [], points: [], levels: [], comment: [])

    revision_base.revision_colors.order(:section).each do |revision_color|
      revision.codes.concat(revision_color.codes || [])
      revision.points.concat(revision_color.points || [])
      revision.levels.concat(revision_color.levels || [])
      revision.comment.concat(revision_color.comment || [])
    end


    template_path = Rails.root.join('app', 'templates', 'template_1.docx')

    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")

    doc.replace('{{XXX}}', inspection.number.to_s)
    doc.replace('{{MM}}', inspection.ins_date&.strftime('%m'))
    doc.replace('{{XX}}', inspection.ins_date&.strftime('%Y'))
    doc.replace('{{rol}}', item_rol)

    doc.replace('{{principal_name}}', principal.name)
    doc.replace('{{principal_business_name}}', principal.business_name)
    doc.replace('{{principal_rut}}', principal.rut)


    if principal.contact_name
      doc.replace('{{principal_contact_name}}', principal.contact_name)
    else
      doc.replace('{{principal_contact_name}}', "S/I")
    end

    doc.replace('{{principal_email}}', principal.email)


    if principal.phone
      doc.replace('{{principal_phone}}', principal.phone)
    else
      doc.replace('{{principal_phone}}', "S/I")
    end




    if principal.cellphone
      doc.replace('{{principal_cellphone}}', principal.cellphone)
    else
      doc.replace('{{principal_cellphone}}', "S/I")
    end


    if principal.contact_email
      doc.replace('{{principal_contact_email}}', principal.contact_email)
    else
      doc.replace('{{principal_contact_email}}', "S/I")
    end


    if principal.place
      doc.replace('{{principal_place}}', principal.place)
    else
      doc.replace('{{principal_place}}', "S/I")
    end


    doc.replace('{{inspection_place}}', inspection.place)
    doc.replace('{{ins_date}}', inspection.ins_date&.strftime('%d/%m/%Y'))

    inspector_names = inspection.users.map(&:real_name).join(' / ')


    doc.replace('{{inspector}}', inspector_names)



    doc.replace('{{admin}}', admin.real_name)
    doc.replace('{{inf_date}}', inspection.inf_date&.strftime('%d/%m/%Y') || '')

    doc.replace('{{inspection_validation}}', report.ending&.strftime('%d/%m/%Y'))

    if report.cert_ant == 'Si' || report.cert_ant == 'sistema'

      if report.cert_ant_real == 'No'
        doc.replace('{{cert_ant}}', 'No')

      elsif report.cert_ant_real == 'Si'
        doc.replace('{{cert_ant}}', 'Si')
      else
        doc.replace('{{cert_ant}}', 'S/I')
      end


      if report.fecha
        doc.replace('{{report_fecha}}', report.fecha&.strftime('%d/%m/%Y'))
      else
        doc.replace('{{report_fecha}}', 'S/I')
      end



    elsif report.cert_ant == 'No'
      doc.replace('{{cert_ant}}', 'No')
      doc.replace('{{report_fecha}}', '')
    else
      doc.replace('{{cert_ant}}', 'S/I')
      doc.replace('{{report_fecha}}', 'S/I')

    end

    doc.replace('{{instalation_number}}', item.identificador)

    if revision.codes.first == '0.1.1'
      doc.replace('{{certificado_minvu}}', "No cumple")
    else
      doc.replace('{{certificado_minvu}}', report.certificado_minvu)
    end







    if report.empresa_anterior
      doc.replace('{{empresa_anterior}}', report.empresa_anterior)
    else
      doc.replace('{{empresa_anterior}}', "S/I")
    end


    if report.ea_rol
      doc.replace('{{ea_rol}}', report.ea_rol)
    else
      doc.replace('{{ea_rol}}', "S/I")
    end


    if report.ea_rut
      doc.replace('{{ea_rut}}', report.ea_rut)
    else
      doc.replace('{{ea_rut}}', "S/I")
    end


    doc.replace('{{empresa_mantenedora}}', report.empresa_mantenedora)
    doc.replace('{{em_rol}}', report.em_rol)
    doc.replace('{{em_rut}}', report.em_rut)
    aux_date = report.vi_co_man_ini&.strftime('%d/%m/%Y') || 'S/I'
    doc.replace('{{vi_co_man_ini}}', aux_date)
    aux_date = report.vi_co_man_ter&.strftime('%d/%m/%Y') || 'S/I'
    doc.replace('{{vi_co_man_ter}}', aux_date)
    doc.replace('{{nom_tec_man}}', report.nom_tec_man)
    doc.replace('{{tm_rut}}', report.tm_rut)

    if report.ul_reg_man
      doc.replace('{{ul_reg_man}}', report.ul_reg_man)
    else
      doc.replace('{{ul_reg_man}}', "S/I")
    end

    aux_date = report.urm_fecha&.strftime('%d/%m/%Y') || 'S/I'
    doc.replace('{{urm_fecha}}', aux_date)
    doc.replace('{{item_identificador}}', item.identificador)
    doc.replace('{{detail_detalle}}', detail.detalle)
    doc.replace('{{detail_marca}}', detail.marca)
    doc.replace('{{detail_modelo}}', detail.modelo)
    doc.replace('{{detail_n_serie}}', detail.n_serie)

    if detail.velocidad
      doc.replace('{{detail_velocidad}}', "#{detail.velocidad} m/s")
    else
      doc.replace('{{detail_velocidad}}', "S/I")
    end

    doc.replace('{{detail_rol_n}}', detail.rol_n)

    if detail.numero_permiso
      doc.replace('{{detail_numero_permiso}}', "N°#{detail.numero_permiso}")
    else
      doc.replace('{{detail_numero_permiso}}', "S/I")
    end

    if detail.fecha_permiso
      doc.replace('{{detail_fecha_permiso}}', detail.fecha_permiso&.strftime('%d/%m/%Y'))
    else
      doc.replace('{{detail_fecha_permiso}}', "S/I")
    end

    doc.replace('{{detail_destino}}', detail.destino)

    if detail.recepcion
      doc.replace('{{detail_recepcion}}', detail.recepcion)
    else
      doc.replace('{{detail_recepcion}}', "S/I")
    end

    doc.replace('{{detail_empresa_instaladora}}', detail.empresa_instaladora)
    if !detail.empresa_instaladora_rut.blank?
      doc.replace('{{detail_empresa_instaladora_rut}}', detail.empresa_instaladora_rut)
    else
      doc.replace('{{detail_empresa_instaladora_rut}}', "S/I")
    end

    if detail.porcentaje
      doc.replace('{{detail_porcentaje}}', "#{detail.porcentaje.to_s}%")
    else
      doc.replace('{{detail_porcentaje}}', "S/I")
    end

    doc.replace('{{detail_descripcion}}', detail.descripcion)



    if group.number == 1
      doc.replace('{{grupo}}', 'Grupo 1')
    elsif group.number == 2

      doc.replace('{{grupo}}', 'Grupo 2')
    elsif group.number == 3
      doc.replace('{{grupo}}', 'Grupo 3')
    else
      doc.replace('{{grupo}}', 'S/I')
    end
    doc.replace('{{detail_mm_marca}}', detail.mm_marca)
    doc.replace('{{detail_mm_n_serie}}', detail.mm_n_serie)

    if detail.potencia
      doc.replace('{{detail_potencia}}', "#{detail.potencia} Kw")
    else
      doc.replace('{{detail_potencia}}', "S/I")

    end

    if detail.capacidad
      doc.replace('{{detail_capacidad}}', " #{detail.capacidad} Kg")
    else
      doc.replace('{{detail_capacidad}}', " S/I")
    end


    if detail.personas
      doc.replace('{{detail_personas}}', detail.personas)
    else
      doc.replace('{{detail_personas}}', "S/I")
    end
    doc.replace('{{detail_ct_marca}}', detail.ct_marca)

    if detail.ct_cantidad
      doc.replace('{{detail_ct_cantidad}}', "#{detail.ct_cantidad} unidades")
    else
      doc.replace('{{detail_ct_cantidad}}', "S/I")
    end

    if detail.ct_diametro
      doc.replace('{{detail_ct_diametro}}', "#{detail.ct_diametro} mm")
    else
      doc.replace('{{detail_ct_diametro}}', "S/I")

    end


    if detail.medidas_cintas
      doc.replace('{{detail_medidas_cintas}}', "#{detail.medidas_cintas} mm")
    else
      doc.replace('{{detail_medidas_cintas}}', "S/I")

    end

    if detail.medidas_cintas_espesor
      doc.replace('{{detail_medidas_cintas_espesor}}', "#{detail.medidas_cintas_espesor} mm")
    else
      doc.replace('{{detail_medidas_cintas_espesor}}', "S/I")

    end

    doc.replace('{{detail_rv_marca}}', detail.rv_marca)
    doc.replace('{{detail_rv_n_serie}}', detail.rv_n_serie)

    if detail.paradas
      doc.replace('{{detail_paradas}}', detail.paradas)
    else
      doc.replace('{{detail_paradas}}', "S/I")
    end


    if detail.embarques
      doc.replace('{{detail_embarques}}', detail.embarques)
    else
      doc.replace('{{detail_embarques}}', "S/I")
    end

    if detail.sala_maquinas == "Si"
      doc.replace('{{detail_sala_maquinas}}', "Si")
    else
      doc.replace('{{detail_sala_maquinas}}', "No")

    end

    doc.replace('{{detail_sala_maquinas}}', detail.sala_maquinas)


    if item.group.number <=3
      doc.replace('{{item_group}}', item.group.number.to_s)
    else
      doc.replace('{{item_group}}', item.group.name)
    end

    if item.group.number == 1
      doc.replace('{{normas_de_referencia}}', 'NCh.3395/1:2016 y NCh.440/2:2001')

    elsif item.group.number == 2
      doc.replace('{{normas_de_referencia}}', 'NCh 440/1 :2000 y NCh440/2 :2001.')

    elsif item.group.number == 3
      doc.replace('{{normas_de_referencia}}', 'NCh 440/1 :2014 y NCh 440/2 :2001 y NCh 3362.')
    end
    sorted_inspections = item.inspections.sort_by do |inspection|
      [-inspection.number.abs, inspection.number < 0 ? 1 : 0]
    end

    last_inspection = sorted_inspections[1]

    if last_inspection
      last_revision_base = Revision.find_by(inspection_id: last_inspection.id)

    end



    if last_revision_base
      last_revision = OpenStruct.new(codes: [], points: [], levels: [], comment: [])


      last_revision_base.revision_colors.order(:section).each do |revision_color|
        last_revision.codes.concat(revision_color.codes || [])
        last_revision.points.concat(revision_color.points || [])
        last_revision.levels.concat(revision_color.levels || [])
        last_revision.comment.concat(revision_color.comment || [])
      end
    end




    last_errors = []
    last_errors_lift = []


    if report.cert_ant == 'Si' || report.cert_ant == 'sistema'

      if last_revision.nil?

        if report.fecha
          doc.replace('{{informe_anterior}}', "Con respecto al informe anterior con fecha #{report.fecha&.strftime('%d/%m/%Y')}:")
        else
          doc.replace('{{informe_anterior}}', "Con respecto al informe anterior con fecha desconocida:")
        end

        doc.replace('{{revision_past_errors_level}}', "")
        doc.replace('{{revision_past_errors_level_lift}}', "")

      end

      if last_revision&.levels.blank?
        doc.replace('{{informe_anterior}}', "Informe anterior sin  registrados")
        doc.replace('{{revision_past_errors_level}}', "")
        doc.replace('{{revision_past_errors_level_lift}}', "")

      else

        control9384 = false

        last_revision.levels.each_with_index do |level, index|

          if level == "L"
            control9384 = true


            if revision.codes.include?(last_revision.codes[index])
              if revision.points.include?(last_revision.points[index])
                last_errors << last_revision.codes[index] + " " + last_revision.points[index]
              else
                last_errors_lift << last_revision.codes[index] + " " + last_revision.points[index]
              end
            else
              last_errors_lift << last_revision.codes[index] + " " + last_revision.points[index]
            end
          end

        end

        formatted_errors_lift = last_errors_lift.map { |last_error_lift| "• #{last_error_lift}\n                                                                                   " }.join("\n")


        if last_errors.blank?

          if control9384 == true
            doc.replace('{{informe_anterior}}', "Se levantan todas las conformidades Defectos leves, indicadas en informe anterior N°#{last_inspection.number} de fecha:#{last_inspection.inf_date&.strftime('%d/%m/%Y')}, las cuales se detallan a continuación:")

          else
            doc.replace('{{informe_anterior}}', "Informe anterior N°#{last_inspection.number} de fecha:#{last_inspection.inf_date&.strftime('%d/%m/%Y')} no presenta Defectos leves")

          end

          doc.replace('{{revision_past_errors_level}}', "")
          doc.replace('{{revision_past_errors_level_lift}}', formatted_errors_lift)


        else
          last_inspection = Inspection.find(last_revision_base.inspection_id)
          formatted_errors = last_errors.map { |last_error| "• #{last_error}\n                                                                                   " }.join("\n")

          if last_inspection.number > 0
            last_inspection_inf_date = last_inspection.inf_date

            doc.replace('{{informe_anterior}}', "Se mantienen las no conformidades indicadas en informe anterior N°#{last_inspection.number} de fecha:#{last_inspection_inf_date&.strftime('%d/%m/%Y')}, las cuales se detallan a continuación:")
            doc.replace('{{revision_past_errors_level}}', formatted_errors)
            doc.replace('{{revision_past_errors_level_lift}}', formatted_errors_lift)
          else

            texto_posible_past = ""

            if report.cert_ant == 'Si'

              if report.past_number
                texto_posible_past = " N°#{report.past_number} con fecha "
              else
                texto_posible_past = " de número desconocido con fecha "
              end

              if report.past_date
                texto_posible_past += report.past_date&.strftime('%d/%m/%Y')
              else
                texto_posible_past += "desconocida"
              end

              if !report.past_number && !report.past_date
                texto_posible_past = " de número y fecha desconocida"
              end

            end

            if report.empresa_anterior=="S/I"
              doc.replace('{{informe_anterior}}', "Se mantienen las no conformidades indicadas en informe anterior#{texto_posible_past} realizado por empresa sin identificar, las cuales se detallan a continuación:")
            else
              doc.replace('{{informe_anterior}}', "Se mantienen las no conformidades indicadas en informe anterior#{texto_posible_past} realizado por #{report.empresa_anterior}, las cuales se detallan a continuación:")
            end
            doc.replace('{{revision_past_errors_level}}', formatted_errors)
            doc.replace('{{revision_past_errors_level_lift}}', formatted_errors_lift)
          end


        end
      end

      else
        doc.replace('{{informe_anterior}}', "No existe información de informe anterior")
        doc.replace('{{revision_past_errors_level}}', "")
        doc.replace('{{revision_past_errors_level_lift}}', "")
    end



    doc.replace('{{grupo_en_titulo}}', group.number)


    if item.group.number == 1
      doc.replace('{{normas_de_referencia_titulo}}', 'NCh.3395/1:2016 y NCh.440/2:2001')

    elsif item.group.number == 2
      doc.replace('{{normas_de_referencia_titulo}}', 'NCh 440/1 :2000 y NCh440/2 :2001.')

    elsif item.group.number == 3
      doc.replace('{{normas_de_referencia_titulo}}', 'NCh 440/1 :2014 y NCh 440/2 :2001 y NCh 3362.')
    end



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

    revision_nulls = RevisionNull.where(revision_id: revision_id, revision_type: 'Revision')
                                 .where("point LIKE ?", "0%")

    revision_nulls_total = RevisionNull.where(revision_id: revision_id, revision_type: 'Revision')
                                       .where("point NOT LIKE ?", "0%")

    comments_hash = {}

    revision.codes.each_with_index do |code, index|
      if carpetas.include?(code)
        comments_hash[code] = revision.comment[index]
      end
    end

    revision_nulls.each do |null|
      numeric_code = null.point.split('_').first
      if carpetas.include?(numeric_code)
        comments_hash[numeric_code] = null.comment
      end
    end

    ordered_comments = carpetas.map { |code| comments_hash[code] || "" }






    carpetas.each_with_index do |carpeta, index|
      indice = revision.codes.find_index(carpeta)
      if indice
        doc.replace('{{carpeta_si}}', 'No')
        doc.replace('{{carpeta_no_aplica}}', '')
        if revision.levels[indice] == 'L'
          doc.replace('{{carpeta_f}}', 'FL')
        else
          doc.replace('{{carpeta_f}}', 'FG')
        end
        doc.replace('{{carpeta_comentario}}', ordered_comments[index])

      elsif revision_nulls.any? { |null| null.point.start_with?("#{carpeta}_") }
        doc.replace('{{carpeta_si}}', '')
        doc.replace('{{carpeta_f}}', '')
        doc.replace('{{carpeta_comentario}}', ordered_comments[index])
        doc.replace('{{carpeta_no_aplica}}', 'X')


      else
        doc.replace('{{carpeta_si}}', 'Si')
        doc.replace('{{carpeta_no_aplica}}', '')
        doc.replace('{{carpeta_f}}', '')
        doc.replace('{{carpeta_comentario}}', '')
      end
    end


    output_path = Rails.root.join('tmp', "Informe N°#{inspection.number.to_s}-#{inspection.ins_date&.strftime('%m')}-#{inspection.ins_date&.strftime('%Y')}-#{item_rol}.docx")
    doc.commit(output_path)


    if inspectors.second
      condicion = admin.real_name == inspectors.first.real_name || admin.real_name == inspectors.second.real_name || (admin.email == inspectors.first.email && admin.email.present? && inspectors.first.email.present?) || (admin.email == inspectors.second.email && admin.email.present? && inspectors.second.email.present?)
    else
      condicion = admin.real_name == inspectors.first.real_name || (admin.email == inspectors.first.email && admin.email.present? && inspectors.first.email.present? )
    end


    template_path = Rails.root.join('app', 'templates', 'template_1.1.docx')



    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")


    doc.replace('{{inspection_place}}', inspection.place)
    doc.replace('{{ins_place}}', inspection.place)
    if inspection.result == 'Aprobado'
      doc.replace('{{buen/mal}}', "buen")
    elsif inspection.result == 'Rechazado'
      doc.replace('{{buen/mal}}', "mal")

    end

    cumple, no_cumple = [], []

    (0..11).each do |index|
      if revision.codes.any? { |code| code.match?(/^#{index}\./) }
        no_cumple <<  index
      else
        cumple << index
      end
    end


      aux = [
        '•0.  Carpeta cero.',
        '•1.  Caja de elevadores.',
        '•2.  Espacio de máquinas y poleas (para ascensores sin cuarto de máquinas aplica cláusula 9).',
        '•3.  Puerta de piso.',
        '•4.  Cabina, contrapeso y masa de equilibrio.',
        '•5.  Suspensión, compensación, protección contra la sobre velocidad y protección contra el movimiento incontrolado de la cabina.',
        '•6.  Guías, amortiguadores y dispositivos de seguridad de final de recorrido.',
        '•7.  Holguras entre cabina y paredes de los accesos, así como entre contrapeso o masa de equilibrado.',
        '•8.  Máquina.',
        '•9.  Ascensor sin sala de máquinas.',
        '•10. Protección contra  eléctricos, mandos y prioridades.',
        '•11. Ascensores con excepciones autorizadas, en los que se hayan realizado modificaciones importantes, o que cumplan normativa particular.'
      ]




    cumple_text = cumple.map { |index| "#{aux[index]}\n                                                                                                                          "}.join("\n")
    no_cumple_text = no_cumple.map { |index| "#{aux[index]}\n                                                                                                                     "}.join("\n")


    # Eliminar el elemento correspondiente en los textos generados
    if detail.sala_maquinas == "Si"
      cumple_text.gsub!('•9.  Ascensor sin sala de máquinas.', '')
      no_cumple_text.gsub!('•9.  Ascensor sin sala de máquinas.', '')
    else
      cumple_text.gsub!('•2.  Espacio de máquinas y poleas (para ascensores sin cuarto de máquinas aplica cláusula 9).', '')
      no_cumple_text.gsub!('•2.  Espacio de máquinas y poleas (para ascensores sin cuarto de máquinas aplica cláusula 9).', '')
    end

    # Eliminar '•0. Carpeta cero.' si revision_nulls tiene 11 elementos
    if revision_nulls.count == 11
      cumple_text.gsub!('•0.  Carpeta cero.', '')
      no_cumple_text.gsub!('•0.  Carpeta cero.', '')
    end

    aux[1..-1].each do |item|
      # Obtener el número entre '•' y el primer '.'
      match = item.match(/•(\d+)\./)
      next unless match # Saltar si no se encuentra un número

      number = match[1] # El número correspondiente

      # Saltar números ya eliminados en lógica anterior (como la de sala_maquinas)
      if detail.sala_maquinas == "Si"
        next if number == "9"
      else
        next if number == "2"
      end

      # Contar rules que empiezan con ese número
      rules_count = rules.select { |rule| rule.code.start_with?(number) }.count

      # Contar revision_nulls_total que empiezan con ese número
      revision_nulls_count = revision_nulls_total.select { |rev| rev.point.start_with?(number) }.count

      # Si la cantidad es igual, eliminar el texto correspondiente
      if rules_count == revision_nulls_count
        cumple_text.gsub!(item, '')
        no_cumple_text.gsub!(item, '')
      end
    end




    if cumple.any?
      doc.replace('{{lista_comprobacion_cumple}}', cumple_text)
      doc.replace('{{texto_comprobacion_cumple}}', 'De acuerdo a esta inspección, CUMPLE, con los requisitos normativos evaluados:')
    else
      doc.replace('{{lista_comprobacion_cumple}}', '')
      doc.replace('{{texto_comprobacion_cumple}}', 'De acuerdo a esta inspección, NO CUMPLE con ningún requisito normativo')
    end

    if no_cumple.any?
      doc.replace('{{lista_comprobacion_no_cumple}}', no_cumple_text)
      doc.replace('{{texto_comprobacion_no_cumple}}', "El equipo inspeccionado, identificado en el ítem II, ubicado en #{inspection.place}, NO CUMPLE, con los siguientes requisitos normativos, detectándose no-conformidades:")
    else
      doc.replace('{{lista_comprobacion_no_cumple}}', '')
      doc.replace('{{texto_comprobacion_no_cumple}}', 'No se encontraron no conformidades en la inspección.')
    end

    errors_graves = []
    errors_leves = []
    errors_all = []

    revision.levels.each_with_index do |level, index|
      if level.include?("G")
        if revision.comment[index].blank?
          errors_graves << ("#{revision.codes[index]} #{revision.points[index]} (No se hizo ningún comentario)")
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} defecto grave. (No se hizo ningún comentario)"

        else
          errors_graves << "#{revision.codes[index]} #{revision.points[index]}. (#{revision.comment[index]})"
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} defecto grave. (#{revision.comment[index]})"

        end
      elsif level.include?("L")
        if revision.comment[index].blank?
          errors_leves << ("#{revision.codes[index]} #{revision.points[index]} (No se hizo ningún comentario)")
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} defecto leve. (No se hizo ningún comentario)"

        else
          errors_leves << "#{revision.codes[index]} #{revision.points[index]}. (#{revision.comment[index]})"
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} defecto leve. (#{revision.comment[index]})"

        end
      end
    end


    if errors_graves.any?
      doc.replace('{{si_las_hubiera_grave}}', 'Las no conformidades, Defectos Graves, encontradas en la inspección son las siguientes:')
    else
      doc.replace('{{si_las_hubiera_grave}}', 'No se encontraron defectos graves en la inspección.')
    end

    output_path1_1 = Rails.root.join('tmp', "#{inspection.number}_part1.1.docx")
    doc.commit(output_path1_1)

    Omnidocx::Docx.merge_documents([output_path, output_path1_1], output_path, false)

    original_files = []
    original_files << output_path1_1

    template_path = Rails.root.join('app', 'templates', 'template_2.docx')



    errors_graves.each_with_index do |error, index|
      doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")
      doc.replace('{{revision_errors}}', error)
      output_path3 = Rails.root.join('tmp', "#{inspection.number}_part2_#{index}.docx")
      doc.commit(output_path3)
      Omnidocx::Docx.merge_documents([output_path, output_path3], output_path, false)
      original_files << output_path3
    end



    template_path = Rails.root.join('app', 'templates', 'template_1.2.docx')

    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")




    if errors_leves.any?
      doc.replace('{{si_las_hubiera_leve}}', 'Las no conformidades, Defectos Leves, encontradas en la inspección son las siguientes:')
    else
      doc.replace('{{si_las_hubiera_leve}}', 'No se encontraron defectos leves en la inspección.')
    end

    output_path1_2 = Rails.root.join('tmp', "#{inspection.number}_part1.2.docx")
    doc.commit(output_path1_2)
    Omnidocx::Docx.merge_documents([output_path, output_path1_2], output_path, false)
    original_files << output_path1_2




    template_path = Rails.root.join('app', 'templates', 'template_2.docx')



    errors_leves.each_with_index do |error, index|
      doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")
      doc.replace('{{revision_errors}}', error)
      output_path3 = Rails.root.join('tmp', "#{inspection.number}_part2_2_#{index}.docx")
      doc.commit(output_path3)
      Omnidocx::Docx.merge_documents([output_path, output_path3], output_path, false)
      original_files << output_path3
    end




    month_number = report.ending.month


    months = {
      1 => "Enero",
      2 => "Febrero",
      3 => "Marzo",
      4 => "Abril",
      5 => "Mayo",
      6 => "Junio",
      7 => "Julio",
      8 => "Agosto",
      9 => "Septiembre",
      10 => "Octubre",
      11 => "Noviembre",
      12 => "Diciembre"
    }

    month_name = months[month_number]



    if inspectors.second && !condicion
      template_path = Rails.root.join('app', 'templates', 'template_3.docx')
    elsif !inspectors.second && condicion
      template_path = Rails.root.join('app', 'templates', 'template_3_0user.docx')
    else
      template_path = Rails.root.join('app', 'templates', 'template_3_1user.docx')
    end


    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")


    if revision.levels.blank?
      doc.replace('{{cumple/parcial/no_cumple}}', "cumple")
      doc.replace('{{esta/no_esta}}', "está")
      doc.replace('{{texto_grave}}', "")
      doc.replace('{{texto_leve}}', "")
    end


    if !errors_graves.empty?
      doc.replace('{{cumple/parcial/no_cumple}}', "no cumple")
      doc.replace('{{esta/no_esta}}', "no está")
      doc.replace('{{texto_grave}}', "Las No Conformidades evaluadas como Defectos Graves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas dentro de 90 días desde la fecha del informe de inspección.")
      if !errors_leves.empty?
        doc.replace('{{texto_leve}}', "Las No Conformidades evaluadas como Defectos Leves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas antes de la próxima CERTIFICACION en #{month_name} del año #{report.ending.year}.")
      else
        doc.replace('{{texto_leve}}', "")
      end

    end

    if !errors_leves.empty? && errors_graves.empty?
      doc.replace('{{cumple/parcial/no_cumple}}', "cumple parcialmente")
      doc.replace('{{esta/no_esta}}', "está")
      doc.replace('{{texto_grave}}', "")
      doc.replace('{{texto_leve}}', "Las No Conformidades evaluadas como Defectos Leves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas antes de la próxima CERTIFICACION en #{month_name} del año #{report.ending.year}.")
    end

    doc.replace('{{admin}}', admin.real_name)
    doc.replace('{{inspector}}', inspectors.first.real_name)


    doc.replace('{{inspector_profesion}}', inspectors.first.profesion)

    if inspectors.second
      doc.replace('{{inspector}}', inspectors.second.real_name)
      doc.replace('{{inspector_profesion}}', inspectors.second.profesion)
    end



    if condicion
      doc.replace('{{y_inspector}}', 'Inspector y ')
    else
      doc.replace('{{y_inspector}}', '')
    end

    doc.replace('{{admin_profesion}}', admin.profesion)


    general_photos = revision_base.revision_photos.ordered_by_code.select { |photo| photo.code.start_with?('GENERALCODE') }
    non_general_photos = revision_base.revision_photos.ordered_by_code.reject { |photo| photo.code.start_with?('GENERALCODE') }

    # Combina ambas colecciones, con las que empiezan por GENERALCODE primero
    revision_photos = general_photos + non_general_photos






    if revision_photos.empty?
      doc.replace('CODIGO IMAGEN 24123123', '')
    end





    output_path2 = Rails.root.join('tmp', "#{inspection.number}_part3.docx")
    doc.commit(output_path2)








    original_files = []


    Omnidocx::Docx.replace_footer_content(replacement_hash={ "{{month}}" => inspection.ins_date&.strftime('%m'), "{{year}}" => inspection.ins_date&.strftime('%Y'), "{{rol}}" => item_rol }, output_path, output_path)




    Omnidocx::Docx.replace_footer_content(replacement_hash={ "{{XXX}}" => inspection.number.to_s}, output_path, output_path)





    Omnidocx::Docx.merge_documents([output_path, output_path2], output_path, false)

    original_files << output_path2






    original_files.each do |file_path|
      File.delete(file_path) if File.exist?(file_path)
    end




    rules = group.rules.ordered_by_code.drop(11)

    if group.number == 1
      tabla_path = Rails.root.join('app', 'templates', 'tabla_grupo_1.docx')
    elsif group.number == 2
      tabla_path = Rails.root.join('app', 'templates', 'tabla_grupo_2.docx')
    elsif group.number == 3
      tabla_path = Rails.root.join('app', 'templates', 'tabla_grupo_3.docx')
    end


    if revision_photos.empty?
      Omnidocx::Docx.merge_documents([output_path, tabla_path], output_path, true)
    else
      Omnidocx::Docx.merge_documents([output_path, tabla_path], output_path, true)
    end


    doc = DocxReplace::Doc.new(output_path, "#{Rails.root}/tmp")




    rules.each_with_index do |rule, index|



      apply_weird = false

      if rule.code.start_with?('9', '2')
        case detail.sala_maquinas
        when "Si"
          if rule.code.start_with?('9')
            doc.replace('{{tabla_si}}', 'N/A')
            doc.replace('{{tabla_l}}', '')
            doc.replace('{{tabla_comentario}}', '')
            apply_weird = true
          end
        when "No. Máquina en la parte superior"
          if rule.code.start_with?('2') || rule.code.start_with?('9.3') || rule.code.start_with?('9.4')
            doc.replace('{{tabla_si}}', 'N/A')
            doc.replace('{{tabla_l}}', '')
            doc.replace('{{tabla_comentario}}', '')
            apply_weird = true
          end
        when "No. Máquina en foso"
          if rule.code.start_with?('2') || rule.code.start_with?('9.2') || rule.code.start_with?('9.4')
            doc.replace('{{tabla_si}}', 'N/A')
            doc.replace('{{tabla_l}}', '')
            doc.replace('{{tabla_comentario}}', '')
            apply_weird = true
          end
        when "No. Maquinaria fuera de la caja de elevadores"
          if rule.code.start_with?('2') || rule.code.start_with?('9.2') || rule.code.start_with?('9.3')
            doc.replace('{{tabla_si}}', 'N/A')
            doc.replace('{{tabla_l}}', '')
            doc.replace('{{tabla_comentario}}', '')
            apply_weird = true
          end
        end
      end

      unless apply_weird
        index2 = nil
        revision.codes.each_with_index do |code, index|
          if code == rule.code && revision.points[index] == rule.point
            index2 = index
            break
          end
        end

        if index2
          if revision.comment[index2].blank?
            doc.replace('{{tabla_comentario}}', '')
          else
            doc.replace('{{tabla_comentario}}', "(#{revision.comment[index2]})")
          end




          doc.replace('{{tabla_si}}', 'NO')
          level121 = revision.levels[index2]
          if level121 == 'L'
            doc.replace('{{tabla_l}}', 'Leve')
          else
            found_in_last_revision = false
            last_revision&.codes&.each_with_index do |last_code, index|
              if last_code == rule.code && last_revision.points[index] == rule.point && last_revision.levels[index] == 'L'
                found_in_last_revision = true
                break
              end
            end
            if found_in_last_revision
              doc.replace('{{tabla_l}}', 'Grave (repite)')
            else
              doc.replace('{{tabla_l}}', 'Grave')
            end
          end

        elsif revision_nulls_total.any? { |null| null.point == "#{rule.code}_#{rule.point}" }
          # Si hay una coincidencia en revision_null
          doc.replace('{{tabla_si}}', 'N/A')
          doc.replace('{{tabla_l}}', '')
          doc.replace('{{tabla_comentario}}', '')

        else
          # Si no se encuentra coincidencia en revision ni en revision_null
          doc.replace('{{tabla_si}}', 'SI')
          doc.replace('{{tabla_l}}', '')
          doc.replace('{{tabla_comentario}}', '')
        end

      end
    end


    if detail.sala_maquinas == "Si"
      doc.replace('{{tabla_aplica1}}', 'NO APLICA A ÉSTA INSPECCIÓN')
      doc.replace('{{tabla_aplica2}}', 'NO APLICA A ÉSTA INSPECCIÓN')
      doc.replace('{{tabla_aplica3}}', 'NO APLICA A ÉSTA INSPECCIÓN')


    elsif detail.sala_maquinas == "No. Máquina en la parte superior"
      doc.replace('{{tabla_aplica1}}', 'SI APLICA A ÉSTA INSPECCIÓN')
      doc.replace('{{tabla_aplica2}}', 'NO APLICA A ÉSTA INSPECCIÓN')
      doc.replace('{{tabla_aplica3}}', 'NO APLICA A ÉSTA INSPECCIÓN')

    elsif detail.sala_maquinas == "No. Máquina en foso"
      doc.replace('{{tabla_aplica1}}', 'NO APLICA A ÉSTA INSPECCIÓN')
      doc.replace('{{tabla_aplica2}}', 'SI APLICA A ÉSTA INSPECCIÓN')
      doc.replace('{{tabla_aplica3}}', 'NO APLICA A ÉSTA INSPECCIÓN')
    elsif detail.sala_maquinas == "No. Maquinaria fuera de la caja de elevadores"
      doc.replace('{{tabla_aplica1}}', 'NO APLICA A ÉSTA INSPECCIÓN')
      doc.replace('{{tabla_aplica2}}', 'NO APLICA A ÉSTA INSPECCIÓN')
      doc.replace('{{tabla_aplica3}}', 'SI APLICA A ÉSTA INSPECCIÓN')
    end


    another_ruletypes = [
      "1.15",
      "2.17",
      "3.15",
      "4.15",
      "5.18",
      "6.7",
      "7.4",
      "8.16",
      "9.2.12",
      "9.3.8",
      "9.4.3",
      "10.9",
      "11.2",
    ]



    another_ruletypes.each do |ruletype|
      matching_anothers = anothers.select do |another|
        another.code == "#{ruletype}.1"
      end

      if matching_anothers.any?
        matching_revision_indices = []
        matching_anothers.each do |another|
          revision.points.each_with_index do |point, index|
            if point == another.point
              matching_revision_indices << index unless matching_revision_indices.include?(index)
            end
          end
        end

        if matching_revision_indices.any?
          doc.replace('{{another_si}}', "No")

          levels = matching_revision_indices.map { |i| revision.levels[i] }
          points = matching_revision_indices.map { |i| revision.points[i] }

          control42918421 = false
          points.each_with_index do |point, index|
            if last_revision&.points&.include?(point)
              if last_revision.levels[index] == "L"
                doc.replace('{{another_l}}', 'Grave (repite)')
                control42918421 = true
              end
            end
          end

          if control42918421 == false

            if levels.include?("G")
              doc.replace('{{another_l}}', "Grave")
            else
              doc.replace('{{another_l}}', "Leve")
            end
          end


          comentarios = matching_revision_indices.map do |i|
            comment_text = revision.comment[i].to_s.strip
            comment = comment_text.empty? ? "(Sin comentario). " : "(#{comment_text}). "
            "#{revision.points[i]} #{comment}                                                                           "
          end

          comentario_final = comentarios.map(&:strip).join(" ")

          doc.replace('{{another_comentario}}', comentario_final)
        else
          doc.replace('{{another_si}}', "Si")
          doc.replace('{{another_l}}', "")
          doc.replace('{{another_comentario}}', "")
        end
      else
        doc.replace('{{another_si}}', "Si")
        doc.replace('{{another_l}}', "")
        doc.replace('{{another_comentario}}', "")
      end
    end



    doc.commit(output_path)

    Dir.glob("#{Rails.root}/tmp/#{inspection.number}_part*").each do |file_path|
      File.delete(file_path) if File.exist?(file_path)
    end



    require 'json'
    require 'fileutils'

    dir_name = "imagenes_#{inspection.number}"
    dir_path = File.join(Rails.root, 'tmp', dir_name)

    FileUtils.mkdir_p(dir_path)

    docx_basename = File.basename(output_path)
    docx_new_path = File.join(dir_path, docx_basename)
    FileUtils.mv(output_path, docx_new_path)

    photos_mapping = []
    counter = 1


    revision_photos.each do |photo|

      original_ext = File.extname(photo.photo.blob.filename.to_s)
      ext = original_ext.empty? ? ".jpg" : original_ext

      new_filename = "#{counter}#{ext}"
      new_file_path = File.join(dir_path, new_filename)

      File.open(new_file_path, 'wb') do |file|
        file.write(photo.photo.download)
      end

      text_imagen_comment = nil
      unless photo.code.start_with?("GENERALCODE")

        temp_code, temp_point = photo.code.split(' ', 2)
        index2 = nil
        revision.codes.each_with_index do |c, idx|
          if c == temp_code && revision.points[idx] == temp_point
            index2 = idx
            text_imagen_comment = revision.comment[idx]
            break
          end
        end
      end

      final_code_text = photo.code.sub('GENERALCODE', '')
      final_text = if text_imagen_comment
                     "#{final_code_text} #{text_imagen_comment}"
                   else
                     final_code_text
                   end

      photos_mapping << {
        "filename" => new_filename,
        "text"     => final_text.strip
      }

      counter += 1
    end

    mapping_json_path = File.join(dir_path, 'mapping.json')
    File.write(mapping_json_path, photos_mapping.to_json)

    venv_python = Rails.root.join('ascensor', 'bin', 'python').to_s

    script_path = Rails.root.join('app', 'scripts', 'insertar_imagenes.py').to_s
    token       = "CODIGO IMAGEN 24123123"

    cmd = "#{venv_python} \"#{script_path}\" --folder \"#{dir_path}\" --docx \"#{docx_basename}\" --token \"#{token}\""
    system(cmd)

    FileUtils.mv(docx_new_path, output_path)

    FileUtils.rm_rf(dir_path)




    return output_path

  end

  private

  def self.prepare_images_for_document(revision_id, code)
    revision_photos = RevisionPhoto.where(revision_id: revision_id, code: code, revision_type: 'Revision')

    max_width_per_image = 400

    images_to_write = revision_photos.map do |revision_photo|
      if revision_photo.photo.attached?
        temp_path = save_temp_image(revision_photo.photo)
        {
          :path => temp_path,
          :height => 250,
          :width => max_width_per_image,
        }
      end
    end.compact
    images_to_write
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

  def download_blob_to_tempfile(blob, tempfile)
    blob.download do |chunk|
      tempfile.write(chunk)
    end
    tempfile.rewind
  end
end
