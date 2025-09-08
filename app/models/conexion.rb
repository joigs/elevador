class Conexion < ApplicationRecord
  belongs_to :original_inspection, class_name: 'Inspection'
  belongs_to :copy_inspection,     class_name: 'Inspection'
end
