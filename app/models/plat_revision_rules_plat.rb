class PlatRevisionRulesPlat < ApplicationRecord
  belongs_to :plat_revision
  belongs_to :rules_plat

  validates :comment, allow_blank: true, length: { maximum: 10_000 }
  validates :level, presence: true, inclusion: { in: ['L', 'G', 'LG'] }
  has_one :revision_photo, dependent: :destroy
end