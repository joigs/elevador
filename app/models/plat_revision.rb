class PlatRevision < ApplicationRecord
  belongs_to :item
  belongs_to :inspection

  has_many :plat_revision_rules_plats, dependent: :destroy
  has_many :rules_plats, through: :plat_revision_rules_plats

  has_many :revision_nulls, dependent: :destroy
end