require 'docx_replace'
require 'omnidocx'
require 'fileutils'

class DocumentGeneratorLadder
  def self.generate_document(inspection_id, principal_id, revision_id, item_id, admin_id)

    inspection = Inspection.find(inspection_id)
    principal = Principal.find(principal_id)
    revision = LadderRevision.find(revision_id)
    item = Item.find(item_id)
    group = item.group
    detail = item.ladder_detail
    report = Report.find_by(inspection_id: inspection.id)
    admin = User.find(admin_id)

    template_path = Rails.root.join('app', 'templates', 'template_ladder.docx')

    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")
    output_path = Rails.root.join('tmp', "Informe N°#{inspection.number.to_s}-#{inspection.inf_date.strftime('%m')}-#{inspection.inf_date.strftime('%Y')}.docx")
    doc.commit(output_path)

    return output_path

  end


end