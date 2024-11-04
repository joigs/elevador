class RevisionColor < ApplicationRecord


  serialize :codes, type: Array,coder: JSON
  serialize :points, type: Array, coder: JSON
  serialize :levels, type: Array, coder: JSON
  serialize :fail, type: Array, coder: JSON
  serialize :comment, type: Array, coder: JSON
  serialize :number, type: Array, coder: JSON
  serialize :priority, type: Array, coder: JSON
  serialize :encore, type: Array, coder: JSON

  belongs_to :revision
end
