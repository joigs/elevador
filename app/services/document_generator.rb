
require 'docx_replace'
require 'omnidocx'
require 'fileutils'
require 'mini_magick'
require 'tempfile'
require 'securerandom'

class DocumentGenerator
  def self.generate_document(inspection_id, principal_id, revision_id, item_id, admin_id)
    inspection = Inspection.find(inspection_id)
    principal = Principal.find(principal_id)
    revision = Revision.find(revision_id)
    item = Item.find(item_id)
    group = item.group
    detail = item.detail
    report = Report.find_by(inspection_id: inspection.id)
    admin = User.find(admin_id)
    inspector = inspection.user

    template_path = Rails.root.join('app', 'templates', 'template_1.docx')

    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")

    doc.replace('{{XXX}}', inspection.number.to_s)
    doc.replace('{{MM}}', inspection.ins_date&.strftime('%m'))
    doc.replace('{{XX}}', inspection.ins_date&.strftime('%Y'))

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
    doc.replace('{{inspector}}', inspection.user.real_name)
    doc.replace('{{admin}}', admin.real_name)
    doc.replace('{{inf_date}}', inspection.inf_date&.strftime('%d/%m/%Y'))

    doc.replace('{{inspection_validation}}', report.ending&.strftime('%d/%m/%Y'))

    if report.cert_ant == 'Si'
      doc.replace('{{cert_si}}', 'X')
      doc.replace('{{cert_no}}', '')

    elsif report.cert_ant == 'No'
      doc.replace('{{cert_si}}', '')
      doc.replace('{{cert_no}}', 'X')
    else
      doc.replace('{{cert_si}}', '')
      doc.replace('{{cert_no}}', '')
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
      doc.replace('{{detail_numero_permiso}}', detail.numero_permiso)
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
      doc.replace('{{detail_porcentaje}}', detail.porcentaje.to_s)
    else
      doc.replace('{{detail_porcentaje}}', "S/I")
    end

    doc.replace('{{detail_descripcion}}', detail.descripcion)



    if group.number == 1
      doc.replace('{{grupo1}}', 'X')
      doc.replace('{{grupo2}}', '')
      doc.replace('{{grupo3}}', '')
    elsif group.number == 2
      doc.replace('{{grupo1}}', '')
      doc.replace('{{grupo2}}', 'X')
      doc.replace('{{grupo3}}', '')

    elsif group.number == 3
      doc.replace('{{grupo1}}', '')
      doc.replace('{{grupo2}}', '')
      doc.replace('{{grupo3}}', 'X')
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



    last_revision = Revision.where(item_id: item.id).order(created_at: :desc).offset(1).first
    last_errors = []


    if report.cert_ant == 'Si'

      if last_revision.nil?

        doc.replace('{{informe_anterior}}', "Con respecto al informe anterior con fecha #{report.fecha&.strftime('%d/%m/%Y')}:")
        doc.replace('{{revision_past_errors_level}}', "")

      end

      if last_revision&.levels.blank?
        doc.replace('{{informe_anterior}}', "Informe anterior sin fallas registradas")
        doc.replace('{{revision_past_errors_level}}', "")
      else



        last_revision.levels.each_with_index do |level, index|
          if level.include?("L")
            if revision.codes.include?(last_revision.codes[index])
              if revision.points.include?(last_revision.points[index])
                last_errors << last_revision.codes[index] + " " + last_revision.points[index]
              end
            end
          end
        end



        if last_errors.blank?


          doc.replace('{{informe_anterior}}', "Se levantan todas las conformidades Faltas Leves, indicadas en certificación anterior.")
          doc.replace('{{revision_past_errors_level}}', "")

        else
          last_inspection = Inspection.find(last_revision.inspection_id)
          formatted_errors = last_errors.map { |last_error| "• #{last_error}\n                                          " }.join("\n")

          if last_inspection.number > 0
            last_inspection_inf_date = last_inspection.inf_date
            doc.replace('{{informe_anterior}}', "Se mantienen las no conformidades leves indicadas en informe anterior N°#{last_inspection.number} de fecha:#{last_inspection_inf_date&.strftime('%d/%m/%Y')}, las cuales se detallan a continuación:")
            doc.replace('{{revision_past_errors_level}}', formatted_errors)

          else

            if report.empresa_anterior=="S/I"
              doc.replace('{{informe_anterior}}', "Se mantienen las no conformidades leves indicadas en informe anterior realizado por empresa sin identificar, las cuales se detallan a continuación:")
            else
              doc.replace('{{informe_anterior}}', "Se mantienen las no conformidades leves indicadas en informe anterior realizado por #{report.empresa_anterior}, las cuales se detallan a continuación:")
            end
            doc.replace('{{revision_past_errors_level}}', formatted_errors)
          end


        end
      end

      else
        doc.replace('{{informe_anterior}}', "No existe información de informe anterior")
        doc.replace('{{revision_past_errors_level}}', "")
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


    output_path = Rails.root.join('tmp', "Informe N°#{inspection.number.to_s}-#{inspection.ins_date&.strftime('%m')}-#{inspection.ins_date&.strftime('%Y')}.docx")
    doc.commit(output_path)

    template_path = Rails.root.join('app', 'templates', 'template_3.docx')

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
        '•1. Carpeta cero.                                                                                                                                                             ',
        '•2. Caja de elevadores.                                                                                                                                                             ',
        '•3. Espacio de máquinas y poleas (para ascensores sin cuarto de máquinas aplica cláusula 9).                                                                                        ',
        '•4. Puerta de piso.                                                                                                                                                                 ',
        '•5. Cabina, contrapeso y masa de equilibrio.                                                                                                                                        ',
        '•6. Suspensión, compensación, protección contra la sobre velocidad y protección contra el movimiento incontrolado de la cabina.                                                               ',
        '•7. Guías, amortiguadores y dispositivos de seguridad de final de recorrido.                                                                                                        ',
        '•8. Holguras entre cabina y paredes de los accesos, así como entre contrapeso o masa de equilibrado.                                                                                ',
        '•10. Ascensores sin sala de máquinas.                                                                                                                                                ',
        '•11. Protección contra defectos eléctricos, mandos y prioridades.                                                                                                                    ',
        '•12. Ascensores con excepciones autorizadas, en los que se hayan realizado modificaciones importantes, o que cumplan normativa particular'
      ]


    else
      aux = [
        '•1. Carpeta cero.                                                                                                                                                             ',
        '•3. Espacio de máquinas y poleas (para ascensores sin cuarto de máquinas aplica cláusula 9).                                                                                        ',
        '•4. Puerta de piso.                                                                                                                                                                 ',
        '•5. Cabina, contrapeso y masa de equilibrio.                                                                                                                                        ',
        '•6. Suspensión, compensación, protección contra la sobre velocidad y protección contra el movimiento incontrolado de la cabina.                                                               ',
        '•7. Guías, amortiguadores y dispositivos de seguridad de final de recorrido.                                                                                                        ',
        '•8. Holguras entre cabina y paredes de los accesos, así como entre contrapeso o masa de equilibrado.                                                                                ',
        '•9. Máquina.                                                                                                                                                                        ',
        '•10. Ascensores sin sala de máquinas.                                                                                                                                                ',
        '•11. Protección contra defectos eléctricos, mandos y prioridades.                                                                                                                    ',
        '•12. Ascensores con excepciones autorizadas, en los que se hayan realizado modificaciones importantes, o que cumplan normativa particular'
      ]
    end


    cumple_text = cumple.map { |index| "#{aux[index]}                                                                                                                                                       " }.join("\n")
    no_cumple_text = no_cumple.map { |index| "#{aux[index]}                                                                                                                                                 " }.join("\n")

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
          errors_leves << "#{revision.codes[index]} #{revision.points[index]}. Razón: #{revision.comment[index]}}"
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} falla leve. Razón: #{revision.comment[index]}"

        end
      end
    end


    if errors_leves.any?
      errors_leves_text = errors_leves.map { |error| "• #{error}\n                                                                                                                                                                                                                                                                         " }.join("\n")
      doc.replace('{{revision_errors_leves}}', errors_leves_text)
      doc.replace('{{si_las_hubiera_leve}}', 'Las no conformidades, Faltas Leves, encontradas en la inspección son las siguientes:')
    else
      doc.replace('{{revision_errors_leves}}', '')
      doc.replace('{{si_las_hubiera_leve}}', 'No se encontraron faltas leves en la inspección.')
    end

    if errors_graves.any?
      errors_graves_text = errors_graves.map { |error| "• #{error}\n                                                                                                                                                                                                        " }.join("\n")
      doc.replace('{{revision_errors_graves}}', errors_graves_text)
      doc.replace('{{si_las_hubiera_grave}}', 'Las no conformidades, Faltas Graves, encontradas en la inspección son las siguientes:')
    else
      doc.replace('{{revision_errors_graves}}', '')
      doc.replace('{{si_las_hubiera_grave}}', 'No se encontraron faltas graves en la inspección.')
    end

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
    end


    if !errors_graves.empty?
      doc.replace('{{cumple/parcial/no_cumple}}', "no cumple")
      doc.replace('{{esta/no_esta}}', "no está")
      doc.replace('{{texto_grave}}', "Las No Conformidades evaluadas como Faltas Graves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas dentro de 90 días desde la fecha del informe de inspección.")
      if !errors_leves.empty?
        doc.replace('{{texto_leve}}', "Las No Conformidades evaluadas como Faltas Leves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas antes de la próxima CERTIFICACION en mes de #{mapped_month}.")
      else
        doc.replace('{{texto_leve}}', "")
      end

    end

    if !errors_leves.empty? && errors_graves.empty?
      doc.replace('{{cumple/parcial/no_cumple}}', "cumple parcialmente")
      doc.replace('{{esta/no_esta}}', "está")
      doc.replace('{{texto_grave}}', "")
      doc.replace('{{texto_leve}}', "Las No Conformidades evaluadas como Faltas Leves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas antes de la próxima CERTIFICACION en mes de #{mapped_month}.")
    end

    doc.replace('{{admin}}', admin.real_name)
    doc.replace('{{inspector}}', inspector.real_name)




    doc.replace('{{inspector_profesion}}', inspector.profesion)
    doc.replace('{{admin_profesion}}', admin.profesion)

    output_path2 = Rails.root.join('tmp', "part3.docx")
    doc.commit(output_path2)








    original_files = []

    revision_photos = RevisionPhoto.where(revision_id: revision_id, revision_type: 'Revision')

    Omnidocx::Docx.replace_footer_content(replacement_hash={ "{{day}}" => inspection.ins_date&.strftime('%d'), "{{month}}" => inspection.ins_date&.strftime('%m'), "{{year}}" => inspection.ins_date&.strftime('%Y') }, output_path, output_path)




    Omnidocx::Docx.replace_footer_content(replacement_hash={ "{{XXX}}" => inspection.number.to_s}, output_path, output_path)




    set_of_errors = []

    revision.codes.each_with_index.chunk_while { |(_, i), (_, j)| revision.codes[i] == revision.codes[j] }.each_with_index do |group, group_index|
      group.each do |code, index|

        template_path = Rails.root.join('app', 'templates', 'template_2.docx')
        doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")
        set_of_errors << errors_all[index]

        has_matching_photo = revision_photos.any? { |photo| photo.code == code }

        next_code_different = (revision.codes[index+1] != code rescue true)

        if has_matching_photo && next_code_different
          errors_all_text = set_of_errors.map { |error| "• #{error}\n                                                                                                                                                                                                                                                     " }.join("\n")
          doc.replace('{{loop_falla}}', errors_all_text)
          output_path_var = Rails.root.join('tmp', "part2.#{group_index}.docx")
          doc.commit(output_path_var)
          original_files << output_path_var # Track the file for later deletion
          Omnidocx::Docx.merge_documents([output_path, output_path_var], output_path, false)
          images_to_write = prepare_images_for_document(revision_id, code)
          Omnidocx::Docx.write_images_to_doc(images_to_write, output_path, output_path)
          cleanup_temporary_images(images_to_write)
          set_of_errors = []

        elsif index == revision.codes.length - 1
          errors_all_text = set_of_errors.map { |error| "• #{error}\n                                                                                                                                                                                                                                                     " }.join("\n")
          doc.replace('{{loop_falla}}', errors_all_text)
          output_path_var = Rails.root.join('tmp', "part2.#{group_index}.docx")
          doc.commit(output_path_var)
          original_files << output_path_var
          Omnidocx::Docx.merge_documents([output_path, output_path_var], output_path, false)
        end
      end
    end



    Omnidocx::Docx.merge_documents([output_path, 'tmp/part3.docx'], output_path, true)

    original_files << 'tmp/part3.docx'






    inspector_signature_path = Rails.root.join('tmp', 'inspector_signature.jpg')
    admin_signature_path = Rails.root.join('tmp', 'admin_signature.jpg')
    third_image_path = Rails.root.join('app', 'templates', 'blanco.jpg')

    [inspector_signature_path, admin_signature_path].each do |path|
      File.open(path, 'wb') do |file|
        file.write(path == inspector_signature_path ? inspector.signature.download : admin.signature.download)
      end
      image = MiniMagick::Image.open(path)
      image.resize "300x"
      image.write(path)
    end

    third_image = MiniMagick::Image.open(third_image_path)
    third_image.resize "100x"
    third_image.write(third_image_path)

    images = [
      inspector_signature_path,
      third_image_path,
      admin_signature_path
    ]

    random_hex = SecureRandom.hex(4)
    output_filename = "inspector_#{inspector.username}_admin_#{admin.username}_#{random_hex}.jpg"
    output_path_image = Rails.root.join('tmp', output_filename)

    MiniMagick::Tool::Montage.new do |montage|
      montage.geometry "300x+0+0"
      montage.tile "3x1"
      images.each { |i| montage << i }
      montage << output_path_image.to_s
    end

    images_to_write = [
      {
        :path => output_path_image.to_s,
        :height => 300,
        :width => 800
      }
    ]

    Omnidocx::Docx.write_images_to_doc(images_to_write, output_path, output_path)

    [inspector_signature_path, admin_signature_path, output_path_image].each do |path|
      File.delete(path) if File.exist?(path)
    end



    original_files.each do |file_path|
      File.delete(file_path) if File.exist?(file_path)
    end


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