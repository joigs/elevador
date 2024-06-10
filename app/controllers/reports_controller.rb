class ReportsController < ApplicationController

  # GET /reports/1/edit
  def edit
    authorize! report
    @item = @report.item
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
         black_inspection = Inspection.find_by(number: black_number, item_id: @item.id, principal_id: @item.principal_id, place: inspection.place, ins_date: inspection.ins_date, state: 'black', result: 'black', user_id: inspection.user_id)

        if black_inspection
          was_created = false
        else
          was_created = true
        end

        if was_created
          black_inspection= Inspection.create!(number: black_number, item_id: @item.id, principal_id: @item.principal_id, place: inspection.place, ins_date: inspection.ins_date, state: 'black', result: 'black', user_id: inspection.user_id)
          black_inspection.created_at = DateTime.new(1000, 1, 1)
          puts(black_inspection.inspect)
          black_inspection.save
        end

        if @item.group.name == Group.where("name LIKE ?", "%Escala%").first&.name
          puts("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
          puts(item.group.name)
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
            @revision = Revision.create!(inspection_id: black_inspection.id, item_id: item.id, group_id: @item.group_id)
            @revision.created_at = DateTime.new(1000, 1, 1)
            @revision.save
            (0..11).each do |index|
              @revision.revision_colors.create!(number: index, color: false)
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

      if @item.group.name == Group.where("name LIKE ?", "%Escala%").first&.name
        redirect_to edit_ladder_revision_path(inspection_id: inspection.id), notice: 'Información modificada exitosamente'
      else
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
