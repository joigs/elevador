class PlatRevisionRulesPlat < ApplicationRecord
  belongs_to :plat_revision
  belongs_to :rules_plat

  has_one :revision_photo, dependent: :destroy
end