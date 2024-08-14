
require 'docx_replace'
require 'omnidocx'
require 'fileutils'
require 'mini_magick'
require 'tempfile'
require 'securerandom'
class DocumentGeneratorLibre
  def self.generate_document(inspection_id, principal_id, revision_id, item_id, admin_id)
    inspection = Inspection.find(inspection_id)
    principal = Principal.find(principal_id)
    revision = Revision.find(revision_id)
    item = Item.find(item_id)
    group = item.group
    detail = item.detail
    report = Report.find_by(inspection_id: inspection.id)
    admin = User.find(admin_id)
    inspectors = inspection.users
    rules = group.rules.ordered_by_code.drop(11)
    item_rol = item.identificador.chars.last(4).join

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
    doc.replace('{{inf_date}}', inspection.inf_date&.strftime('%d/%m/%Y'))

    doc.replace('{{inspection_validation}}', report.ending&.strftime('%d/%m/%Y'))

    if report.cert_ant == 'Si'
      doc.replace('{{cert_ant}}', 'Si')

    elsif report.cert_ant == 'No'
      doc.replace('{{cert_ant}}', 'No')
    else
      doc.replace('{{cert_ant}}', 'S/I')
    end


    doc.replace('{{instalation_number}}', item.identificador)

    if revision.codes.first == '0.1.1'
      doc.replace('{{certificado_minvu}}', "No cumple")
    else
      doc.replace('{{certificado_minvu}}', report.certificado_minvu)
    end


    doc.replace('{{report_fecha}}', report.fecha&.strftime('%d/%m/%Y'))
    doc.replace('{{empresa_anterior}}', report.empresa_anterior)
    doc.replace('{{ea_rol}}', report.ea_rol)
    doc.replace('{{ea_rut}}', report.ea_rut)
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
    doc.replace('{{detail_velocidad}}', detail.velocidad)
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
    doc.replace('{{detail_recepcion}}', detail.recepcion)
    doc.replace('{{detail_empresa_instaladora}}', detail.empresa_instaladora)
    doc.replace('{{detail_empresa_instaladora_rut}}', detail.empresa_instaladora_rut)

    if detail.porcentaje
      doc.replace('{{detail_porcentaje}}', "#{detail.porcentaje.to_s}%")
    else
      doc.replace('{{detail_porcentaje}}', "S/I")
    end

    doc.replace('{{detail_descripcion}}', detail.descripcion)



    doc.replace('{{grupo}}', group.name)



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


    doc.replace('{{item_group}}', '[Desconocido]')

    doc.replace('{{normas_de_referencia}}', '[Desconocido]')






    last_revision = Revision.where(item_id: item.id).order(created_at: :desc).offset(1).first

    rules.each_with_index do |rule, index|
      if revision.points.include?(rule.point)
        point_index = revision.points.index(rule.point)
        revision.codes[point_index] = "1.1." + (index+1).to_s
      end
      if last_revision.points.include?(rule.point)
        point_index = last_revision.points.index(rule.point)
        last_revision.codes[point_index] = "1.1." + (index+1).to_s
      end
    end

    # Ordenar revision
    sorted_indexes = revision.codes.each_with_index.sort_by { |code, index| code.split('.').map(&:to_i) }.map(&:last)

    sorted_levels = sorted_indexes.map { |index| revision.levels[index] }
    sorted_codes = sorted_indexes.map { |index| revision.codes[index] }
    sorted_points = sorted_indexes.map { |index| revision.points[index] }
    sorted_fail = sorted_indexes.map { |index| revision.fail[index] }
    sorted_comment = sorted_indexes.map { |index| revision.comment[index] }

    revision.levels = sorted_levels
    revision.codes = sorted_codes
    revision.points = sorted_points
    revision.fail = sorted_fail
    revision.comment = sorted_comment

    # Ordenar last_revision
    sorted_indexes_last = last_revision.codes.each_with_index.sort_by { |code, index| code.split('.').map(&:to_i) }.map(&:last)

    sorted_levels_last = sorted_indexes_last.map { |index| last_revision.levels[index] }
    sorted_codes_last = sorted_indexes_last.map { |index| last_revision.codes[index] }
    sorted_points_last = sorted_indexes_last.map { |index| last_revision.points[index] }
    sorted_fail_last = sorted_indexes_last.map { |index| last_revision.fail[index] }
    sorted_comment_last = sorted_indexes_last.map { |index| last_revision.comment[index] }

    last_revision.levels = sorted_levels_last
    last_revision.codes = sorted_codes_last
    last_revision.points = sorted_points_last
    last_revision.fail = sorted_fail_last
    last_revision.comment = sorted_comment_last



    last_errors = []
    last_errors_lift = []


    if report.cert_ant == 'Si'

      if last_revision.nil?

        doc.replace('{{informe_anterior}}', "Con respecto al informe anterior con fecha #{report.fecha&.strftime('%d/%m/%Y')}:")
        doc.replace('{{revision_past_errors_level}}', "")
        doc.replace('{{revision_past_errors_level_lift}}', "")

      end

      if last_revision&.levels.blank?
        doc.replace('{{informe_anterior}}', "Informe anterior sin fallas registradas")
        doc.replace('{{revision_past_errors_level}}', "")
        doc.replace('{{revision_past_errors_level_lift}}', "")

      else



        last_revision.levels.each_with_index do |level, index|
          if level.include?("L")
              if revision.points.include?(last_revision.points[index])
                last_errors << last_revision.codes[index] + " " + last_revision.points[index]
              else
                last_errors_lift << last_revision.codes[index] + " " + last_revision.points[index]
              end

          end
        end

        formatted_errors_lift = last_errors_lift.map { |last_error_lift| "• #{last_error_lift}\n                                                                      " }.join("\n")


        if last_errors.blank?


          doc.replace('{{informe_anterior}}', "Se levantan todas las conformidades Faltas Leves, indicadas en certificación anterior.")
          doc.replace('{{revision_past_errors_level}}', "")
          doc.replace('{{revision_past_errors_level_lift}}', formatted_errors_lift)


        else
          last_inspection = Inspection.find(last_revision.inspection_id)
          formatted_errors = last_errors.map { |last_error| "• #{last_error}\n                                                                 " }.join("\n")

          if last_inspection.number > 0
            last_inspection_inf_date = last_inspection.inf_date
            doc.replace('{{informe_anterior}}', "Se mantienen las no conformidades leves indicadas en informe anterior N°#{last_inspection.number} de fecha:#{last_inspection_inf_date&.strftime('%d/%m/%Y')}, las cuales se detallan a continuación:")
            doc.replace('{{revision_past_errors_level}}', formatted_errors)
            doc.replace('{{revision_past_errors_level_lift}}', formatted_errors_lift)
          else

            if report.empresa_anterior=="S/I"
              doc.replace('{{informe_anterior}}', "Se mantienen las no conformidades leves indicadas en informe anterior realizado por empresa sin identificar, las cuales se detallan a continuación:")
            else
              doc.replace('{{informe_anterior}}', "Se mantienen las no conformidades leves indicadas en informe anterior realizado por #{report.empresa_anterior}, las cuales se detallan a continuación:")
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



    doc.replace('{{grupo_en_titulo}}', '[Desconocido]')



    doc.replace('{{normas_de_referencia_titulo}}', '')



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

    carpetas.each do |carpeta|
      indice = revision.codes.find_index(carpeta)
      if indice
        doc.replace('{{carpeta_si}}', 'No')
        doc.replace('{{carpeta_no_aplica}}', '')
        if revision.levels[indice] == 'L'
          doc.replace('{{carpeta_f}}', 'FL')
        else
          doc.replace('{{carpeta_f}}', 'FG')
        end
        doc.replace('{{carpeta_comentario}}', revision.comment[indice])

      elsif revision_nulls.any? { |null| null.point.start_with?("#{carpeta}_") }
        doc.replace('{{carpeta_si}}', '')
        doc.replace('{{carpeta_f}}', '')
        doc.replace('{{carpeta_comentario}}', '')
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
      condicion = admin.real_name == inspectors.first.real_name || admin.real_name == inspectors.second.real_name || admin.email == inspectors.first.email || admin.email == inspectors.second.email
    else
      condicion = admin.real_name == inspectors.first.real_name || admin.email == inspectors.first.email
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

    if detail.sala_maquinas == "Si"
      aux = [
        '•1. Carpeta cero.',
        '•2. Caja de elevadores.',
        '•3. Espacio de máquinas y poleas (para ascensores sin cuarto de máquinas aplica cláusula 9).',
        '•4. Puerta de piso.',
        '•5. Cabina, contrapeso y masa de equilibrio.',
        '•6. Suspensión, compensación, protección contra la sobre velocidad y protección contra el movimiento incontrolado de la cabina.',
        '•7. Guías, amortiguadores y dispositivos de seguridad de final de recorrido.',
        '•8. Holguras entre cabina y paredes de los accesos, así como entre contrapeso o masa de equilibrado.',
        '•10. Ascensores sin sala de máquinas.',
        '•11. Protección contra defectos eléctricos, mandos y prioridades.',
        '•12. Ascensores con excepciones autorizadas, en los que se hayan realizado modificaciones importantes, o que cumplan normativa particular.'
      ]


    else
      aux = [
        '•1. Carpeta cero.',
        '•3. Espacio de máquinas y poleas (para ascensores sin cuarto de máquinas aplica cláusula 9).',
        '•4. Puerta de piso.',
        '•5. Cabina, contrapeso y masa de equilibrio.',
        '•6. Suspensión, compensación, protección contra la sobre velocidad y protección contra el movimiento incontrolado de la cabina.',
        '•7. Guías, amortiguadores y dispositivos de seguridad de final de recorrido.',
        '•8. Holguras entre cabina y paredes de los accesos, así como entre contrapeso o masa de equilibrado.',
        '•9. Máquina.',
        '•10. Ascensores sin sala de máquinas.',
        '•11. Protección contra defectos eléctricos, mandos y prioridades.',
        '•12. Ascensores con excepciones autorizadas, en los que se hayan realizado modificaciones importantes, o que cumplan normativa particular.'
      ]
    end


    cumple_text = cumple.map { |index| "#{aux[index]}\n                                                                                                                          "}.join("\n")
    no_cumple_text = no_cumple.map { |index| "#{aux[index]}\n                                                                                                                     "}.join("\n")

    if cumple.any?
      doc.replace('{{lista_comprobacion_cumple}}', cumple_text)
      doc.replace('{{texto_comprobacion_cumple}}', 'De acuerdo a esta inspección, CUMPLE, con los requisitos normativos evaluados:')
    else
      doc.replace('{{lista_comprobacion_cumple}}', '')
      doc.replace('{{texto_comprobacion_cumple}}', 'No cumple con ningún requisito normativo')
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
          errors_graves << ("#{revision.codes[index]} #{revision.points[index]} (Esto No ocurre. No se hizo ningún comentario)")
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} falla grave. Razón: (Esto No ocurre. No se hizo ningún comentario)"

        else
          errors_graves << "#{revision.codes[index]} #{revision.points[index]}. Razón: #{revision.comment[index]}"
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} falla grave. Razón: #{revision.comment[index]}"

        end
      elsif level.include?("L")
        if revision.comment[index].blank?
          errors_leves << ("#{revision.codes[index]} #{revision.points[index]} (Esto No ocurre. No se hizo ningún comentario)")
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} falla leve. Razón: (Esto No ocurre. No se hizo ningún comentario)"

        else
          errors_leves << "#{revision.codes[index]} #{revision.points[index]}. Razón: #{revision.comment[index]}"
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} falla leve. Razón: #{revision.comment[index]}"

        end
      end
    end




    if errors_graves.any?
      doc.replace('{{si_las_hubiera_grave}}', 'Las no conformidades, Faltas Graves, encontradas en la inspección son las siguientes:')
    else
      doc.replace('{{si_las_hubiera_grave}}', 'No se encontraron faltas graves en la inspección.')
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
      doc.replace('{{si_las_hubiera_leve}}', 'Las no conformidades, Faltas Leves, encontradas en la inspección son las siguientes:')
    else
      doc.replace('{{si_las_hubiera_leve}}', 'No se encontraron faltas leves en la inspección.')
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
      doc.replace('{{texto_grave}}', "Las No Conformidades evaluadas como Faltas Graves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas dentro de 90 días desde la fecha del informe de inspección.")
      if !errors_leves.empty?
        doc.replace('{{texto_leve}}', "Las No Conformidades evaluadas como Faltas Leves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas antes de la próxima CERTIFICACION en mes de #{month_name}.")
      else
        doc.replace('{{texto_leve}}', "")
      end

    end

    if !errors_leves.empty? && errors_graves.empty?
      doc.replace('{{cumple/parcial/no_cumple}}', "cumple parcialmente")
      doc.replace('{{esta/no_esta}}', "está")
      doc.replace('{{texto_grave}}', "")
      doc.replace('{{texto_leve}}', "Las No Conformidades evaluadas como Faltas Leves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas antes de la próxima CERTIFICACION en mes de #{month_name}.")
    end

    doc.replace('{{admin}}', admin.real_name)
    doc.replace('{{inspector}}', inspectors.first.real_name)


    doc.replace('{{inspector_profesion}}', inspectors.first.profesion)

    if inspectors.second
      doc.replace('{{inspector}}', inspectors.second.real_name)
      doc.replace('{{inspector_profesion}}', inspectors.second.profesion)
    end

    if condicion
      doc.replace('{{y_inspector}}', 'Inspector y')
    else
      doc.replace('{{y_inspector}}', '')
    end

    doc.replace('{{admin_profesion}}', admin.profesion)

    output_path2 = Rails.root.join('tmp', "part3.docx")
    doc.commit(output_path2)








    original_files = []


    Omnidocx::Docx.replace_footer_content(replacement_hash={ "{{month}}" => inspection.ins_date&.strftime('%m'), "{{year}}" => inspection.ins_date&.strftime('%Y'), "{{rol}}" => item_rol }, output_path, output_path)



    Omnidocx::Docx.replace_footer_content(replacement_hash={ "{{XXX}}" => inspection.number.to_s}, output_path, output_path)








    Omnidocx::Docx.merge_documents([output_path, 'tmp/part3.docx'], output_path, true)

    original_files << 'tmp/part3.docx'

