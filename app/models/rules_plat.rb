class RulesPlat < ApplicationRecord

  def self.ransackable_attributes(_auth_object = nil)
    %w[code point ref created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  serialize :level, type: Array, coder: JSON

  validates :point, presence: true
  validate :level_array_presence
  belongs_to :group, optional: true
  before_save :set_code

  scope :ordered_by_code, lambda {
    select("#{table_name}.*")
      .order(
        Arel.sql(
          "
          CAST(SUBSTRING_INDEX(code, '.', 1) AS UNSIGNED),
          CAST(SUBSTRING_INDEX(code, '.', -1) AS UNSIGNED)
          "
        )
      )
  }

  private


  def set_code
    return if code.present?

    base_number =
      if ref.present? && ref.match?(/\A\d+(\.\d+)*\z/)
        ref.split(".")[0..1].join(".")
      else
        "1.1"
      end

    max_suffix =
      self.class
          .where("code LIKE ?", "#{base_number}.%")
          .pluck(:code)
          .map { |c| c.split(".").last.to_i }
          .max

    suffix = max_suffix ? max_suffix + 1 : 1
    self.code = "#{base_number}.#{suffix}"
  end

  def level_array_presence
    if level.blank? || level.all?(&:blank?)
      errors.add(:level, "Debe asignar al menos un nivel")
    end
  end
end
