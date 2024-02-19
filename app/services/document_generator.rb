# app/services/document_generator.rb

require 'docx_replace'

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

    template_path = Rails.root.join('app', 'templates', 'template.docx')

    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")

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

    doc.replace('{{instalation_number}}', report.instalation_number)
    doc.replace('{{certificado_minvu}}', report.certificado_minvu)

    doc.replace('{{report_fecha}}', inspection.inf_date.strftime('%d/%m/%Y'))
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
    doc.replace('{{detail_detalle}}', detail.detalle)
    doc.replace('{{detail_marca}}', detail.marca)
    doc.replace('{{detail_modelo}}', detail.modelo)
    doc.replace('{{detail_n_serie}}                                                                                                                                           ', detail.n_serie)

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
    doc.replace('{{detail_potencia}}', detail.potencia)
    doc.replace('{{detail_capacidad}}', detail.capacidad)
    doc.replace('{{detail_personas}}', detail.personas)
    doc.replace('{{detail_ct_marca}}', detail.ct_marca)
    doc.replace('{{detail_ct_cantidad}}', detail.ct_cantidad)
    doc.replace('{{detail_ct_diametro}}', detail.ct_diametro)
    doc.replace('{{detail_medidas_cintas}}', detail.medidas_cintas)
    doc.replace('{{detail_rv_marca}}', detail.rv_marca)
    doc.replace('{{detail_rv_n_serie}}', detail.rv_n_serie)
    doc.replace('{{detail_paradas}}', detail.paradas)
    doc.replace('{{detail_embarques}}', detail.embarques)
    doc.replace('{{detail_sala_maquinas}}', detail.sala_maquinas)



    if item.group.number <=3
      doc.replace('{{item_group}}', item.group.number.to_s)
    else
      doc.replace('{{item_group}}', item.group.name)
    end


    last_revision = Revision.where(item_id: item.id).order(created_at: :desc).offset(1).first
    last_errors = []



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
        last_inspection_inf_date = Inspection.find(last_revision.inspection_id).inf_date
        formatted_errors = last_errors.map { |last_error| "• #{last_error}\n                                          " }.join("\n")
        doc.replace('{{informe_anterior}}', "Se mantienen las no conformidades leves indicadas en informe anterior N°#{last_revision.number} de fecha:#{last_inspection_inf_date.strftime('%d/%m/%Y')}, las cuales se detallan a continuación:")
        doc.replace('{{revision_past_errors_level}}', formatted_errors)

      end
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

    carpetas.each do |carpeta|
      indice = revision.codes.find_index(carpeta)
      if indice
        doc.replace('{{carpeta_si}}', '')
        doc.replace('{{carpeta_no}}', 'X')
        if revision.levels[indice] == 'L'
          doc.replace('{{carpeta_g}}', '')
          doc.replace('{{carpeta_l}}', 'X')
        else
          doc.replace('{{carpeta_g}}', 'X')
          doc.replace('{{carpeta_l}}', '')
        end
        doc.replace('{{carpeta_comentario}}', revision.comment[indice])
      else
        doc.replace('{{carpeta_si}}', 'X')
        doc.replace('{{carpeta_no}}', '')
        doc.replace('{{carpeta_g}}', '')
        doc.replace('{{carpeta_l}}', '')
        doc.replace('{{carpeta_comentario}}', '')
      end
    end


            doc.replace('{{item_group2}}', "F#{item.group.number}-PO-ASC-01 #{item.group.name}")

    doc.replace('{{inspection_place}}', inspection.place)
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
      '• Carpeta cero.                                                                                                                                                             ',
      '• Caja de elevadores.                                                                                                                                                             ',
      '• Espacio de máquinas y poleas (para ascensores sin cuarto de máquinas aplica cláusula 9).                                                                                        ',
      '• Puerta de piso.                                                                                                                                                                 ',
      '• Cabina, contrapeso y masa de equilibrio.                                                                                                                                        ',
      '• Suspensión, compensación, protección contra la sobre velocidad y protección contra el movimiento incontrolado de la cabina.                                                               ',
      '• Guías, amortiguadores y dispositivos de seguridad de final de recorrido.                                                                                                        ',
      '• Holguras entre cabina y paredes de los accesos, así como entre contrapeso o masa de equilibrado.                                                                                ',
      '• Máquina.                                                                                                                                                                        ',
      '• Ascensores sin sala de máquinas.                                                                                                                                                ',
      '• Protección contra defectos eléctricos, mandos y prioridades.                                                                                                                    ',
      '• Ascensores con excepciones autorizadas, en los que se hayan realizado modificaciones importantes, o que cumplan normativa particular'
    ]

    cumple_text = cumple.map { |index| "#{aux[index]}                                                                                                                                                       " }.join("\n")
    no_cumple_text = no_cumple.map { |index| "#{aux[index]}                                                                                                                                                 " }.join("\n")

    doc.replace('{{lista_comprobacion_cumple}}', cumple_text)
    doc.replace('{{lista_comprobacion_no_cumple}}', no_cumple_text)

    errors_graves = []
    errors_leves = []

    revision.levels.each_with_index do |level, index|
      if level.include?("G")
        if revision.comment[index].blank?
          errors_graves << revision.points[index]
        else
          errors_graves << revision.comment[index]
        end
      elsif level.include?("L")
        if revision.comment[index].blank?
          errors_leves << revision.points[index]
        else
          errors_leves << revision.comment[index]
        end
      end
    end

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

    # Assuming last_digit_before_dash contains the last digit as a string
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

    if !errors_leves.empty? and errors_graves.empty?
      doc.replace('{{cumple/parcial/no_cumple}}', "cumple parcialmente")
      doc.replace('{{esta/no_esta}}', "está")
      doc.replace('{{texto_grave}}', "")
      doc.replace('{{texto_leve}}', "Las No Conformidades evaluadas como Faltas Leves, deben ser resueltas por la administración, de tal manera de dar cumplimiento en forma integral a la normativa vigente, éstas deben quedar resueltas antes de la próxima CERTIFICACION en mes de #{mapped_month}.")
    end


    doc.replace('{{admin}}', "        #{admin.real_name}")
    doc.replace('{{inspector}}', "inspection.user.real_name")


    output_path = Rails.root.join('tmp', "#{principal.name}_document.docx")
    doc.commit(output_path)

    return output_path
  end
end

