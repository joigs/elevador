class RevisionPhoto < ApplicationRecord

  validates :code , presence: true

  belongs_to :revision
  has_one_attached :photo
end

