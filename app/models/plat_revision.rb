class PlatRevision < ApplicationRecord
  belongs_to :item
  belongs_to :inspection
  belongs_to :group

  has_many :plat_revision_rules_plats, dependent: :destroy
  has_many :rules_plats, through: :plat_revision_rules_plats
  has_many :plat_revision_sections, dependent: :destroy
  has_many :revision_comments, as: :revision, dependent: :destroy


  has_many :revision_photos, as: :revision, dependent: :destroy
  has_many :revision_nulls, as: :revision, dependent: :destroy
  has_many :inclusion_checks, as: :revision, dependent: :destroy

  accepts_nested_attributes_for :revision_photos, allow_destroy: true
  accepts_nested_attributes_for :revision_nulls, allow_destroy: true



  def inclusion_posible?
    group.secondary_type == "plataforma"
  end

  def inclusion_aplica?
    inclusion_posible? && inspection.report&.inclusion == true
  end

  def only_owner?
    inspection = Inspection.find_by(id: self.inspection_id)
    inspection.users.exists?(id: Current.user&.id)
  end


end