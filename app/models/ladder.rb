class Ladder < ApplicationRecord

  def self.ransackable_attributes(auth_object = nil)
    ["point", "code", "number", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    []  # No hay asociaciones buscables en este caso
  end

end
