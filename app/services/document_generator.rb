# app/services/document_generator.rb

require 'docx_replace'

class DocumentGenerator
  def self.generate_document(principal_id, revision_id)
    principal = Principal.find(principal_id)
    revision = Revision.find(revision_id)
    template_path = Rails.root.join('app', 'templates', 'template.docx')

    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")

    doc.replace('{{principal_name}}', principal.name)
    doc.replace('{{principal_business_name}}', principal.business_name)
    doc.replace('{{principal_rut}}', principal.rut)

    output_path = Rails.root.join('tmp', "#{principal.name}_document.docx")
    doc.commit(output_path)

    return output_path
  end
end

