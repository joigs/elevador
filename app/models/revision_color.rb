class RevisionColor < ApplicationRecord


  serialize :codes, Array, coder: JSON
  serialize :points, Array, coder: JSON
  serialize :levels, Array, coder: JSON
  serialize :comment, Array, coder: JSON
  serialize :number, Array, coder: JSON
  serialize :priority, Array, coder: JSON

  belongs_to :revision
end
