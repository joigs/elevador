class PrincipalsController < ApplicationController
  require 'write_xlsx' # Asegúrate de requerir la gema al inicio de tu archivo

  # GET /principals or /principals.json
  def index
    @q = Principal.ransack(params[:q])
    @principals = @q.result(distinct: true).order(created_at: :desc)

    unless Current.user.tabla

      @pagy, @principals = pagy_countless(@principals, items: 10)
    end

  end



  # GET /principals/1 or /principals/1.json
  def show
    principal

    if Current.user.empresa != nil
      if @principal.id != Current.user.principal_id
        flash[:alert] = "No tienes permiso"
        redirect_to principal_path(Current.user.principal_id)
      end
    end

    @q = principal.items.ransack(params[:q])
    @items = @q.result(distinct: true).order(created_at: :desc)

    unless Current.user.tabla
      @pagy, @items = pagy_countless(@items, items: 10)
    end

    @inspections = @principal.inspections.where("number > ?", 0).order(number: :desc)
    if params[:tab] == 'inspections'
      @q_inspections = @principal.inspections.ransack(params[:q])
      @inspections = @q_inspections.result(distinct: true).where("number > ?", 0).order(number: :desc)
      unless Current.user.tabla
        @pagy_inspections, @inspections = pagy_countless(@inspections, items: 10)
      end
    end

    @available_years = @inspections.map { |i| i.ins_date.year }.uniq.sort
    @selected_year = if params[:year] == 'all'
                       'all'
                     elsif params[:year].present?
                       params[:year].to_i
                     else
                       'all'
                     end

    filtered_inspections = if @selected_year == 'all'
                             @inspections
                           else
                             @inspections.select { |i| i.ins_date.year == @selected_year }
                           end

    month_order = ["Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"]
    month_mapping = {
      "01"=>"Enero","02"=>"Febrero","03"=>"Marzo","04"=>"Abril","05"=>"Mayo","06"=>"Junio",
      "07"=>"Julio","08"=>"Agosto","09"=>"Septiembre","10"=>"Octubre","11"=>"Noviembre","12"=>"Diciembre"
    }

    @inspections_by_month = filtered_inspections.group_by { |i| month_mapping[i.ins_date.strftime("%m")] }.transform_values(&:count)
    @inspections_by_month = @inspections_by_month.sort_by { |m, _| month_order.index(m) }.to_h

    @inspections_by_year = @inspections.group_by { |i| i.ins_date.year }.transform_values(&:count)
    @inspections_by_year = @inspections_by_year.sort_by { |y, _| y }.to_h

    result_order = ["Aprobado","Rechazado","En revisión","Creado"]
    @inspection_results = filtered_inspections.group_by(&:result).transform_values(&:count)
    @inspection_results = @inspection_results.sort_by { |r, _| result_order.index(r) || result_order.size }.to_h

    state_order = ["Cerrado","Abierto"]
    @inspection_states = filtered_inspections.group_by(&:state).transform_values(&:count)
    @inspection_states = @inspection_states.sort_by { |s, _| state_order.index(s) || state_order.size }.to_h

    @chart_type = params[:chart_type] || 'bar'

    @colors = [
      '#ff6347','#4682b4','#32cd32','#ffd700','#6a5acd','#ff69b4','#8a2be2','#00ced1','#ff4500','#2e8b57',
      '#ff7f50','#6495ed','#9932cc','#3cb371','#b8860b','#ff1493','#1e90ff','#daa520','#ba55d3','#7b68ee',
      '#ff4500','#ffa07a','#20b2aa','#87cefa','#b22222','#ffdead','#8fbc8f','#ff6347','#6b8e23','#a9a9a9',
      '#ffe4b5','#fa8072','#eee8aa','#98fb98','#afeeee','#cd5c5c','#ff69b4','#2e8b57','#8a2be2','#20b2aa',
      '#dda0dd','#66cdaa','#f08080','#e9967a','#3cb371','#f5deb3','#ff6347','#40e0d0','#4682b4','#db7093'
    ]

    respond_to do |format|
      format.html
    end
  end





  # GET /principals/new
  def new
    authorize! @principal = Principal.new
  end

  # GET /principals/1/edit
  def edit
    authorize! principal

    if Current.user.empresa != nil
      if @principal.id != Current.user.principal_id
        flash[:alert] = "No tienes permiso"
        redirect_to principal_path(Current.user.principal_id)
      end
    end
  end

  # POST /principals or /principals.json
  def create
    authorize! @principal = Principal.new(principal_params)

    if @principal.save
      flash[:notice] = "Empresa añadida exitosamente"
      redirect_to principals_path
    else
      render :new, status: :unprocessable_entity
    end

  end

  # PATCH/PUT /principals/1 or /principals/1.json
  def update
    authorize! principal

    if Current.user.empresa != nil
      if @principal.id != Current.user.principal_id
        flash[:alert] = "No tienes permiso"
        return redirect_to principal_path(Current.user.principal_id), status: :see_other
      end
    end

    if @principal.update(principal_params)
      flash[:notice] = "Empresa modificada"
      redirect_to principal_path(@principal), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /principals/1 or /principals/1.json
  def destroy
    authorize! principal
    @principal.destroy
    flash[:notice] = "Empresa eliminada"
    respond_to do |format|
      format.html { redirect_to principals_path }
      format.turbo_stream { head :no_content }
    end
  end


  def toggle_activo
    authorize! principal

    if @principal.update(activo: !@principal.activo)
      flash[:notice] = @principal.activo? ? "Empresa activada" : "Empresa desactivada"
    else
      flash[:alert] = "No se pudo cambiar el estado de la empresa"
    end

    redirect_to principal_path(@principal), status: :see_other
  end

  def items
    principal = Principal.find(params[:id])
    items = principal.items.select(:id, :identificador).order(:identificador)
    render json: items
  end

  def places
    principal = Principal.find(params[:id])
    places = principal.inspections.select(:place).distinct.map(&:place)
    render json: places
  end


  def no_conformidad
    @principal = Principal.find(params[:principal_id])
    authorize! @principal

    if Current.user.empresa != nil
      if @principal.id != Current.user.principal_id
        flash[:alert] = "No tienes permiso"
        redirect_to principal_path(Current.user.principal_id)
      end
    end
    @groups = Group.all
    @totalitems = @principal.items.select { |item| item.inspections.any? }

    items_by_group = @totalitems.group_by(&:group_id)

    rules_per_group = {}
    revisions_base_per_group = {}
    group_types = {}
    group_names = {}

    @groups.each do |group|
      items = items_by_group[group.id] || []
      revisions = []

      items.each do |item|
        inspection = item.inspections.order(number: :desc).first
        next unless inspection

        revision = case group.type_of
                   when "escala" then LadderRevision.find_by(inspection_id: inspection.id)
                   when "plat"   then PlatRevision.find_by(inspection_id: inspection.id)
                   else               Revision.find_by(inspection_id: inspection.id)
                   end
        next unless revision

        revisions << revision
      end

      rules_per_group[group.number] = case group.type_of
                                      when "escala" then Ladder.all.to_a
                                      when "plat"   then RulesPlat.where(group_id: group.id).to_a
                                      else               group.rules.to_a
                                      end

      revisions_base_per_group[group.number] = revisions
      group_types[group.number] = group.type_of
      group_names[group.number] = group.name
    end

    require 'write_xlsx'
    temp_file = Tempfile.new(["no_conformidad_#{@principal.name}", '.xlsx'])
    workbook = WriteXLSX.new(temp_file.path)

    rules_per_group.each do |group_number, rules|

      unless revisions_base_per_group[group_number].any?
        next
      end

      sheet_name = group_names[group_number]
      worksheet = workbook.add_worksheet(sheet_name)

      max_length = 0

      rules.each_with_index do |rule, row|
        counter = 0

        content = "#{rule.code} - #{rule.point}"

        revisions_base_per_group[group_number].each do |revision_base|
          if group_types[group_number] == "plat"
            if revision_base.plat_revision_rules_plats.any? { |prrp| prrp.rules_plat_id == rule.id }
              counter += 1
            end
          else
            revision_base.revision_colors.each do |color|
              color.codes.each_with_index do |code, index|
                if code == rule.code && color.points[index] == rule.point
                  counter += 1
                end
              end
            end
          end
        end

        percentage = counter.to_f / revisions_base_per_group[group_number].size * 100
        worksheet.write(row, 1, "#{percentage}%")


        worksheet.write(row, 2, content)
        max_length = [max_length, content.length].max
      end

      column_width = [max_length + 2, 30].min
      worksheet.set_column(2, 2, column_width)
    end

    workbook.close

    send_file temp_file.path,
              filename: "no_conformidad_#{@principal.name}.xlsx",
              type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              disposition: 'attachment'

    DeleteTempFileJob.set(wait: 5.minutes).perform_later(temp_file.path.to_s)

  end




  def estado_activos
    @principal = Principal.find(params[:principal_id])
    authorize! @principal
    if Current.user.empresa != nil
      if @principal.id != Current.user.principal_id
        flash[:alert] = "No tienes permiso"
        redirect_to principal_path(Current.user.principal_id)
      end
    end
    @items = @principal.items



    require 'write_xlsx'
    temp_file = Tempfile.new(["Estado_activos_#{@principal.name}", '.xlsx'])
    workbook = WriteXLSX.new(temp_file.path)



    header_format = workbook.add_format(
      bold: true,
      border: 1,
      bg_color: '#D7E4BC',
      align: 'center',
      valign: 'vcenter',
      text_wrap: true
    )

    cell_format = workbook.add_format(
      border: 1,
      text_wrap: true,
      align: 'left',
      valign: 'top'
    )

    worksheet_activos = workbook.add_worksheet("Activos")

    headers_activos = [
      "Identificador",
      "Grupo",
      "Inspección más reciente",
      "Número inspección",
      "¿Es reinspección?",
      "Fecha de inspección",
      "Dirección",
      "Fecha de informe",
      "Resultado",
      "Próxima inspección"
    ]

    encabezados_fila = 2
    encabezados_columna = 3

    headers_activos.each_with_index do |header, idx|
      worksheet_activos.write(encabezados_fila, encabezados_columna + idx, header, header_format)
    end

    datos_fila_inicial = encabezados_fila + 1
    @items.each_with_index do |item, index|
      row = datos_fila_inicial + index
      inspection = item.inspections.order(number: :desc).first

      worksheet_activos.write(row, 2, index + 1, cell_format)
      worksheet_activos.write(row, 3, item.identificador, cell_format)
      worksheet_activos.write(row, 4, item.group.name, cell_format)

      if inspection

        if inspection.name == ""
          inspection.name = "Sin nombre"
        end
        worksheet_activos.write(row, 5, inspection.name, cell_format)
        worksheet_activos.write(row, 6, inspection.number, cell_format)
        worksheet_activos.write(row, 7, inspection.rerun ? "Sí" : "No", cell_format)
        worksheet_activos.write(row, 8, inspection.ins_date&.strftime('%d/%m/%Y'), cell_format)
        worksheet_activos.write(row, 9, inspection.place, cell_format)
        worksheet_activos.write(row, 10, inspection.inf_date&.strftime('%d/%m/%Y'), cell_format)
        worksheet_activos.write(row, 11, inspection.result, cell_format)
        worksheet_activos.write(row, 12, inspection.report.ending&.strftime('%d/%m/%Y'), cell_format)
      else
        (5..12).each do |col|
          worksheet_activos.write(row, col, '', cell_format)
        end
      end
    end

    num_rows_activos = @items.size
    num_cols_activos = headers_activos.size
    last_row_activos = datos_fila_inicial + num_rows_activos - 1
    last_col_activos = encabezados_columna + num_cols_activos - 1
    last_col_letter_activos = col_num_to_letter(last_col_activos)
    table_range_activos = "D3:#{last_col_letter_activos}#{last_row_activos + 1}"

    worksheet_activos.add_table(table_range_activos, {
      name: 'TablaActivos',
      columns: headers_activos.map { |h| { header: h } },
      style: 'Table Style Medium 9',
      autofilter: true
    })

    (3..12).each do |col|
      worksheet_activos.set_column(col, col, 20)
    end

    worksheet_defectos = workbook.add_worksheet("Defectos")

    max_defectos = @items.map do |item|
      inspection = item.inspections.order(number: :desc).first
      next 0 unless inspection

      revision = case item.group.type_of
                 when "escala" then LadderRevision.find_by(inspection_id: inspection.id)
                 when "plat"   then PlatRevision.find_by(inspection_id: inspection.id)
                 else               Revision.find_by(inspection_id: inspection.id)
                 end

      next 0 unless revision

      if item.group.type_of == "plat"
        revision.plat_revision_rules_plats.size
      else
        revision.revision_colors.map { |color| color.points.size }.max || 0
      end
    end.max

    max_defectos ||= 0

    max_defectos = [max_defectos, 20].min

    headers_defectos = [
      "Identificador",
      "Grupo"
    ]

    (0..max_defectos).each do |i|
      headers_defectos << "Defecto #{i+1}"
    end

    encabezados_defectos_fila = 2
    encabezados_defectos_columna = 3

    headers_defectos.each_with_index do |header, idx|
      worksheet_defectos.write(encabezados_defectos_fila, encabezados_defectos_columna + idx, header, header_format)
    end

    datos_defectos_fila_inicial = encabezados_defectos_fila + 1
    @items.each_with_index do |item, index|
      row = datos_defectos_fila_inicial + index
      inspection = item.inspections.order(number: :desc).first

      worksheet_defectos.write(row, 3, item.identificador, cell_format)
      worksheet_defectos.write(row, 4, item.group.name, cell_format)

      if inspection
        revision = case item.group.type_of
                   when "escala" then LadderRevision.find_by(inspection_id: inspection.id)
                   when "plat"   then PlatRevision.find_by(inspection_id: inspection.id)
                   else               Revision.find_by(inspection_id: inspection.id)
                   end

        if revision
          points = []
          if item.group.type_of == "plat"
            revision.plat_revision_rules_plats.includes(:rules_plat).each do |prrp|
              comment = prrp.comment.to_s.strip.empty? ? "(Sin comentarios)" : "(#{prrp.comment})"
              points << "#{prrp.rules_plat.point} #{comment}"
            end
          else
            revision.revision_colors.each do |color|
              color.points.each_with_index do |point, idx_point|
                comment = color.comment[idx_point].to_s.strip.empty? ? "(Sin comentarios)" : "(#{color.comment[idx_point]})"
                points << "#{point} #{comment}"
              end
            end
          end

          defectos_encontrados = points.join(", ")
          worksheet_defectos.write(row, 5, defectos_encontrados, cell_format)

          points.each_with_index do |point, idx_defecto|
            break if idx_defecto >= max_defectos
            col = 6 + idx_defecto
            worksheet_defectos.write(row, col, point, cell_format)
          end
        else
          worksheet_defectos.write(row, 5, '', cell_format)
          (6..(5 + max_defectos)).each do |col|
            worksheet_defectos.write(row, col, '', cell_format)
          end
        end
      else
        worksheet_defectos.write(row, 5, '', cell_format)
        (6..(5 + max_defectos)).each do |col|
          worksheet_defectos.write(row, col, '', cell_format)
        end
      end
    end

    num_rows_defectos = @items.size
    num_cols_defectos = headers_defectos.size
    last_row_defectos = datos_defectos_fila_inicial + num_rows_defectos - 1
    last_col_defectos = encabezados_defectos_columna + num_cols_defectos - 1
    last_col_letter_defectos = col_num_to_letter(last_col_defectos)
    table_range_defectos = "D3:#{last_col_letter_defectos}#{last_row_defectos + 1}"

    worksheet_defectos.add_table(table_range_defectos, {
      name: 'TablaDefectos',
      columns: headers_defectos.map { |h| { header: h } },
      style: 'Table Style Medium 9'
    })

    (3..(3 + headers_defectos.size - 1)).each do |col|
      worksheet_defectos.set_column(col, col, 20)
    end



    workbook.close
    send_file temp_file.path,
              filename: "Estado_activos_#{@principal.name}.xlsx",
              type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              disposition: 'attachment'

    DeleteTempFileJob.set(wait: 5.minutes).perform_later(temp_file.path.to_s)

  end
  def col_num_to_letter(col_num)
    letter = ''
    while col_num >= 0
      letter = (65 + (col_num % 26)).chr + letter
      col_num = (col_num / 26) - 1
    end
    letter
  end

  def defectos_activos
    @principal = Principal.find(params[:principal_id])
    authorize! @principal

    if Current.user.empresa != nil
      if @principal.id != Current.user.principal_id
        flash[:alert] = "No tienes permiso"
        redirect_to principal_path(Current.user.principal_id)
      end
    end

    @groups = Group.all
    @totalitems = @principal.items.select { |item| item.inspections.any? }

    items_by_group = @totalitems.group_by(&:group_id)

    rules_per_group = {}
    revisions_base_per_group = {}
    items_per_group = {}
    inspections_per_group = {}
    group_types = {}
    group_names = {}

    @groups.each do |group|
      items = items_by_group[group.id] || []

      revisions = []
      identificadores = []
      states = []

      items.each do |item|
        inspection = item.inspections.order(number: :desc).first
        next unless inspection

        revision = case group.type_of
                   when "escala" then LadderRevision.find_by(inspection_id: inspection.id)
                   when "plat"   then PlatRevision.find_by(inspection_id: inspection.id)
                   else               Revision.find_by(inspection_id: inspection.id)
                   end
        next unless revision

        revisions << revision
        identificadores << item.identificador
        states << inspection.result
      end

      rules_per_group[group.number] = case group.type_of
                                      when "escala" then Ladder.all.to_a
                                      when "plat"   then RulesPlat.where(group_id: group.id).to_a
                                      else               group.rules.to_a
                                      end

      revisions_base_per_group[group.number] = revisions
      items_per_group[group.number] = identificadores
      inspections_per_group[group.number] = states
      group_types[group.number] = group.type_of
      group_names[group.number] = group.name
    end

    require 'write_xlsx'
    temp_file = Tempfile.new(["defectos_de_activos_#{@principal.name}", '.xlsx'])
    workbook = WriteXLSX.new(temp_file.path)



    rules_per_group.each do |group_number, rules|

      unless revisions_base_per_group[group_number].any?
        next
      end

      sheet_name = group_names[group_number]
      worksheet = workbook.add_worksheet(sheet_name)

      max_length = 0

      inspections_per_group[group_number].each_with_index do |inspection, index|
        worksheet.write(1, 8 + index, items_per_group[group_number][index])
        worksheet.write(2, 8 + index, inspection)
      end

      rules.each_with_index do |rule, row|
        content = "#{rule.code} - #{rule.point}"

        revisions_base_per_group[group_number].each_with_index do |revision_base, index|
          if group_types[group_number] == "plat"
            prrp = revision_base.plat_revision_rules_plats.find { |x| x.rules_plat_id == rule.id }
            if prrp
              stuff = prrp.comment.to_s.strip.empty? ? "Sin comentarios" : prrp.comment
              worksheet.write(row + 3, 8 + index, stuff)
            end
          else
            revision_base.revision_colors.each do |color|
              color.codes.each_with_index do |code, index2|
                if code == rule.code && color.points[index2] == rule.point
                  stuff = color.comment[index2].to_s.strip.empty? ? "Sin comentarios" : color.comment[index2]
                  worksheet.write(row + 3, 8 + index, stuff)
                end
              end
            end
          end
        end


        worksheet.write(row+3, 2, content)
        worksheet.write(row+3, 7, "-")
        max_length = [max_length, content.length].max
      end

      column_width = [max_length + 2, 30].min
      worksheet.set_column(2, 2, column_width)
    end

    workbook.close

    send_file temp_file.path,
              filename: "defectos_de_activos_#{@principal.name}.xlsx",
              type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              disposition: 'attachment'

    DeleteTempFileJob.set(wait: 5.minutes).perform_later(temp_file.path.to_s)


  end





  private
    # Use callbacks to share common setup or constraints between actions.
    def principal
      @principal = Principal.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
  def principal_params
    params.require(:principal).permit(:rut, :name, :business_name, :contact_name, :email, :phone, :cellphone, :contact_email, :place, :activo)
  end




end
