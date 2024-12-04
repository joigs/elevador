class PrincipalsController < ApplicationController
  require 'write_xlsx' # Asegúrate de requerir la gema al inicio de tu archivo

  # GET /principals or /principals.json
  def index
    @q = Principal.ransack(params[:q])
    @principals = @q.result(distinct: true).order(created_at: :desc)

    if Current.user.tabla
      @pagy, @principals = pagy(@principals, items: 10) # Paginación tradicional para la tabla
    else
      @pagy, @principals = pagy_countless(@principals, items: 10)
    end

  end



  # GET /principals/1 or /principals/1.json
  def show
    principal
    @q = principal.items.ransack(params[:q])
    @items = @q.result(distinct: true).order(created_at: :desc)

    if Current.user.tabla
      @pagy, @items = pagy(@items, items: 10)  # Paginación tradicional para la tabla
    else
      @pagy, @items = pagy_countless(@items, items: 10)  # Paginación infinita para las tarjetas
    end

    @inspections = @principal.inspections.where("number > ?", 0).order(number: :desc)

    @available_years = @inspections.map { |inspection| inspection.ins_date.year }.uniq.sort
    @selected_year = params[:year].present? ? params[:year].to_i : @available_years.last

    month_order = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
                   "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    month_mapping = {
      "01" => "Enero", "02" => "Febrero", "03" => "Marzo", "04" => "Abril", "05" => "Mayo", "06" => "Junio",
      "07" => "Julio", "08" => "Agosto", "09" => "Septiembre", "10" => "Octubre", "11" => "Noviembre", "12" => "Diciembre"
    }

    inspections_for_year = @inspections.select { |inspection| inspection.ins_date.year == @selected_year }

    @inspections_by_month = inspections_for_year.group_by { |inspection| month_mapping[inspection.ins_date.strftime("%m")] }
                                                .transform_values(&:count)
    @inspections_by_month = @inspections_by_month.sort_by { |month, _| month_order.index(month) }.to_h

    # Agrupar inspecciones por año y ordenar
    @inspections_by_year = @inspections.group_by { |inspection| inspection.ins_date.year }
                                       .transform_values(&:count)
    @inspections_by_year = @inspections_by_year.sort_by { |year, _| year }.to_h

    result_order = ["Aprobado", "Rechazado", "En revisión", "Creado"]
    @inspection_results = @inspections.group_by(&:result).transform_values(&:count)
    @inspection_results = @inspection_results.sort_by { |result, _| result_order.index(result) || result_order.size }.to_h

    state_order = ["Cerrado", "Abierto"]
    @inspection_states = @inspections.group_by(&:state).transform_values(&:count)
    @inspection_states = @inspection_states.sort_by { |state, _| state_order.index(state) || state_order.size }.to_h

    @chart_type = params[:chart_type] || 'bar'
    @colors = [
      '#ff6347', '#4682b4', '#32cd32', '#ffd700', '#6a5acd', '#ff69b4', '#8a2be2', '#00ced1', '#ff4500', '#2e8b57',
      '#ff7f50', '#6495ed', '#9932cc', '#3cb371', '#b8860b', '#ff1493', '#1e90ff', '#daa520', '#ba55d3', '#7b68ee',
      '#ff4500', '#ffa07a', '#20b2aa', '#87cefa', '#b22222', '#ffdead', '#8fbc8f', '#ff6347', '#6b8e23', '#a9a9a9',
      '#ffe4b5', '#fa8072', '#eee8aa', '#98fb98', '#afeeee', '#cd5c5c', '#ff69b4', '#2e8b57', '#8a2be2', '#20b2aa',
      '#dda0dd', '#66cdaa', '#f08080', '#e9967a', '#3cb371', '#f5deb3', '#ff6347', '#40e0d0', '#4682b4', '#db7093',
    ]

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end



  # GET /principals/new
  def new
    authorize! @principal = Principal.new
  end

  # GET /principals/1/edit
  def edit
    authorize! principal
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
    if principal.update(principal_params)
      flash[:notice] = "Empresa modificada"
      redirect_to principals_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /principals/1 or /principals/1.json
  def destroy
    authorize! principal.destroy
    flash[:notice] = "Empresa eliminada"
    respond_to do |format|
      format.html { redirect_to principals_path }
      format.turbo_stream { head :no_content }
    end
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
    @groups = Group.all
    @totalitems = @principal.items


    @items1, @items2, @items3, @items4 = [], [], [], []

    @totalitems.each do |item|

      if item.inspections.any?


        case item.group.number
        when 1
          @items1 << item
        when 2
          @items2 << item
        when 3
          @items3 << item
        when 4
          @items4 << item
        end
      end

    end

    rules_per_group = {}
    revisions_base_per_group = []

    @groups.each do |group|
      @items = instance_variable_get("@items#{group.number}")
      @items.each do |item|
        @inspections << item.inspections.order(number: :desc).first
      end

      @inspections.each do |inspection|
        if group.type_of == "escala"
          @revisions_base << LadderRevision.find_by(inspection_id: inspection.id)
        else
          @revisions_base << Revision.find_by(inspection_id: inspection.id)
        end
      end

      @rules = group.number == 4 ? Ladder.all : group.rules
      rules_per_group[group.number] = @rules
      revisions_base_per_group[group.number] = @revisions_base

      @inspections = []
      @revisions_base = []
    end

    require 'write_xlsx'
    temp_file = Tempfile.new(["no_conformidad_#{@principal.name}", '.xlsx'])
    workbook = WriteXLSX.new(temp_file.path)

    rules_per_group.each do |group_number, rules|

      unless revisions_base_per_group[group_number].any?
        next
      end

      sheet_name = group_number == 4 ? 'Escala' : "Grupo #{group_number}"
      worksheet = workbook.add_worksheet(sheet_name)

      max_length = 0

      rules.each_with_index do |rule, row|
        counter = 0

        content = "#{rule.code} - #{rule.point}"

        revisions_base_per_group[group_number].each do |revision_base|
          revision_base.revision_colors.each do |color|
            color.codes.each_with_index do |code, index|
              if code == rule.code && color.points[index] == rule.point
                counter += 1
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
              disposition: 'attachment' and return

  end




  def estado_activos
    @principal = Principal.find(params[:principal_id])
    authorize! @principal

    @items = @principal.items



    require 'write_xlsx'
    temp_file = Tempfile.new(["Estado_activos_#{@principal.name}", '.xlsx'])
    workbook = WriteXLSX.new(temp_file.path)


    worksheet = workbook.add_worksheet("Activos")

    worksheet.write(2, 3, "Identificador")
    worksheet.write(2, 4, "Grupo")
    worksheet.write(2, 5, "Inspección más reciente")
    worksheet.write(2, 6, "Número inspección")
    worksheet.write(2, 7, "¿Es reinspección?")
    worksheet.write(2, 8, "Fecha de inspección")
    worksheet.write(2, 9, "Dirección")
    worksheet.write(2, 10, "Fecha de informe")
    worksheet.write(2, 11, "Resultado")
    worksheet.write(2, 12, "Próxima inspección")


    @items.each_with_index do |item, index|
      inspection = item.inspections.order(number: :desc).first
      worksheet.write(3 + index, 2, index + 1)
      worksheet.write(3 + index, 3, item.identificador)
      worksheet.write(3 + index, 4, item.group.name)
      if inspection
        worksheet.write(3 + index, 5, inspection.name)
        worksheet.write(3 + index, 6, inspection.number)
        if inspection.rerun == true
          worksheet.write(3 + index, 7, "Sí")
        else
          worksheet.write(3 + index, 7, "No")
        end
        worksheet.write(3 + index, 8, inspection.ins_date&.strftime('%d/%m/%Y'))
        worksheet.write(3 + index, 9, inspection.place)
        worksheet.write(3 + index, 10, inspection.inf_date&.strftime('%d/%m/%Y'))
        worksheet.write(3 + index, 11, inspection.result)
        worksheet.write(3 + index, 12, inspection.report.ending&.strftime('%d/%m/%Y'))
      end
    end

    workbook.close

    send_file temp_file.path,
              filename: "Estado_activos_#{@principal.name}.xlsx",
              type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              disposition: 'attachment' and return


  end


  def defectos_activos
    @principal = Principal.find(params[:principal_id])
    authorize! @principal
    @groups = Group.all
    @totalitems = @principal.items.select { |item| item.inspections.any? }
    @items1, @items2, @items3, @items4 = [], [], [], []
    @inspections, @revisions_base, @states, @identificadores = [], [], [], []

    @items1, @items2, @items3, @items4 = [], [], [], []

    @totalitems.each do |item|
      case item.group.number
      when 1
        @items1 << item
      when 2
        @items2 << item
      when 3
        @items3 << item
      when 4
        @items4 << item
      end
    end

    rules_per_group = {}
    revisions_base_per_group = []
    items_per_group = []
    inspections_per_group = []

    @groups.each do |group|
      @items = instance_variable_get("@items#{group.number}")
      @items.each do |item|
        @inspections << item.inspections.order(number: :desc).first
        @identificadores << item.identificador
      end

      @inspections.each do |inspection|
        if group.type_of == "escala"
          @revisions_base << LadderRevision.find_by(inspection_id: inspection.id)
        else
          @revisions_base << Revision.find_by(inspection_id: inspection.id)
        end
        @states << inspection.result
      end

      @rules = group.number == 4 ? Ladder.all : group.rules
      rules_per_group[group.number] = @rules
      revisions_base_per_group[group.number] = @revisions_base
      items_per_group[group.number] = @identificadores
      inspections_per_group[group.number] = @states

      @inspections = []
      @revisions_base = []
      @states = []
      @identificadores = []
    end

    require 'write_xlsx'
    temp_file = Tempfile.new(["defectos_de_activos_#{@principal.name}", '.xlsx'])
    workbook = WriteXLSX.new(temp_file.path)



    rules_per_group.each do |group_number, rules|

      unless revisions_base_per_group[group_number].any?
        next
      end

      sheet_name = group_number == 4 ? 'Escala' : "Grupo #{group_number}"
      worksheet = workbook.add_worksheet(sheet_name)

      max_length = 0

      inspections_per_group[group_number].each_with_index do |inspection, index|
        worksheet.write(1, 8 + index, items_per_group[group_number][index])
        worksheet.write(2, 8 + index, inspection)
      end

      rules.each_with_index do |rule, row|
        content = "#{rule.code} - #{rule.point}"


        revisions_base_per_group[group_number].each_with_index do |revision_base, index|
          revision_base.revision_colors.each do |color|
            color.codes.each_with_index do |code, index|
              if code == rule.code && color.points[index] == rule.point
                if color.comment[index] == ""
                  stuff = "Sin comentarios"
                else
                  stuff = color.comment[index]
                end
                puts color.inspect
                worksheet.write(row+3, 8 + index, stuff)

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
              disposition: 'attachment' and return

  end





  private
    # Use callbacks to share common setup or constraints between actions.
    def principal
      @principal = Principal.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def principal_params
      params.require(:principal).permit(:rut, :name, :business_name, :contact_name, :email, :phone, :cellphone, :contact_email, :place)
    end




end
