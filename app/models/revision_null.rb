class RevisionNull < ApplicationRecord
  belongs_to :revision, polymorphic: true
end