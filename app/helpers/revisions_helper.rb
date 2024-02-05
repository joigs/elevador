module RevisionsHelper
  def other_rule(inspection_id, rule_code)
    revision = Revision.find_by(inspection_id: inspection_id, codes: rule_code)
    revision ? revision.flaws : nil
  end
end