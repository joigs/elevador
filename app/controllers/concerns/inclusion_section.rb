require "ostruct"

module InclusionSection
  extend ActiveSupport::Concern

  private

  def cargar_inclusion(registro)
    @inclusion_checks = registro.inclusion_checks.with_attached_photos.index_by(&:numero)
  end

  def colores_con_inclusion(colors, registro, seccion)
    lista = colors.to_a
    lista << OpenStruct.new(section: seccion, color: true) if registro.inclusion_checks.exists?
    lista
  end

  def actualizar_inclusion(registro, redirect_ok:, redirect_error:)
    guardar_inclusion(registro)

    if params[:imagen_general].present?
      registro.revision_photos.create!(photo: params[:imagen_general], code: "GENERALCODE#{params[:imagen_general_comment]}")
    end

    flash[:notice] = "Checklist actualizada"
    redirect_to redirect_ok
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "No se pudo guardar inclusión: #{e.record.errors.full_messages.to_sentence}"
    redirect_to redirect_error
  end

  def guardar_inclusion(registro)
    datos = params[:inclusion] || {}
    fotos_a_borrar = []

    InclusionCheck.transaction do
      InclusionCheck::CRITERIOS.each do |criterio|
        fila = datos[criterio[:numero].to_s] || {}

        check = registro.inclusion_checks.find_or_initialize_by(numero: criterio[:numero])
        check.no_implementado = fila[:no_implementado] == "1"
        check.na              = !check.no_implementado && fila[:na] == "1"
        check.comment         = fila[:comment].presence
        check.save!

        ids = Array(fila[:eliminar_fotos]).reject(&:blank?)
        fotos_a_borrar.concat(check.photos_attachments.where(id: ids).to_a) if ids.any?

        archivos = Array(fila[:photos]).reject(&:blank?)
        check.photos.attach(archivos) if archivos.any?
      end
    end

    fotos_a_borrar.each(&:purge_later)
  end
end
