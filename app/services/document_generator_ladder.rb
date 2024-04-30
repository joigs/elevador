require 'docx_replace'
require 'omnidocx'
require 'fileutils'
require 'libreconv'
require 'pdf-reader'

class DocumentGeneratorLadder
  def self.generate_document(inspection_id, principal_id, revision_id, item_id, admin_id)

    inspection = Inspection.find(inspection_id)
    principal = Principal.find(principal_id)
    revision = LadderRevision.find(revision_id)
    item = Item.find(item_id)
    detail = item.ladder_detail
    report = Report.find_by(inspection_id: inspection.id)
    admin = User.find(admin_id)

    template_path = Rails.root.join('app', 'templates', 'template_ladder1.docx')

    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")

    doc.replace('{{XXX}}', inspection.number.to_s)
    doc.replace('{{MM}}', inspection.inf_date.strftime('%m'))
    doc.replace('{{XX}}', inspection.inf_date.strftime('%Y'))


    doc.replace('{{principal_name}}', principal.name)
    doc.replace('{{principal_business_name}}', principal.business_name)
    doc.replace('{{principal_rut}}', principal.rut)
    doc.replace('{{principal_contact_name}}', principal.contact_name)
    doc.replace('{{principal_email}}', principal.email)
    doc.replace('{{principal_phone}}', principal.phone)
    doc.replace('{{principal_cellphone}}', principal.cellphone)
    doc.replace('{{principal_contact_email}}', principal.contact_email)
    doc.replace('{{inspection_place}}', inspection.place)


    doc.replace('{{inspection_place}}', inspection.place)
    doc.replace('{{ins_date}}', inspection.ins_date.strftime('%d/%m/%Y'))
    doc.replace('{{inspector}}', inspection.user.real_name)
    doc.replace('{{admin}}', admin.real_name)
    doc.replace('{{inf_date}}', inspection.inf_date.strftime('%d/%m/%Y'))
    validation_s = inspection.validation.to_s
    validation_word = validation_s == '1' ? 'año' : 'años'
    doc.replace('{{inspection_validation}}',"#{validation_s} #{validation_word}")

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
      doc.replace('{{certificado_minvu}}', "Cumple/no aplica")
    end

    doc.replace('{{report_fecha}}', report.fecha&.strftime('%d/%m/%Y'))
    doc.replace('{{empresa_anterior}}', report.empresa_anterior)
    doc.replace('{{ea_rol}}', report.ea_rol)
    doc.replace('{{ea_rut}}', report.ea_rut)
    doc.replace('{{empresa_mantenedora}}', report.empresa_mantenedora)
    doc.replace('{{em_rol}}', report.em_rol)
    doc.replace('{{em_rut}}', report.em_rut)
    aux_date = report.vi_co_man_ini&.strftime('%d/%m/%Y') || ''
    doc.replace('{{vi_co_man_ini}}', aux_date)
    aux_date = report.vi_co_man_ter&.strftime('%d/%m/%Y') || ''
    doc.replace('{{vi_co_man_ter}}', aux_date)
    doc.replace('{{nom_tec_man}}', report.nom_tec_man)
    doc.replace('{{tm_rut}}', report.tm_rut)
    doc.replace('{{ul_reg_man}}', report.ul_reg_man)
    aux_date = report.urm_fecha&.strftime('%d/%m/%Y') || ''
    doc.replace('{{urm_fecha}}', aux_date)
    doc.replace('{{item_identificador}}', item.identificador)

    doc.replace('{{ld_marca}}', detail.marca)
    doc.replace('{{ld_modelo}}', detail.modelo)
    doc.replace('{{ld_nserie}}', detail.nserie)
    doc.replace('{{mm_marca}}', detail.mm_marca)
    doc.replace('{{mm_nserie}}', detail.mm_nserie)
    doc.replace('{{potencia}}', detail.potencia.to_s)
    doc.replace('{{capacidad}}', detail.capacidad.to_s)
    doc.replace('{{personas}}', detail.personas.to_s)
    doc.replace('{{peldanos}}', detail.peldaños.to_s)
    doc.replace('{{longitud}}', detail.longitud.to_s)
    doc.replace('{{inclinacion}}', detail.inclinacion.to_s)
    doc.replace('{{ancho}}', detail.ancho.to_s)
    doc.replace('{{velocidad}}', detail.velocidad.to_s)
    doc.replace('{{fabricacion}}', detail.fabricacion.to_s)
    doc.replace('{{procedencia}}', detail.procedencia)



    last_revision = LadderRevision.where(item_id: item.id).order(created_at: :desc).offset(1).first
    last_errors = []


    if report.cert_ant == 'Si'

      if last_revision.nil?
        doc.replace('{{informe_anterior}}', "Con respecto al informe anterior con fecha #{report.fecha&.strftime('%d/%m/%Y')}:")
        doc.replace('{{revision_past_errors_level}}', "")

      end

      if last_revision&.levels.blank?
        doc.replace('{{informe_anterior}}', "")
        doc.replace('{{revision_past_errors_level}}', "")
      else


        last_revision.levels.each_with_index do |level, index|
          if level.include?("L")
            if revision.codes.include?(last_revision.codes[index])
              if revision.points.include?(last_revision.points[index])
                last_errors << last_revision.points[index]
              end
            end
          end
        end


        if last_errors.blank?
          doc.replace('{{informe_anterior}}', "Se levantan las conformidades Faltas Leves, indicadas en certificación anterior.")
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
      doc.replace('{{informe_anterior}}', "No presenta certificación anterior")
      doc.replace('{{revision_past_errors_level}}', "")
    end








    output_path = Rails.root.join('tmp', "Informe N°#{inspection.number.to_s}-#{inspection.inf_date.strftime('%m')}-#{inspection.inf_date.strftime('%Y')}.docx")
    doc.commit(output_path)

    template_path = Rails.root.join('app', 'templates', 'template_ladder3.docx')


    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")

    doc.replace('{{inspection_place}}', inspection.place)

    errors_graves = []
    errors_leves = []
    errors_all = []

    revision.levels.each_with_index do |level, index|
      if level.include?("G")
        if revision.comment[index].blank?
          errors_graves << ("#{revision.points[index]} (Esto No ocurre. No se hizo ningún comentario)")
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} falla grave. Razón: (Esto No ocurre. No se hizo ningún comentario)"

        else
          errors_graves << "#{revision.points[index]}. Razón: #{revision.comment[index]}"
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} falla grave. Razón: #{revision.comment[index]}"

        end
      elsif level.include?("L")
        if revision.comment[index].blank?
          errors_leves << ("#{revision.points[index]} (Esto No ocurre. No se hizo ningún comentario)")
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} falla leve. Razón: (Esto No ocurre. No se hizo ningún comentario)"

        else
          errors_leves << "#{revision.points[index]}. Razón: #{revision.comment[index]}}"
          errors_all << "Defecto: #{revision.codes[index]} #{revision.points[index]} falla leve. Razón: #{revision.comment[index]}"

        end
      end
    end

    if errors_all.blank?
      doc.replace('{{buen/regular/mal}}', "buen")
    elsif errors_graves.blank?
      doc.replace('{{buen/regular/mal}}', "regular")
    else
      doc.replace('{{buen/regular/mal}}', "mal")
    end
    cumple = []
    numbers = [1,2,3,4,5,6,7,8,11, 12, 13, 14, 15]
    numbers.each do |index|
      unless revision.codes.any? { |code| code.match?(/^5\.#{index}\./) }
        cumple << index
      end
    end

    aux = [
      '• Requisitos generales'                                                                                                                                                                                                                                                                                    ,
      '• Estructura de soporte (bastidor) y cerramiento'                                                                                                                                                                                                                                                                                    ,
      '• Escalones, placa, banda'                                                                                                                                                                                                                                                                                    ,
      '• Unidad de almacenamiento                                                                                                                                                                                                                                                                                    ',
      '•  Balaustrada                                                                                                                                                                                                                                                                                    ',
      '•  Pasamanos                                                                                                                                                                                                                                                                                    ',
      '•  Rellanos                                                                                                                                                                                                                                                                                    ',
      '•  Cuartos de maquinaria, estaciones de accionamiento y de retorno                                                                                                                                                                                                                                                                                    ',
      '• Instalaciones y aparatos eléctricos                                                                                                                                                                                                                                                                                    ',
      '• Protección contra fallos eléctricos-maniobra                                                                                                                                                                                                                                                                                    ',
      '• Interfaces con el edificio                                                                                                                                                                                                                                                                                    ',
      '• Señales de seguridad para los usuarios                                                                                                                                                                                                                                                                                    ',
      '• Utilización de carros de compra y de carros de equipaje                                                                                                                                                                                                                                                                                    '
    ]


    cumple_text = cumple.map { |index| "#{aux[index]}                                                                                                                                                       " }.join("\n")

    doc.replace('{{lista_comprobacion_cumple}}', cumple_text)


    errors_leves_text = errors_leves.map { |error| "• #{error}\n                                                                                                                                                                                                                                                                         " }.join("\n")
    errors_graves_text = errors_graves.map { |error| "• #{error}\n                                                                                                                                                                                                        " }.join("\n")

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

    output_path2 = Rails.root.join('tmp', "part3.docx")
    doc.commit(output_path2)

    original_files = []

    revision_photos = RevisionPhoto.where(revision_id: revision_id, revision_type: 'LadderRevision')
    set_of_errors = []

    Omnidocx::Docx.replace_footer_content(replacement_hash={ "{{ins_num}}" => inspection.number.to_s }, output_path, output_path)


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
          original_files << output_path_var
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
    original_files << output_path2



    pdf_path = "#{Rails.root}/tmp/#{inspection.number.to_s}.pdf"

    Libreconv.convert(output_path, pdf_path)

    reader = PDF::Reader.new(pdf_path)
    number_of_pages = reader.page_count

    Omnidocx::Docx.replace_footer_content(replacement_hash={ "{{number_of_pages}}" => number_of_pages.to_s}, output_path, output_path)




    original_files.each do |file_path|
      File.delete(file_path) if File.exist?(file_path)
    end
    return output_path
  end

  private

  def self.prepare_images_for_document(revision_id, code)
    revision_photos = RevisionPhoto.where(revision_id: revision_id, revision_type: 'LadderRevision', code: code)

    max_width_per_image = 300

    images_to_write = revision_photos.map do |revision_photo|
      if revision_photo.photo.attached?
        temp_path = save_temp_image(revision_photo.photo)
        {
          :path => temp_path,
          :height => 300,
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