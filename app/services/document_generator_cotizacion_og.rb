require 'roo'
require 'docx_replace'
require 'json'
require 'open3'
require 'date'
require 'securerandom'

class DocumentGeneratorCotizacionOg
  MARKER_MAP = {
    'condominio' => '{{condominio2}}',
    'direccion'  => '{{direccion3}}',
    'ascensores' => '{{ascensores}}',
    'paradas'    => '{{paradas}}'
  }.freeze

  PYTHON_SCRIPT = Rails.root.join('app', 'scripts', 'fill_cotizacion_table.py')

  MESES = {
    'January' => 'enero', 'February' => 'febrero', 'March' => 'marzo',
    'April' => 'abril', 'May' => 'mayo', 'June' => 'junio',
    'July' => 'julio', 'August' => 'agosto', 'September' => 'septiembre',
    'October' => 'octubre', 'November' => 'noviembre', 'December' => 'diciembre'
  }.freeze

  def self.generate_document(facturacion_id)
    facturacion   = Facturacion.find(facturacion_id)
    template_path = Rails.root.join('app', 'templates', 'cotizacion_template_og.docx')

    unless facturacion.solicitud_file.attached?
      raise 'No se encontró un archivo adjunto en solicitud_file.'
    end

    solicitud_file_path = Rails.root.join('tmp', facturacion.solicitud_file.filename.to_s)
    File.open(solicitud_file_path, 'wb') { |f| f.write(facturacion.solicitud_file.download) }

    begin
      xlsx     = Roo::Excelx.new(solicitud_file_path)
      keywords = column_map(xlsx)
      rows     = read_rows(xlsx, keywords)
      first    = rows.first

      intermediate_path = Rails.root.join('tmp', "cotizacion_og_tabla_#{SecureRandom.hex(6)}.docx")
      expand_table(template_path, rows, intermediate_path)

      condominio = first['condominio']
      direccion  = first['direccion']
      contacto   = first['contacto']
      ascensores = first['ascensores']
      paradas    = first['paradas']

      direccion_1, direccion_2 = split_direccion(direccion)
      fecha = fecha_larga

      doc = DocxReplace::Doc.new(intermediate_path, "#{Rails.root}/tmp")

      doc.replace('{{condominio}}', condominio)
      doc.replace('{{direccion}}', direccion_1)
      doc.replace('{{direccion_provincia}}', direccion_2)
      doc.replace('{{contacto_nombre}}', contacto)
      doc.replace('{{ascensores}}', ascensores)
      doc.replace('{{paradas}}', paradas)
      doc.replace('{{condominio2}}', condominio)
      doc.replace('{{direccion2}}', direccion)
      doc.replace('{{direccion3}}', direccion)
      doc.replace('{{numero_corr}}', "#{facturacion.number}-#{Time.zone.today.strftime('%m-%Y')}")
      doc.replace('{{fecha}}', fecha)
      doc.replace('{{ascensores2}}', ascensores)
      doc.replace('{{paradas2}}', paradas)
      doc.replace('{{direccion4}}', "#{condominio} #{direccion_2}")

      output_path = Rails.root.join('tmp', "Cotizacion_N°#{facturacion.number}_#{Time.zone.today.strftime('%d-%m-%Y')}.docx")
      doc.commit(output_path)

      File.delete(intermediate_path) if File.exist?(intermediate_path)
      output_path
    ensure
      File.delete(solicitud_file_path) if File.exist?(solicitud_file_path)
    end
  end


  def self.column_map(xlsx)
    headers = xlsx.row(4).map { |h| h.to_s.downcase.strip }
    keywords = {
      'contacto' => nil, 'condominio' => nil, 'edificio' => nil,
      'dire' => nil, 'ubica' => nil, 'ascensor' => nil, 'parada' => nil
    }
    headers.each_with_index do |header, index|
      keywords.each_key { |k| keywords[k] = index + 1 if header.include?(k) }
    end
    keywords
  end
  private_class_method :column_map

  def self.cell(xlsx, row, col)
    return nil if col.nil?

    xlsx.cell(row, col)
  end
  private_class_method :cell

  def self.clean(value)
    return nil if value.nil?

    if value.is_a?(Float) && value == value.to_i
      value.to_i.to_s
    else
      s = value.to_s.strip
      s.empty? ? nil : s
    end
  end
  private_class_method :clean

  def self.read_rows(xlsx, keywords)
    first_row = 5
    last_row  = xlsx.last_row || first_row
    rows = []

    (first_row..last_row).each do |r|
      condominio = clean(cell(xlsx, r, keywords['condominio'])) || clean(cell(xlsx, r, keywords['edificio']))
      direccion  = clean(cell(xlsx, r, keywords['dire']))       || clean(cell(xlsx, r, keywords['ubica']))
      ascensores = clean(cell(xlsx, r, keywords['ascensor']))
      paradas    = clean(cell(xlsx, r, keywords['parada']))
      contacto   = clean(cell(xlsx, r, keywords['contacto']))

      next if [condominio, direccion, ascensores, paradas, contacto].all?(&:nil?)

      rows << {
        'condominio' => condominio || 'S/I',
        'direccion'  => direccion  || 'S/I',
        'ascensores' => ascensores || 'S/I',
        'paradas'    => paradas    || 'S/I',
        'contacto'   => contacto   || 'S/I'
      }
    end

    if rows.empty?
      rows << {
        'condominio' => 'S/I', 'direccion' => 'S/I', 'ascensores' => 'S/I',
        'paradas' => 'S/I', 'contacto' => 'S/I'
      }
    end
    rows
  end
  private_class_method :read_rows

  def self.expand_table(template_path, rows, output_path)
    payload   = { 'rows' => rows, 'marker_map' => MARKER_MAP }
    json_path = Rails.root.join('tmp', "cotizacion_og_rows_#{SecureRandom.hex(6)}.json")
    File.write(json_path, JSON.generate(payload))

    stdout, stderr, status = Open3.capture3(
      'python3', PYTHON_SCRIPT.to_s,
      template_path.to_s, json_path.to_s, output_path.to_s
    )

    File.delete(json_path) if File.exist?(json_path)

    unless status.success?
      raise "Error al expandir la tabla (python): #{stderr.presence || stdout}"
    end

    output_path
  end
  private_class_method :expand_table

  def self.fecha_larga
    hoy = Time.zone.today
    "#{hoy.strftime('%d')} de #{MESES[hoy.strftime('%B')]} de #{hoy.strftime('%Y')}"
  end
  private_class_method :fecha_larga

  def self.split_direccion(direccion)
    texto  = direccion.to_s.split.map(&:capitalize).join(' ')
    partes = texto.split(/(\d+)/, 2)
    [partes[0..1].join(' ').strip, partes[2].to_s.strip]
  end
  private_class_method :split_direccion
end