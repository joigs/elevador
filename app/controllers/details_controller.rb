class DetailsController < ApplicationController


  # GET /details/1/edit
  def edit
    authorize! detail
    @inspection = Inspection.where(item_id: detail.item_id).where.not(result: 'black').order(created_at: :desc).first
    @item = Item.find(detail.item_id)
    @item_identificador = @item.identificador.split('-').first
    if @inspection.ins_date <= Time.zone.today && !params[:closed]
      @inspection.update(state: 'Abierto', result: 'En revisión')
    end
    @group = Group.find(Item.find(detail.item_id).group_id)
  end


  # GET /details/new



  # PATCH/PUT /details/1 or /details/1.json
  def update

    authorize! detail
    @report = Report.where(item_id: detail.item_id).last
    @inspection = Inspection.find(@report.inspection_id)

    @revision = @inspection.item.group.revision_for(@inspection)

    if @inspection.item.group.type_of == "ascensor"

      revision_2 = @revision.revision_colors.find_by(section: 2)
      revision_9 = @revision.revision_colors.find_by(section: 9)
    end

    if detail.update(detail_params)



      if @inspection.item.group.type_of == "ascensor"

        if @detail.sala_maquinas == "Responder más tarde"
          # Eliminar defectos que comienzan con 2 o 9
          remove_unwanted_rules([revision_2, revision_9], ['2', '9'])

        elsif @detail.sala_maquinas == "Si"
          # Eliminar defectos que comienzan con 9
          remove_unwanted_rules([revision_9], ['9'])

        elsif @detail.sala_maquinas == "No. Máquina en la parte superior"
          # Eliminar defectos que comienzan con 2, 9.3 y 9.4
          remove_unwanted_rules([revision_2, revision_9], ['2', '9.3', '9.4'])

        elsif @detail.sala_maquinas == "No. Máquina en foso"
          # Eliminar defectos que comienzan con 2, 9.2 y 9.4
          remove_unwanted_rules([revision_2, revision_9], ['2', '9.2', '9.4'])

        elsif @detail.sala_maquinas == "No. Maquinaria fuera de la caja de elevadores"
          # Eliminar defectos que comienzan con 2, 9.2 y 9.3
          remove_unwanted_rules([revision_2, revision_9], ['2', '9.2', '9.3'])

        end
      end
      
      flash[:notice] = "Detalle modificado exitosamente"

      if params[:closed].nil? || params[:closed] == "false"

        redirect_to edit_report_path(@report)


      else
        redirect_to inspection_path(params[:inspection_origin])
      end

    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /details/1 or /details/1.json


  private
    # Use callbacks to share common setup or constraints between actions.
    def detail
      @detail = Detail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def detail_params
      params.require(:detail).permit(:descripcion, :detalle, :marca, :modelo, :n_serie, :mm_marca, :mm_n_serie, :porcentaje, :potencia, :capacidad, :personas, :ct_marca, :ct_cantidad, :ct_diametro, :medidas_cintas, :medidas_cintas_espesor, :rol_n, :numero_permiso, :fecha_permiso, :destino, :recepcion, :empresa_instaladora, :empresa_instaladora_rut, :rv_marca, :rv_n_serie, :paradas, :embarques, :sala_maquinas, :velocidad, :item_id)
    end

  def remove_unwanted_rules(revision_colors, eliminados)
    revision_colors.each do |revision_color|
      next unless revision_color

      codes, points, levels, comment = [], [], [], []

      revision_color.codes.each_with_index do |code, index|
        unless eliminados.any? { |codigo| code.starts_with?(codigo) }
          codes << code
          points << revision_color.points[index]
          levels << revision_color.levels[index]
          comment << revision_color.comment[index]
        end
      end

      revision_color.update!(
        codes: codes,
        points: points,
        levels: levels,
        comment: comment
      )
    end
  end
end
