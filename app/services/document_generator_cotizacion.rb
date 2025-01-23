require 'docx_replace'
require 'roo'

class DocumentGeneratorCotizacion
  def self.generate_document(facturacion_id)
    facturacion = Facturacion.find(facturacion_id)

    template_path = Rails.root.join('app', 'templates', 'cotizacion_template.docx')

    unless facturacion.solicitud_file.attached?
      raise "No se encontró un archivo adjunto en solicitud_file."
    end

    solicitud_file_path = Rails.root.join('tmp', "#{facturacion.solicitud_file.filename.to_s}")
    File.open(solicitud_file_path, 'wb') do |file|
      file.write(facturacion.solicitud_file.download)
    end

    # Abrir el archivo Excel
    xlsx = Roo::Excelx.new(solicitud_file_path)

    contacto_nombre = xlsx.cell('A', 5) || 'S/I'
    condominio = xlsx.cell('B', 5) || 'S/I'
    direccion = xlsx.cell('C', 5) || 'S/I'
    ascensores = xlsx.cell('D', 5) || 'S/I'
    pisos = xlsx.cell('E', 5) || 'S/I'
    correo = xlsx.cell('F', 5) || 'S/I'






    texto_capitalizado = direccion.split.map(&:capitalize).join(" ")

    partes = texto_capitalizado.split(/(\d+)/, 2)
    direccion_1 = "#{partes[0].strip} #{partes[1].strip}"
    direccion_2 = partes[2].strip




    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")

    doc.replace('{{condominio}}', condominio)
    doc.replace('{{direccion}}', direccion_1)
    doc.replace('{{direccion_provincia}}', direccion_2)


    output_path = Rails.root.join('tmp', "Cotizacion_N°#{facturacion.number}_#{Time.zone.today.strftime('%d-%m-%Y')}.docx")
    doc.commit(output_path)

    File.delete(solicitud_file_path) if File.exist?(solicitud_file_path)

    output_path
  end
end
