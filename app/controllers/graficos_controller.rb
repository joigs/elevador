class GraficosController < ApplicationController
  def index
    @inspections = Inspection.where("number > 0").order(number: :desc)

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
end
