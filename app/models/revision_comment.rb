class RevisionComment < ApplicationRecord
  belongs_to :revision, polymorphic: true
end