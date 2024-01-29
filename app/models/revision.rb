class Revision < ApplicationRecord

  serialize :codes, type: Array, coder: JSON
  serialize :flaws, type: Array, coder: JSON

  belongs_to :item
  belongs_to :group
  belongs_to :inspection

  def only_owner?
    self.inspection.user_id == Current.user&.id or Current.user&.admin?
  end



  private





end