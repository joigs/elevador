class GraficosController < ApplicationController
  def index
    @inspections = Inspection.where("number > 0").order(number: :desc)
    @year = params[:year].presence&.to_i || Date.current.year

    @available_years = @inspections.map { |i| i.ins_date.year }.uniq.sort
    @selected_year   = if params[:year] == 'all'
                         'all'
                       elsif params[:year].present?
                         params[:year].to_i
                       else
                         'all'
                       end

    filtered_inspections =
      if @selected_year == 'all'
        @inspections
      else
        @inspections.select { |i| i.ins_date.year == @selected_year }
      end

    month_order   = %w[Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre]
    month_mapping = {
      "01" => "Enero", "02" => "Febrero", "03" => "Marzo", "04" => "Abril",
      "05" => "Mayo",  "06" => "Junio",   "07" => "Julio", "08" => "Agosto",
      "09" => "Septiembre", "10" => "Octubre", "11" => "Noviembre", "12" => "Diciembre"
    }

    @inspections_by_month =
      filtered_inspections
        .group_by { |i| month_mapping[i.ins_date.strftime('%m')] }
        .transform_values(&:count)
        .sort_by { |m, _| month_order.index(m) }
        .to_h

    @inspections_by_year =
      @inspections.group_by { |i| i.ins_date.year }
                  .transform_values(&:count)
                  .sort_by { |y, _| y }
                  .to_h

    result_order = %w[Aprobado Rechazado En\ revisión Creado]
    @inspection_results =
      filtered_inspections.group_by(&:result)
                          .transform_values(&:count)
                          .sort_by { |r, _| result_order.index(r) || result_order.size }
                          .to_h

    state_order = %w[Cerrado Abierto]
    @inspection_states =
      filtered_inspections.group_by(&:state)
                          .transform_values(&:count)
                          .sort_by { |s, _| state_order.index(s) || state_order.size }
                          .to_h

    @available_regions = @inspections.map(&:region).uniq.compact.sort
    @selected_region   = params[:region].presence || 'all'

    @selected_years =
      params[:years].present? ? params[:years].reject(&:blank?).map(&:to_i) : []

    comuna_scope =
      if @selected_region != 'all'
        @inspections.where(region: @selected_region)
      else
        @inspections
      end

    comuna_scope =
      if @selected_years.any?
        comuna_scope.select { |i| @selected_years.include?(i.ins_date.year) }
      else
        comuna_scope
      end

    @inspections_by_comuna =
      comuna_scope
        .group_by { |i| "#{i.comuna} – #{i.ins_date.year}" }
        .transform_values(&:count)
        .sort_by { |key, _| key }
        .to_h

    @chart_type = params[:chart_type] || 'bar'

    @colors = %w[
      #ff6347 #4682b4 #32cd32 #ffd700 #6a5acd #ff69b4 #8a2be2 #00ced1 #ff4500 #2e8b57
      #ff7f50 #6495ed #9932cc #3cb371 #b8860b #ff1493 #1e90ff #daa520 #ba55d3 #7b68ee
      #ff4500 #ffa07a #20b2aa #87cefa #b22222 #ffdead #8fbc8f #ff6347 #6b8e23 #a9a9a9
      #ffe4b5 #fa8072 #eee8aa #98fb98 #afeeee #cd5c5c #ff69b4 #2e8b57 #8a2be2 #20b2aa
      #dda0dd #66cdaa #f08080 #e9967a #3cb371 #f5deb3 #ff6347 #40e0d0 #4682b4 #db7093
    ]

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end




  def certificados_excel
    year  = params[:year]&.to_i || Date.current.year
    range = Date.new(year, 1, 1)..Date.new(year, 12, 31)
    months_es = %w[Ene Feb Mar Abr May Jun Jul Ago Sep Oct Nov Dic]

    principals = Principal
                   .joins(:inspections)
                   .where(inspections: { ins_date: range })
                   .where('inspections.number > 0')
                   .distinct
                   .includes(inspections: [:item, :report, :users])

    Tempfile.create(['informes', '.xlsx']) do |tmp|
      path = tmp.path
      tmp.close

      workbook = WriteXLSX.new(path)
      sheet    = workbook.add_worksheet("Informes #{year}")

      header = workbook.add_format(
        bold: 1, align: 'center', valign: 'vcenter', text_wrap: 1,
        border: 1, color: 'white', bg_color: '#4F81BD', pattern: 1
      )
      cell   = workbook.add_format(align: 'left',   valign: 'vcenter', text_wrap: 1, border: 1)
      cell_c = workbook.add_format(align: 'center', valign: 'vcenter', text_wrap: 1, border: 1)

      titles = [
        'Nombre Empresa', 'Representante Legal', 'RUT Empresa Legal', 'Dirección',
        'Personal Certificador', 'RUT', 'Personal Inspector', 'RUT',
        'Numero de Informe', 'ID', 'Fecha Inspección', 'Folio Certificado',
        'Fecha Prox Certificación'
      ]
      sheet.write_row(0, 0, titles, header)
      sheet.set_row(0, 24)
      sheet.set_column(0, 0, 26)
      sheet.set_column(1, 1, 24)
      sheet.set_column(2, 2, 18)
      sheet.set_column(3, 3, 30)
      sheet.set_column(4, 4, 24)
      sheet.set_column(5, 5, 10)
      sheet.set_column(6, 6, 26)
      sheet.set_column(7, 7, 10)
      sheet.set_column(8, 8, 30)
      sheet.set_column(9, 9, 28)
      sheet.set_column(10,10,18)
      sheet.set_column(11,11,18)
      sheet.set_column(12,12,24)

      r = 1

      principals.find_each do |principal|
        inspections = principal.inspections
                               .select { |i| i.ins_date.present? && range.cover?(i.ins_date.to_date) && i.number.to_i > 0 }
                               .sort_by(&:ins_date)
        next if inspections.empty?

        inspectors = inspections.flat_map(&:users).compact.map(&:real_name).uniq.sort
        inspectors_multiline = inspectors.join("\n")

        base = [
          principal.name.to_s,
          principal.contact_name.to_s,
          principal.rut.to_s,
          principal.place.to_s,
          'Ivan Castro Dolcino',
          '',
          inspectors_multiline,
          ''
        ]

        r0 = r

        inspections.each do |insp|
          date  = insp.ins_date.to_date
          mm    = date.strftime('%m')
          yyyy  = date.strftime('%Y')
          ident = insp.item&.identificador.to_s
          tail4 = ident[-4, 4].to_s

          numero = "N° #{insp.number}-#{mm}-#{yyyy}-#{tail4}"
          prox = if insp.report&.ending.present?
                   d = insp.report.ending.to_date
                   "#{months_es[d.month - 1]}-#{d.strftime('%y')}"
                 else
                   ''
                 end

          row = Array.new(8, '') + [
            numero,
            ident,
            date.strftime('%d/%m/%Y'), # dd/mm/yyyy
            '',
            prox
          ]

          0.upto(12) { |cidx| sheet.write(r, cidx, row[cidx], [2,5,7,10,11,12].include?(cidx) ? cell_c : cell) }
          sheet.set_row(r, 20)
          r += 1
        end

        span_last = r - 1
        if r0 == span_last
          sheet.write_row(r0, 0, base, cell)
          [2,5,7].each { |c| sheet.write(r0, c, base[c], cell_c) }
        else
          (0..7).each do |c|
            fmt = [2,5,7].include?(c) ? cell_c : cell
            sheet.merge_range(r0, c, span_last, c, base[c], fmt)
          end
        end
      end

      workbook.close

      send_data File.binread(path),
                filename: "informes_#{year}.xlsx",
                type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                disposition: :attachment

      DeleteTempFileJob.set(wait: 5.minutes).perform_later(path)
    end
  end
end