=begin


    # Rutas de firma de inspectores
    inspector1_signature_path = Rails.root.join('tmp', 'inspector1_signature.jpg')
    inspector2_signature_path = inspectors.second ? Rails.root.join('tmp', 'inspector2_signature.jpg') : nil

    # Ruta de firma del administrador
    admin_signature_path = Rails.root.join('tmp', 'admin_signature.jpg')

    # Imagen en blanco
    third_image_path = Rails.root.join('app', 'templates', 'blanco.jpg')

    # Procesamiento de las firmas
    File.open(inspector1_signature_path, 'wb') { |file| file.write(inspectors.first.signature.download) }
    MiniMagick::Image.open(inspector1_signature_path).tap do |image|
      image.resize "300x"
      image.write(inspector1_signature_path)
    end

    # Procesar segundo inspector si existe
    if inspector2_signature_path
      File.open(inspector2_signature_path, 'wb') { |file| file.write(inspectors.second.signature.download) }
      MiniMagick::Image.open(inspector2_signature_path).tap do |image|
        image.resize "300x"
        image.write(inspector2_signature_path)
      end
    end

    # Procesar firma del administrador
    File.open(admin_signature_path, 'wb') { |file| file.write(admin.signature.download) }
    MiniMagick::Image.open(admin_signature_path).tap do |image|
      image.resize "300x"
      image.write(admin_signature_path)
    end

    # Procesar imagen en blanco
    MiniMagick::Image.open(third_image_path).tap do |image|
      image.resize "100x"
      image.write(third_image_path)
    end

    # Lista de imágenes para el montaje
    images = [
      inspector1_signature_path,
      (inspector2_signature_path || third_image_path), # Si no hay inspector2, usar imagen en blanco
      admin_signature_path
    ]

    # Añadir la imagen en blanco al final si hay inspector2
    images.insert(3, third_image_path) if inspector2_signature_path

    # Generación de la imagen combinada
    random_hex = SecureRandom.hex(4)
    output_filename = "inspector_#{inspectors.first.username}_admin_#{admin.username}_#{random_hex}.jpg"
    output_path_image = Rails.root.join('tmp', output_filename)

    MiniMagick::Tool::Montage.new do |montage|
      montage.geometry "300x+0+0"
      montage.tile "3x1"
      images.each { |i| montage << i }
      montage << output_path_image.to_s
    end

    # Escritura de la imagen combinada en un documento
    images_to_write = [{ path: output_path_image.to_s, height: 250, width: 800 }]
    Omnidocx::Docx.write_images_to_doc(images_to_write, output_path, output_path)

    # Limpieza de archivos temporales
    [inspector1_signature_path, admin_signature_path, output_path_image].concat([inspector2_signature_path].compact).each do |path|
      File.delete(path) if File.exist?(path)
    end
