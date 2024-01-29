class Revision < ApplicationRecord

  serialize :codes, Array,coder: JSON
  serialize :flaws, Array, coder: JSON

  belongs_to :item
  belongs_to :group
  belongs_to :inspection

  private


  def only_owner?
    user_id == Current.user&.id
  end



end