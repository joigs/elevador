require 'roo'
require 'docx_replace'
require 'date'

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

    # Obtener la primera fila con encabezados normalizados
    headers = xlsx.row(4).map { |h| h.to_s.downcase.strip }

    # Palabras clave para cada campo
    keywords = {
      "contacto" => nil,
      "condominio" => nil,
      "edificio" => nil,
      "dire" => nil,
      "ubica" => nil,
      "ascensor" => nil,
      "piso" => nil
    }

    # Buscar las columnas en base a las palabras clave
    headers.each_with_index do |header, index|
      keywords.each_key do |keyword|
        if header.include?(keyword)
          keywords[keyword] = index + 1  # +1 porque Roo usa índices desde 1
        end
      end
    end

    # Asignar variables dinámicamente
    contacto_nombre = xlsx.cell(5, keywords["contacto"]) || 'S/I'
    condominio = xlsx.cell(5, keywords["condominio"]) || xlsx.cell(5, keywords["edificio"]) || 'S/I'
    direccion = xlsx.cell(5, keywords["dire"]) || xlsx.cell(5, keywords["ubica"]) || 'S/I'
    ascensores = xlsx.cell(5, keywords["ascensor"]) || 'S/I'
    pisos = xlsx.cell(5, keywords["piso"]) || 'S/I'

    fecha_actual = Time.zone.today
    meses_espanol = {
      "January" => "enero", "February" => "febrero", "March" => "marzo",
      "April" => "abril", "May" => "mayo", "June" => "junio",
      "July" => "julio", "August" => "agosto", "September" => "septiembre",
      "October" => "octubre", "November" => "noviembre", "December" => "diciembre"
    }
    mes = meses_espanol[fecha_actual.strftime("%B")]
    fecha = "#{fecha_actual.strftime("%d")} de #{mes} de #{fecha_actual.strftime("%Y")}"

    # Separar dirección en dos partes si tiene números
    texto_capitalizado = direccion.split.map(&:capitalize).join(" ")
    partes = texto_capitalizado.split(/(\d+)/, 2)
    direccion_1 = partes[0..1].join(" ").strip
    direccion_2 = partes[2].to_s.strip

    # Reemplazar en el documento
    doc = DocxReplace::Doc.new(template_path, "#{Rails.root}/tmp")

    doc.replace('{{condominio}}', condominio)
    doc.replace('{{direccion}}', direccion_1)
    doc.replace('{{direccion_provincia}}', direccion_2)
    doc.replace('{{contacto_nombre}}', contacto_nombre)
    doc.replace('{{ascensores}}', ascensores)
    doc.replace('{{paradas}}', pisos)
    doc.replace('{{condominio2}}', condominio)
    doc.replace('{{direccion2}}', direccion)
    doc.replace('{{direccion3}}', direccion)
    doc.replace('{{numero_corr}}', "#{facturacion.number.to_s}-#{Time.zone.today.strftime('%m-%Y')}")
    doc.replace('{{fecha}}', fecha)
    doc.replace('{{ascensores2}}', ascensores)
    doc.replace('{{paradas2}}', pisos)
    doc.replace('{{direccion4}}', "#{condominio} #{direccion_2}")


    doc.replace('{{excel_fecha_cotizacion}}', fecha)
    doc.replace('{{excel_cliente}}',        condominio)
    doc.replace('{{excel_contacto}}',       contacto_nombre)
    doc.replace('{{excel_lugar}}',          direccion)
    doc.replace('{{XXX}}',          facturacion.number)

    output_path = Rails.root.join('tmp', "Cotizacion_N°#{facturacion.number}_#{Time.zone.today.strftime('%d-%m-%Y')}.docx")
    doc.commit(output_path)

    File.delete(solicitud_file_path) if File.exist?(solicitud_file_path)

    output_path
  end
end
