#activos, ascensores, elevadores, etc.
class Item < ApplicationRecord


  def self.ransackable_attributes(auth_object = nil)
    ["identificador", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["principal"]
  end


  validates :identificador, presence: true

  belongs_to :group
  belongs_to :principal
  has_one :detail, dependent: :destroy
  has_many :inspections, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :revisions, dependent: :destroy
  has_one :ladder_detail, dependent: :destroy
  has_many :ladder_revisions, dependent: :destroy
  has_many :plat_revisions, dependent: :destroy
  has_many :anothers, dependent: :destroy


  def inspector?
    self.inspections.each do |inspection|
      return true if inspection.users.exists?(id: Current.user&.id)
    end
    false
  end


  def identificador_provisorio?
    identificador.to_s.include?("CAMBIAME")
  end

  def cambiar_identificador!(nuevo)
    nuevo = nuevo.to_s.strip
    return false if nuevo.blank? || nuevo == identificador

    update!(identificador_anterior: identificador, identificador: nuevo)
  end

  def corregir_identificador!(nuevo)
    nuevo = nuevo.to_s.strip
    return false if nuevo.blank? || nuevo == identificador

    erroneo = identificador

    transaction do
      update!(identificador: nuevo)
      inspections.where(identificador: erroneo)
                 .update_all(identificador: nuevo, updated_at: Time.current)
    end
  end

  def corregir_identificador_anterior!(nuevo)
    nuevo = nuevo.to_s.strip
    return false if nuevo == identificador_anterior

    erroneo = identificador_anterior

    transaction do
      update!(identificador_anterior: nuevo.presence)
      inspections.where(identificador: erroneo)
                 .update_all(identificador: nuevo, updated_at: Time.current) if erroneo.present?
    end
  end

end