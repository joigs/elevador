class ReportsController < ApplicationController

  # GET /reports/1/edit
  def edit
    authorize! report
    @item = @report.item
    @previous_inspection = @item.inspections.where(state: ["Cerrado", "Abierto"]).order(number: :desc).offset(1).first

    @black_inspection = Inspection.find_by(number: @report.inspection.number*-1, item_id: @item.id, state: 'black', result: 'black')
    if @previous_inspection
      @show_third_radio_button = true
    else
      @show_third_radio_button = false
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



         black_inspection = Inspection.find_by(number: black_number, item_id: @item.id, state: 'black', result: 'black')


        if black_inspection

          was_created = false
        else
          was_created = true
        end



        if was_created
          factura = Facturacion.find_by(number: 0)
          black_inspection= Inspection.create!(number: black_number, item_id: @item.id, principal_id: @item.principal_id, place: inspection.place, ins_date: inspection.ins_date, state: 'black', result: 'black', rerun: false, facturacion_id: factura.id, region: "no", comuna: "no")
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
              @revision.revision_colors.create!(section: number, color: false)
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
                @revision.revision_colors.create!(section: index, color: false)
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
          @black_inspection.destroy
        end
      end


      if inspection.ins_date <= Date.today

        flash[:notice] = "Información modificada exitosamente"
        if @item.group.type_of == "escala"
          if params[:closed].nil? || params[:closed] == "false"
            redirect_to edit_ladder_revision_path(inspection_id: inspection.id)
          else
            redirect_to inspection_path(inspection)
          end
        elsif @item.group.type_of == "libre"
          redirect_to edit_libre_revision_path(inspection_id: inspection.id)
        elsif @item.group.type_of == "ascensor"
          if params[:closed].nil? || params[:closed] == "false"
            redirect_to edit_revision_path(inspection_id: inspection.id)
          else
            redirect_to inspection_path(inspection)
          end
        end
      else
        flash[:notice] = "Información modificada exitosamente. Vuelva el día de la inspección"
        redirect_to inspection_path(inspection)
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
      params.require(:report).permit(:certificado_minvu, :cert_ant, :fecha, :empresa_anterior, :cert_ant_real, :ea_rol, :ea_rut, :empresa_mantenedora, :em_rol, :em_rut, :vi_co_man_ini, :vi_co_man_ter, :nom_tec_man, :tm_rut, :ul_reg_man, :urm_fecha, :inspection_id, :item_id, :fecha_sistema, :empresa_anterior_sistema, :ea_rol_sistema, :ea_rut_sistema, :past_number, :past_date)
    end
end
