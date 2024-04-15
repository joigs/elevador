class Detail < ApplicationRecord

  validates :n_serie, non_negative: true, allow_nil: true
  validates :mm_n_serie, non_negative: true, allow_nil: true
  validates :potencia, non_negative: true, allow_nil: true
  validates :capacidad, non_negative: true, allow_nil: true
  validates :personas, non_negative: true, allow_nil: true
  validates :ct_cantidad, non_negative: true, allow_nil: true
  validates :ct_diametro, non_negative: true, allow_nil: true
  validates :paradas, non_negative: true, allow_nil: true
  validates :embarques, non_negative: true, allow_nil: true
  validates :medidas_cintas, non_negative: true, allow_nil: true
  validates :rv_n_serie, non_negative: true, allow_nil: true

  belongs_to :item
end
