class ReportsController < ApplicationController

  # GET /reports/1/edit
  def edit
    authorize! report
    @item = @report.item
    @inspections = @item.inspections.order(ins_date: :desc)
    if @inspections.size == 1 || (@inspections.size == 2 && @inspections.last.number < 0)
      @show_third_radio_button = false
    elsif @inspections.size == 2 && @inspections.last.number > 0
      @show_third_radio_button = true
      @previous_inspection = @inspections.last
    elsif @inspections.size >= 3 && @inspections.second.number < 0
      @show_third_radio_button = true
      @previous_inspection = @inspections.third
    else
      @show_third_radio_button = true
      @previous_inspection = @inspections.second
    end

    if @item.group.type_of == "escala"
      @detail = LadderDetail.find_by(item_id: @item.id)
    else
      @detail = Detail.find_by(item_id: @item.id)
    end
  end




  # PATCH/PUT /reports/1 or /reports/1.json
  def update
    authorize! report
    @item = @report.item

    if params[:report][:cert_ant] == "sistema"
      params[:report][:fecha] = params[:report][:fecha_sistema]
      params[:report][:empresa_anterior] = params[:report][:empresa_anterior_sistema]
      params[:report][:ea_rol] = params[:report][:ea_rol_sistema]
      params[:report][:ea_rut] = params[:report][:ea_rut_sistema]
    end
    params[:report].delete(:fecha_sistema)
    params[:report].delete(:empresa_anterior_sistema)
    params[:report].delete(:ea_rol_sistema)
    params[:report].delete(:ea_rut_sistema)


    @detail = Detail.find_by(item_id: @item.id)
    inspection = @report.inspection

    @inspections = @item.inspections.order(ins_date: :desc)
    if @inspections.size == 1 || (@inspections.size == 2 && @inspections.last.number < 0)
      @show_third_radio_button = false
    elsif @inspections.size == 2 && @inspections.last.number > 0
      @show_third_radio_button = true
      @previous_inspection = @inspections.last
    elsif @inspections.size >= 3 && @inspections.second.number < 0
      @show_third_radio_button = true
      @previous_inspection = @inspections.third
    else
      @show_third_radio_button = true
      @previous_inspection = @inspections.second
    end


    if @report.update(report_params)

      if @report[:cert_ant] == 'Si'
        black_number = inspection.number*-1
         black_inspection = Inspection.find_by(number: black_number, item_id: @item.id, principal_id: @item.principal_id, place: inspection.place, ins_date: inspection.ins_date, state: 'black', result: 'black')

        if black_inspection
          was_created = false
        else
          was_created = true
        end

        if was_created
          black_inspection= Inspection.create!(number: black_number, item_id: @item.id, principal_id: @item.principal_id, place: inspection.place, ins_date: inspection.ins_date, state: 'black', result: 'black')
          inspection.users.each do |user|
            black_inspection.users << user
          end
          black_inspection.created_at = Time.current - 1.minute
          black_inspection.save
          inspection.created_at = Time.current
          inspection.save
        end

        if @item.group.type_of == "escala"
          if was_created
            current_revision = LadderRevision.find_by(inspection_id: inspection.id)

            @revision = LadderRevision.create!(inspection_id: black_inspection.id, item_id: @item.id)
            @revision.created_at = Time.current - 1.minute
            @revision.save

            current_revision.created_at = Time.current
            current_revision.save

            numbers = [0,1,2,3,4,5,6,7,8,11, 12, 13, 14, 15]
            numbers.each do |number|
              @revision.revision_colors.create!(number: number, color: false)
            end
          else
            @revision = LadderRevision.find_by(inspection_id: black_inspection.id)
          end



        else
          if was_created
            current_revision = Revision.find_by(inspection_id: inspection.id)

            @revision = Revision.create!(inspection_id: black_inspection.id, item_id: @item.id, group_id: @item.group_id)
            @revision.created_at = Time.current - 1.minute
            @revision.save

            current_revision.created_at = Time.current
            current_revision.save


            if @item.group.type_of == "ascensor"
              (0..11).each do |index|
                @revision.revision_colors.create!(number: index, color: false)
              end

            elsif @item.group.type_of == "libre"
              numbers = [0,100]
              numbers.each do |number|
                @revision.revision_colors.create!(number: number, color: false)
              end

            end


          end
        end
      end


      if report_params[:cert_ant] == 'No' || report_params[:cert_ant] == 'sistema'
        @black_inspection = Inspection.find_by(number: inspection.number*-1)
        if @black_inspection
          @black_revision = Revision.find_by(inspection_id: @black_inspection.id)
          @black_inspection.destroy
          @black_revision.destroy
        end
      end

      if @item.group.type_of == "escala"
        redirect_to edit_ladder_revision_path(inspection_id: inspection.id), notice: 'Información modificada exitosamente'

      elsif @item.group.type_of == "libre"
        redirect_to edit_libre_revision_path(inspection_id: inspection.id), notice: 'Información modificada exitosamente'
      elsif @item.group.type_of == "ascensor"
        redirect_to edit_revision_path(inspection_id: inspection.id), notice: 'Información modificada exitosamente'
      end

    else
      render :edit, status: :unprocessable_entity
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def report
      @report = Report.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def report_params
      params.require(:report).permit(:certificado_minvu, :cert_ant, :fecha, :empresa_anterior, :ea_rol, :ea_rut, :empresa_mantenedora, :em_rol, :em_rut, :vi_co_man_ini, :vi_co_man_ter, :nom_tec_man, :tm_rut, :ul_reg_man, :urm_fecha, :inspection_id, :item_id, :fecha_sistema, :empresa_anterior_sistema, :ea_rol_sistema, :ea_rut_sistema)
    end
end
