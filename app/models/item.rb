#activos, ascensores, elevadores, etc.
class Item < ApplicationRecord


  def self.ransackable_attributes(auth_object = nil)
    ["identificador", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["principal"]
  end


  validates :identificador, presence: true, uniqueness: true

  belongs_to :group
  belongs_to :principal
  has_one :detail, dependent: :destroy
  has_many :inspections, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :revisions, dependent: :destroy
  has_one :ladder_detail, dependent: :destroy
  has_many :ladder_revisions, dependent: :destroy
  def inspector?
    self.inspections.each do |inspection|
      return true if inspection.users.exists?(id: Current.user&.id)
    end
    false
  end


end
