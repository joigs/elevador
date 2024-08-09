require 'docx_replace'
require 'omnidocx'
require 'fileutils'

class DocumentGeneratorLadder
  def self.generate_document(inspection_id, principal_id, revision_id, item_id, admin_id)

    inspection = Inspection.find(inspection_id)
    principal = Principal.find(principal_id)
    revision = LadderRevision.find(revision_id)
    item = Item.find(item_id)
    detail = item.ladder_detail
    report = Report.find_by(inspection_id: inspection.id)
    admin = User.find(admin_id)
    inspectors = inspection.users
    rules = Ladder.all.drop(11)
    item_rol = item.identificador.chars.last(4).join


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
    doc.replace('{{inf_date}}', inspection.inf_date.strftime('%d/%m/%Y'))

    doc.replace('{{inspection_validation}}', report.ending.strftime('%d/%m/%Y'))

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
      doc.replace('{{detail_numero_permiso}}', "#N°{detail.numero_permiso}")
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




    last_revision = LadderRevision.where(item_id: item.id).order(created_at: :desc).offset(1).first
    last_errors = []
    last_errors_lift = []


    if report.cert_ant == 'Si'

      if last_revision.nil?
        doc.replace('{{informe_anterior}}', "Con respecto al informe anterior con fecha #{report.fecha&.strftime('%d/%m/%Y')}:")
        doc.replace('{{revision_past_errors_level}}', "")
        doc.replace('{{revision_past_errors_level_lift}}', "")
      end

      if last_revision&.levels.blank?
        doc.replace('{{informe_anterior}}', "")
        doc.replace('{{revision_past_errors_level}}', "")
        doc.replace('{{revision_past_errors_level_lift}}', "")
      else

        last_revision_pikachu = []

        last_revision.levels.each_with_index do |level, index|
          if level.include?("L")
            if revision.codes.include?(last_revision.codes[index])
              if revision.points.include?(last_revision.points[index])
                last_errors << last_revision.codes[index] + " " + last_revision.points[index]
              else
                last_errors_lift << last_revision.codes[index] + " " + last_revision.points[index]
              end
            else
              last_errors_lift << last_revision.codes[index] + " " + last_revision.points[index]
            end
            last_revision_pikachu << last_revision.codes[index] + " " + last_revision.points[index]
          end
        end

        formatted_errors_lift = last_errors_lift.map { |last_error_lift| "• #{last_error_lift}\n                                            " }.join("\n")

        if last_errors.blank?
          formatted_pikachu = last_revision_pikachu.map { |last_error| "• #{last_error}\n                                                     "}.join("\n")
          doc.replace('{{informe_anterior}}', "Se levantan las conformidades Faltas Leves, indicadas en certificación anterior.")
          doc.replace('{{revision_past_errors_level}}', formatted_pikachu)
          doc.replace('{{revision_past_errors_level_lift}}', "")
        else
          last_inspection = Inspection.find(last_revision.inspection_id)
          formatted_errors = last_errors.map { |last_error| "• #{last_error}\n                                                          "}.join("\n")

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
      doc.replace('{{informe_anterior}}', "No presenta certificación anterior")
      doc.replace('{{revision_past_errors_level}}', "")
      doc.replace('{{revision_past_errors_level_lift}}', "")
    end








    output_path = Rails.root.join('tmp', "Informe N°#{inspection.number.to_s}-#{inspection.ins_date&.strftime('%m')}-#{inspection.ins_date&.strftime('%Y')}-#{item_rol}.docx")
    doc.commit(output_path)



    if inspectors.second
      condicion = admin.real_name == inspectors.first.real_name || admin.real_name == inspectors.second.real_name || admin.email == inspectors.first.email || admin.email == inspectors.second.email
    else
      condicion = admin.real_name == inspectors.first.real_name || admin.email == inspectors.first.email
    end


    if inspectors.second && !condicion
      template_path = Rails.root.join('app', 'templates', 'template_3.docx')
    elsif !inspectors.second && condicion
      template_path = Rails.root.join('app', 'templates', 'template_3_0user.docx')
    else
      template_path = Rails.root.join('app', 'templates', 'template_3_1user.docx')
    end


    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")

    doc.replace('{{inspection_place}}', inspection.place)

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

    if errors_all.blank?
      doc.replace('{{buen/mal}}', "buen")
    elsif errors_graves.blank?
      doc.replace('{{buen/mal}}', "regular")
    else
      doc.replace('{{buen/mal}}', "mal")
    end
    cumple = []
    no_cumple = []
    numbers = [1,2,3,4,5,6,7,8,11, 12, 13, 14, 15]
    numbers.each do |index|
      unless revision.codes.any? { |code| code.match?(/^5\.#{index}\./) }
        cumple << index
      else
        no_cumple << index
      end
    end

    aux = [
      '•1. Requisitos generales',
      '•2. Estructura de soporte (bastidor) y cerramiento',
      '•3. Escalones, placa, banda',
      '•4. Unidad de almacenamiento',
      '•5.  Balaustrada',
      '•6.  Pasamanos',
      '•7.  Rellanos',
      '•8.  Cuartos de maquinaria, estaciones de accionamiento y de retorno',
      '•11. Instalaciones y aparatos eléctricos',
      '•12. Protección contra fallos eléctricos-maniobra',
      '•13. Interfaces con el edificio',
      '•14. Señales de seguridad para los usuarios',
      '•15. Utilización de carros de compra y de carros de equipaje'
    ]


    cumple_text = cumple.map { |index| "#{aux[index]}\n                                                                                                                          "}.join("\n")
    no_cumple_text = no_cumple.map { |index| "#{aux[index]}\n                                                                                                                          "}.join("\n")
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



    if errors_leves.any?
      errors_leves_text = errors_leves.map { |error| "• #{error}\n                                                                                                                                     "}.join("\n")
      doc.replace('{{revision_errors_leves}}', errors_leves_text)
      doc.replace('{{si_las_hubiera_leve}}', 'Las no conformidades, Faltas Leves, encontradas en la inspección son las siguientes:')
    else
      doc.replace('{{revision_errors_leves}}', '')
      doc.replace('{{si_las_hubiera_leve}}', 'No se encontraron faltas leves en la inspección.')
    end

    if errors_graves.any?
      errors_graves_text = errors_graves.map { |error| "• #{error}\n                                                                                                                                  "}.join("\n")
      doc.replace('{{revision_errors_graves}}', errors_graves_text)
      doc.replace('{{si_las_hubiera_grave}}', 'Las no conformidades, Faltas Graves, encontradas en la inspección son las siguientes:')
    else
      doc.replace('{{revision_errors_graves}}', '')
      doc.replace('{{si_las_hubiera_grave}}', 'No se encontraron faltas graves en la inspección.')
    end

    errors_leves_text = errors_leves.map { |error| "• #{error}\n                                                                                                                          "}.join("\n")
    errors_graves_text = errors_graves.map { |error| "• #{error}\n                                                                                                                          "}.join("\n")

    doc.replace('{{revision_errors_leves}}', errors_leves_text)
    doc.replace('{{revision_errors_graves}}', errors_graves_text)



    identificador_rol = item.identificador.split("-").first
    identificador_rol_last = identificador_rol[/\d(?=[^\d]*$)/]

    months = {
      "0" => "Enero, Febrero o Marzo",
      "1" => "Abril",
      "2" => "Mayo",
      "3" => "Junio",
      "4" => "Julio",
      "5" => "Agosto",
      "6" => "Septiembre",
      "7" => "Octubre",
      "8" => "Noviembre",
      "9" => "Diciembre"
    }

    mapped_month = months[identificador_rol_last]

    if revision.levels.blank?
      doc.replace('{{cumple/parcial/no_cumple}}', "cumple")
      doc.replace('{{esta/no_esta}}', "está")
      doc.replace('{{texto_grave}}', "")
      doc.replace('{{texto_leve}}', "")
      doc.replace('{{if_grave}}', "")
      doc.replace('{{if_leves}}', "")
    end

    if !errors_graves.empty?
      doc.replace('{{if_grave}}', "El equipo inspeccionado, identificado en el ítem II, ubicado en: #{inspection.place} no cumple con los requisitos normativos, encontrándose durante la inspección Faltas Graves de certificación anterior no subsanadas.")
      doc.replace('{{cumple/parcial/no_cumple}}', "no cumple")
      doc.replace('{{esta/no_esta}}', "no está")
      doc.replace('{{texto_grave}}', "Las No Conformidades evaluadas como Faltas Graves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas dentro de 90 días desde la fecha del informe de inspección.")
      if !errors_leves.empty?
        doc.replace('{{if_leves}}', "Las no conformidades, Faltas Leves, encontradas en la inspección son las siguientes:")
        doc.replace('{{texto_leve}}', "Las No Conformidades evaluadas como Faltas Leves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas antes de la próxima CERTIFICACION en mes de #{mapped_month}.")
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
      doc.replace('{{if_leves}}', "Las no conformidades, Faltas Leves, encontradas en la inspección son las siguientes:")
      doc.replace('{{texto_leve}}', "Las No Conformidades evaluadas como Faltas Leves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas antes de la próxima CERTIFICACION en mes de #{mapped_month}.")
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

    revision_photos = RevisionPhoto.where(revision_id: revision_id, revision_type: 'LadderRevision')
    set_of_errors = []

    Omnidocx::Docx.replace_footer_content(replacement_hash={ "{{month}}" => inspection.ins_date&.strftime('%m'), "{{year}}" => inspection.ins_date&.strftime('%Y'), "{{rol}}" => item_rol }, output_path, output_path)




    Omnidocx::Docx.replace_footer_content(replacement_hash={ "{{XXX}}" => inspection.number.to_s}, output_path, output_path)



    revision.codes.each_with_index.chunk_while { |(_, i), (_, j)| revision.codes[i] == revision.codes[j] }.each_with_index do |group, group_index|
      group.each do |code, index|

        template_path = Rails.root.join('app', 'templates', 'template_2.docx')
        doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")
        set_of_errors << errors_all[index]

        has_matching_photo = revision_photos.any? { |photo| photo.code == code }

        next_code_different = (revision.codes[index+1] != code rescue true)

        if has_matching_photo && next_code_different
          errors_all_text = set_of_errors.map { |error| "• #{error}\n                                                                                                                          "}.join("\n")
          doc.replace('{{loop_falla}}', errors_all_text)
          output_path_var = Rails.root.join('tmp', "part2.#{group_index}.docx")
          doc.commit(output_path_var)
          original_files << output_path_var
          Omnidocx::Docx.merge_documents([output_path, output_path_var], output_path, false)
          images_to_write = prepare_images_for_document(revision_id, code)
          Omnidocx::Docx.write_images_to_doc(images_to_write, output_path, output_path)
          cleanup_temporary_images(images_to_write)
          set_of_errors = []

        elsif index == revision.codes.length - 1
          errors_all_text = set_of_errors.map { |error| "• #{error}\n                                                                                                                          "}.join("\n")
          doc.replace('{{loop_falla}}', errors_all_text)
          output_path_var = Rails.root.join('tmp', "part2.#{group_index}.docx")
          doc.commit(output_path_var)
          original_files << output_path_var
          Omnidocx::Docx.merge_documents([output_path, output_path_var], output_path, false)
        end
      end
    end

    Omnidocx::Docx.merge_documents([output_path, 'tmp/part3.docx'], output_path, true)
    original_files << output_path2
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
    images_to_write = [{ path: output_path_image.to_s, height: 300, width: 900 }]
    Omnidocx::Docx.write_images_to_doc(images_to_write, output_path, output_path)

    # Limpieza de archivos temporales
    [inspector1_signature_path, admin_signature_path, output_path_image].concat([inspector2_signature_path].compact).each do |path|
      File.delete(path) if File.exist?(path)
    end

=end


    tabla_path = Rails.root.join('app', 'templates', 'tabla_escala.docx')


    Omnidocx::Docx.merge_documents([output_path, tabla_path], output_path, false)


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



    rules.each_with_index do |rule, index|
      if revision.codes.include?(rule.code) && revision.points.include?(rule.point)
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
    end


    doc.commit(output_path)



    original_files.each do |file_path|
      File.delete(file_path) if File.exist?(file_path)
    end
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