class Report < ApplicationRecord
  belongs_to :inspection
  belongs_to :item
end
