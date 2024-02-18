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
    doc.replace('{{detail_n_serie}}', detail.n_serie)
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


    doc.replace('{{item_group}}', item.group.number)





    output_path = Rails.root.join('tmp', "#{principal.name}_document.docx")
    doc.commit(output_path)

    return output_path
  end
end