=end

    # Obtener las fotos ordenadas por `revision_photo.code`
    revision_photos = revision.revision_photos.ordered_by_code

    # Directorio temporal para guardar el archivo LaTeX y las imágenes
    latex_dir = Rails.root.join('tmp', 'latex')
    FileUtils.mkdir_p(latex_dir)

    # Nombre base que incluye `inspection.number`
    base_name = inspection.number.to_s + '_' + inspection.ins_date.strftime('%m') + '_' + inspection.ins_date.strftime('%Y') + '_' + item_rol

    # Nombre del archivo LaTeX
    latex_file = File.join(latex_dir, "#{base_name}_document.tex")

    # Generar el contenido LaTeX dinámicamente basado en las imágenes y códigos
    latex_content = "\\documentclass{article}\n"
    latex_content += "\\usepackage{graphicx}\n"
    latex_content += "\\usepackage{geometry}\n"
    latex_content += "\\geometry{a4paper, margin=1in}\n"
    latex_content += "\\pagestyle{empty}\n" # Quitar el número de página
    latex_content += "\\renewcommand{\\figurename}{Imagen}\n" # Cambiar "Figure" por "Imagen"
    latex_content += "\\renewcommand{\\thefigure}{N°\\arabic{figure}}\n" # Cambiar el formato a "N°"
    latex_content += "\\begin{document}\n"

    revision_photos.each_slice(2) do |photos|
      latex_content += "\\begin{figure}[h!]\n"
      photos.each do |photo|
        image_path = ActiveStorage::Blob.service.path_for(photo.photo.key)
        # Usar `inspection.number` para el nombre de la imagen
        image_destination = File.join(latex_dir, "#{base_name}_#{photo.id}.jpg")
        FileUtils.cp(image_path, image_destination)

        latex_content += "  \\begin{minipage}[b]{0.45\\textwidth}\n"
        latex_content += "    \\centering\n"
        latex_content += "    \\includegraphics[width=0.8\\textwidth, height=0.5\\textheight, keepaspectratio]{#{File.basename(image_destination)}}\n"
        latex_content += "    \\caption{#{photo.code}}\n" # Mostrar "Imagen N°<número>: <código>"
        latex_content += "  \\end{minipage}\n"
        latex_content += "  \\hfill\n" if photos.size > 1
      end
      latex_content += "\\end{figure}\n"
    end

    latex_content += "\\end{document}\n"

    # Guardar el contenido en el archivo LaTeX
    File.open(latex_file, 'w') { |file| file.write(latex_content) }

    # Compilar el archivo LaTeX a PDF usando el comando pdflatex
    Dir.chdir(latex_dir) do
      stdout, stderr, status = Open3.capture3("pdflatex #{File.basename(latex_file)}")
      unless status.success?
        render plain: "Error al compilar LaTeX: #{stderr}", status: :internal_server_error
        return
      end
    end

    # Convertir PDF a imágenes (una por página)
    pdf_file = File.join(latex_dir, "#{base_name}_document.pdf")
    image_output_base = File.join(latex_dir, "#{base_name}_page")
    stdout, stderr, status = Open3.capture3("pdftoppm -png #{pdf_file} #{image_output_base}")
    unless status.success?
      render plain: "Error al convertir PDF a imágenes: #{stderr}", status: :internal_server_error
      return
    end

    images_to_write = Dir.glob("#{image_output_base}-*.png").map do |image|
      {
        path: image,
        height: 1100,
        width: 700
      }
    end

    Omnidocx::Docx.write_images_to_doc(images_to_write, output_path, output_path)

    # Buscar y eliminar todos los archivos que comiencen con `base_name`
    Dir.glob("#{latex_dir}/#{base_name}*").each do |file_path|
      File.delete(file_path) if File.exist?(file_path)
    end


    original_files.each do |file_path|
      File.delete(file_path) if File.exist?(file_path)
    end


    tabla_path = Rails.root.join('app', 'templates', 'tabla_libre_1.docx')


    Omnidocx::Docx.merge_documents([output_path, tabla_path], output_path, false)


    doc = DocxReplace::Doc.new(output_path, "#{Rails.root}/tmp")


    rules.each_with_index do |rule, index|

      if index > 0
        tabla_path = Rails.root.join('app', 'templates', 'tabla_libre_2.docx')
        Omnidocx::Docx.merge_documents([output_path, tabla_path], output_path, false)
        doc = DocxReplace::Doc.new(output_path, "#{Rails.root}/tmp")
      end

      doc.replace("{{tabla_code}}", "1.1." + (index+1).to_s)
      doc.replace("{{tabla_point}}", rule.point)
      ins_type_string = rule.ins_type.join(',')
      doc.replace("{{tabla_tipo}}", ins_type_string)


      if revision.points.include?(rule.point)
        index2 = revision.points.index(rule.point)

        doc.replace('{{tabla_si}}', 'NO')


        level121 = revision.levels[index2]

        if level121 == 'L'
          doc.replace('{{tabla_l}}', 'Leve')

        else
          doc.replace('{{tabla_l}}', 'Grave')

        end
        if revision.comment[index2].blank?
          doc.replace('{{tabla_comentario}}', 'No se hizo ningún comentario')
        else
          doc.replace('{{tabla_comentario}}', revision.comment[index2])
        end


      else
        doc.replace('{{tabla_si}}', 'SI')
        doc.replace('{{tabla_l}}', '')
        doc.replace('{{tabla_comentario}}', '')
      end
      doc.replace('{{tabla_na}}', ' ')
      doc.commit(output_path)

    end







    return output_path

  end

  private

  def self.prepare_images_for_document(revision_id, point)
    revision_photos = RevisionPhoto.where(revision_id: revision_id, revision_type: 'Revision')

    max_width_per_image = 400

    images_to_write = revision_photos.select { |photo| photo.code.split('|||').last == point }.map do |revision_photo|
      if revision_photo.photo.attached?
        temp_path = save_temp_image(revision_photo.photo)
        {
          path: temp_path,
          height: 250,
          width: max_width_per_image,
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