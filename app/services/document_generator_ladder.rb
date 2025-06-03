require 'docx_replace'
require 'omnidocx'
require 'fileutils'
require "ostruct"


class DocumentGeneratorLadder
  def self.generate_document(inspection_id, principal_id, revision_id, item_id, admin_id)

    inspection = Inspection.find(inspection_id)
    principal = Principal.find(principal_id)
    revision_base = LadderRevision.find(revision_id)
    item = Item.find(item_id)
    detail = item.ladder_detail
    report = Report.find_by(inspection_id: inspection.id)
    admin = User.find(admin_id)
    inspectors = inspection.users
    rules = Ladder.all.drop(11)
    item_rol = item.identificador.chars.last(4).join

    revision = OpenStruct.new(codes: [], points: [], levels: [], comment: [], number: [], priority: [])
    revision_base.revision_colors.order(:section).each do |revision_color|
      revision.codes.concat(revision_color.codes || [])
      revision.points.concat(revision_color.points || [])
      revision.levels.concat(revision_color.levels || [])
      revision.comment.concat(revision_color.comment || [])
      revision.number.concat(revision_color.number || [])
      revision.priority.concat(revision_color.priority || [])
    end

    template_path = Rails.root.join('app', 'templates', 'template_ladder1.docx')

    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")

    doc.replace('{{XXX}}', inspection.number.to_s)
    doc.replace('{{MM}}', inspection.ins_date.strftime('%m'))
    doc.replace('{{XX}}', inspection.ins_date.strftime('%Y'))
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
    doc.replace('{{ins_date}}', inspection.ins_date.strftime('%d/%m/%Y'))
    inspector_names = inspection.users.map(&:real_name).join(' / ')

    doc.replace('{{inspector}}', inspector_names)

    doc.replace('{{admin}}', admin.real_name)
    doc.replace('{{inf_date}}', inspection.inf_date.strftime('%d/%m/%Y') || '')

    doc.replace('{{inspection_validation}}', report.ending.strftime('%d/%m/%Y'))

    if report.cert_ant == 'Si' || report.cert_ant == 'sistema'
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

    doc.replace('{{detail_modelo}}', detail.modelo)
    doc.replace('{{detail_n_serie}}', detail.nserie)

    if detail.potencia
      doc.replace('{{detail_potencia}}', "#{detail.potencia.to_s} Kw")
    else
      doc.replace('{{detail_potencia}}', "S/I")
    end

    if detail.capacidad
      doc.replace('{{detail_capacidad}}', "#{detail.capacidad.to_s} Kg")
    else
      doc.replace('{{detail_capacidad}}', "S/I")

    end


    if detail.personas
      doc.replace('{{detail_personas}}', detail.personas.to_s)
    else
      doc.replace('{{detail_personas}}', "S/I")

    end

    if detail.peldaños
      doc.replace('{{peldanos}}', detail.peldaños.to_s)
    else
      doc.replace('{{peldanos}}', "S/I")
    end


    if detail.longitud
      doc.replace('{{longitud}}', detail.longitud.to_s)
    else
      doc.replace('{{longitud}}', "S/I")
    end

    if detail.inclinacion
      doc.replace('{{inclinacion}}', "#{detail.inclinacion.to_s}°")
    else
      doc.replace('{{inclinacion}}', "S/I")
    end


    if detail.ancho
      doc.replace('{{ancho}}', "#{detail.ancho.to_s} mm")
    else
      doc.replace('{{ancho}}', "S/I")

    end


    if detail.velocidad
      doc.replace('{{velocidad}}', detail.velocidad.to_s)
    else
      doc.replace('{{velocidad}}', "S/I")
    end
    if detail.fabricacion
      doc.replace('{{fabricacion}}', detail.fabricacion.to_s)
    else
      doc.replace('{{fabricacion}}', "S/I")
    end
    doc.replace('{{procedencia}}', detail.procedencia)
    doc.replace('{{detail_descripcion}}', detail.descripcion)
    doc.replace('{{detail_detalle}}', detail.detalle)
    doc.replace('{{detail_rol_n}}', detail.rol_n)
    doc.replace('{{detail_mm_marca}}', detail.mm_marca)
    doc.replace('{{detail_marca}}', detail.marca)
    doc.replace('{{detail_mm_n_serie}}', detail.mm_nserie)

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
    if detail.empresa_instaladora_rut
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
    revision_nulls = RevisionNull.where(revision_id: revision_id, revision_type: 'LadderRevision')
                                 .where("point LIKE ?", "5.0%")
    revision_nulls_total = RevisionNull.where(revision_id: revision_id, revision_type: 'LadderRevision')
                                       .where("point NOT LIKE ?", "5.0%")

    sorted_inspections = item.inspections.sort_by do |inspection|
      [-inspection.number.abs, inspection.number < 0 ? 1 : 0]
    end

    last_inspection = sorted_inspections[1]

    if last_inspection
      last_revision_base = LadderRevision.find_by(inspection_id: last_inspection.id)

    end

    last_errors = []
    last_errors_lift = []
    if last_revision_base
      last_revision = OpenStruct.new(codes: [], points: [], levels: [], comment: [], number: [], priority: [])

      last_revision_base.revision_colors.order(:section).each do |revision_color|
        last_revision.codes.concat(revision_color.codes || [])
        last_revision.points.concat(revision_color.points || [])
        last_revision.levels.concat(revision_color.levels || [])
        last_revision.comment.concat(revision_color.comment || [])
        last_revision.number.concat(revision_color.number || [])
        last_revision.priority.concat(revision_color.priority || [])
      end
    end

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
        doc.replace('{{informe_anterior}}', "Informe anterior sin defectos registrados")
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
          formatted_errors = last_errors.map { |last_error| "• #{last_error}\n                                                                                   " }.join("\n")

          if last_inspection.number > 0
            last_inspection_inf_date = last_inspection.inf_date
            doc.replace('{{informe_anterior}}', "Se mantienen las no conformidades indicadas en informe anterior N°#{last_inspection.number} de fecha:#{last_inspection_inf_date&.strftime('%d/%m/%Y')}, las cuales se detallan a continuación:")
            doc.replace('{{revision_past_errors_level}}', formatted_errors)
            doc.replace('{{revision_past_errors_level_lift}}', formatted_errors_lift)
          else

            if report.empresa_anterior=="S/I"
              doc.replace('{{informe_anterior}}', "Se mantienen las no conformidades indicadas en informe anterior realizado por empresa sin identificar, las cuales se detallan a continuación:")
            else
              doc.replace('{{informe_anterior}}', "Se mantienen las no conformidades indicadas en informe anterior realizado por #{report.empresa_anterior}, las cuales se detallan a continuación:")
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

    errors_graves = []
    errors_leves = []
    errors_all = []

    revision.levels.each_with_index do |level, index|
      if level.include?("G")
        if revision.comment[index].blank?
          errors_graves << ("#{revision.codes[index]} #{revision.points[index]} (No se hizo ningún comentario)")
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} defecto grave. (No se hizo ningún comentario)"

        else
          errors_graves << "#{revision.codes[index]} #{revision.points[index]} (#{revision.comment[index]})"
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} defecto grave. (#{revision.comment[index]})"

        end
      elsif level.include?("L")
        if revision.comment[index].blank?
          errors_leves << ("#{revision.codes[index]} #{revision.points[index]} (No se hizo ningún comentario)")
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} defecto leve. (No se hizo ningún comentario)"

        else
          errors_leves << "#{revision.codes[index]} #{revision.points[index]} (#{revision.comment[index]})"
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} defecto leve. (#{revision.comment[index]})"

        end
      end
    end

    if errors_all.blank?
      doc.replace('{{buen/mal}}', "buen")
    elsif errors_graves.blank?
      doc.replace('{{buen/mal}}', "regular")
    else
      doc.replace('{{buen/mal}}', "mal")
    end
    cumple = []
    no_cumple = []
    numbers = [0,1,2,3,4,5,6,7,8,11, 12, 13, 14, 15]
    numbers.each do |index|
      unless revision.codes.any? { |code| code.match?(/^5\.#{index}\./) }
        cumple << index
      else
        no_cumple << index
      end
    end

    aux = [
      '•0.  Carpeta cero.',
      '•1.  Requisitos generales',
      '•2.  Estructura de soporte (bastidor) y cerramiento',
      '•3.  Escalones, placa, banda',
      '•4.  Unidad de almacenamiento',
      '•5.  Balaustrada',
      '•6.  Pasamanos',
      '•7.  Rellanos',
      '•8.  Cuartos de maquinaria, estaciones de accionamiento y de retorno',
      '•9.  placeholder',
      '•10. placeholder',
      '•11. Instalaciones y aparatos eléctricos',
      '•12. Protección contra fallos eléctricos-maniobra',
      '•13. Interfaces con el edificio',
      '•14. Señales de seguridad para los usuarios',
      '•15. Utilización de carros de compra y de carros de equipaje'
    ]



    cumple_text = cumple.map { |index| "#{aux[index]}\n                                                                                                                          "}.join("\n")
    no_cumple_text = no_cumple.map { |index| "#{aux[index]}\n                                                                                                                          "}.join("\n")



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

      # Contar rules que empiezan con ese número
      rules_count = rules.select { |rule| rule.code.start_with?("5.#{number}") }.count
      # Contar revision_nulls_total que empiezan con ese número
      revision_nulls_count = revision_nulls_total.select { |rev| rev.point.start_with?("5.#{number}") }.count
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
      doc.replace('{{if_grave}}', "")
      doc.replace('{{if_leves}}', "")
    end

    if !errors_graves.empty?
      doc.replace('{{if_grave}}', "El equipo inspeccionado, identificado en el ítem II, ubicado en: #{inspection.place} no cumple con los requisitos normativos, encontrándose durante la inspección Defectos Graves de certificación anterior no subsanadas.")
      doc.replace('{{cumple/parcial/no_cumple}}', "no cumple")
      doc.replace('{{esta/no_esta}}', "no está")
      doc.replace('{{texto_grave}}', "Las No Conformidades evaluadas como Defectos Graves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas dentro de 90 días desde la fecha del informe de inspección.")
      if !errors_leves.empty?
        doc.replace('{{if_leves}}', "Las no conformidades, Defectos Leves, encontradas en la inspección son las siguientes:")
        doc.replace('{{texto_leve}}', "Las No Conformidades evaluadas como Defectos Leves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas antes de la próxima CERTIFICACION en #{month_name} del año #{report.ending.year}.")
      else
        doc.replace('{{texto_leve}}', "")
        doc.replace('{{if_leves}}', "")

      end
    else
    end

    if !errors_leves.empty? && errors_graves.empty?
      doc.replace('{{cumple/parcial/no_cumple}}', "cumple parcialmente")
      doc.replace('{{esta/no_esta}}', "está")
      doc.replace('{{texto_grave}}', "")
      doc.replace('{{if_leves}}', "Las no conformidades, Defectos Leves, encontradas en la inspección son las siguientes:")
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
      doc.replace('{{y_inspector}}', 'Inspector y')
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






    tabla_path = Rails.root.join('app', 'templates', 'tabla_escala.docx')


    if revision_photos.empty?
      Omnidocx::Docx.merge_documents([output_path, tabla_path], output_path, true)
    else
      Omnidocx::Docx.merge_documents([output_path, tabla_path], output_path, false)
    end

    doc = DocxReplace::Doc.new(output_path, "#{Rails.root}/tmp")



    carpetas = [
      '5.0.1',
      '5.0.2',
      '5.0.3',
      '5.0.4',
      '5.0.5',
      '5.0.6',
      '5.0.7',
      '5.0.8',
      '5.0.9',
      '5.0.10',
      '5.0.11'
    ]





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



    rules.each_with_index do |rule, index|
      if revision.codes.include?(rule.code) && revision.points.include?(rule.point)
        index2 = revision.points.index(rule.point)

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
    end


    doc.commit(output_path)



    original_files.each do |file_path|
      File.delete(file_path) if File.exist?(file_path)
    end
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
    revision_photos = RevisionPhoto.where(revision_id: revision_id, revision_type: 'LadderRevision', code: code)

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
end
