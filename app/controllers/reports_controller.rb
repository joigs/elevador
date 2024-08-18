class ReportsController < ApplicationController

  # GET /reports/1/edit
  def edit
    authorize! report
    @item = @report.item
    @inspections = @item.inspections.order(ins_date: :desc)
    puts("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
    puts(@inspections.size)
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

    if @item.group.name.downcase.include?("escala")
      @detail = LadderDetail.find_by(item_id: @item.id)
    else
      @detail = Detail.find_by(item_id: @item.id)
    end
  end




  # PATCH/PUT /reports/1 or /reports/1.json
  def update
    authorize! report
    @item = @report.item
    @detail = Detail.find_by(item_id: @item.id)
    inspection = @report.inspection
    if @report.update(report_params)

      if @report[:cert_ant] == 'Si' && @item.inspections.where('number > 0').count == 1
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
          black_inspection.created_at = DateTime.new(1000, 1, 1)
          puts(black_inspection.inspect)
          black_inspection.save
        end

        if @item.group.type_of == "escala"
          if was_created
            @revision = LadderRevision.create!(inspection_id: black_inspection.id, item_id: @item.id)
            @revision.created_at = DateTime.new(1000, 1, 1)
            @revision.save

            numbers = [0,1,2,3,4,5,6,7,8,11, 12, 13, 14, 15]
            numbers.each do |number|
              @revision.revision_colors.create!(number: number, color: false)
            end
          else
            @revision = LadderRevision.find_by(inspection_id: black_inspection.id)
          end



        else
          if was_created
            @revision = Revision.create!(inspection_id: black_inspection.id, item_id: @item.id, group_id: @item.group_id)
            @revision.created_at = DateTime.new(1000, 1, 1)
            @revision.save

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


          else
            @revision = Revision.find_by(inspection_id: black_inspection.id)
          end
        end
      end


      if report_params[:cert_ant] == 'No'
        @black_inspection = Inspection.find_by(number: inspection.number*-1)
        if @black_inspection
          @black_inspection.destroy
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
      params.require(:report).permit(:certificado_minvu, :cert_ant, :fecha, :empresa_anterior, :ea_rol, :ea_rut, :empresa_mantenedora, :em_rol, :em_rut, :vi_co_man_ini, :vi_co_man_ter, :nom_tec_man, :tm_rut, :ul_reg_man, :urm_fecha, :inspection_id, :item_id)
    end
end
