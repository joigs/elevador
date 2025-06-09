class PagesController < ApplicationController

  def bash_fill
      @items = Item
                 .joins(:group)
                 .where(groups: { type_of: "ascensor" })
                 .includes(:detail, inspections: :report)


      @inspections = @items.map { |item| item.inspections.max_by(&:number) }.compact

      @inspections = @inspections.where(user_id: Current.user.id) unless Current.user.admin

      @inspections = @inspections.sort_by(&:number).reverse
      @inspections.each do |inspection|
        authorize! inspection
      end

  end

  def bash_fill_detail
    if params[:inspection_numbers].present?
      numbers = params[:inspection_numbers].split(',')
      @inspections = Inspection.where(number: numbers)
      @inspections.each do |inspection|
        authorize! inspection
      end
    else
      flash[:alert] = "No se ingresaron inspecciones"
      redirect_to bash_fill_path
    end
  end
  def update_many_details
    Detail.transaction do
      params.require(:details).each do |inspection_id, detail_params|
        inspection = Inspection.find(inspection_id)
        detail     = inspection.item.detail || inspection.item.build_detail
        detail.update!(detail_params.permit(Detail.column_names - %w[id item_id created_at updated_at]))
      end
    end

    # → **nuevo**: armar la lista de números de inspección
    inspection_ids = params[:details].keys
    numbers        = Inspection.where(id: inspection_ids).pluck(:number).join(',')

    # → redirigir al form‑matriz de Report
    redirect_to bash_fill_report_path(inspection_numbers: numbers),
                notice: "Detalles actualizados. Completa los reportes."
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Error al guardar: #{e.record.errors.full_messages.to_sentence}"
    @inspections = Inspection.where(id: params[:details].keys) # mantiene la tabla
    render :bash_fill_detail, status: :unprocessable_entity
  end

  def bash_fill_report
    numbers      = params[:inspection_numbers]&.split(',') || []
    @inspections = Inspection.includes(:report).where(number: numbers).order(:number)

    @inspections.each do |inspection|
      authorize! inspection
    end

    @inspections.each { |i| i.build_report unless i.report }
    flash.now[:alert] = "No se encontraron inspecciones" if @inspections.empty?
  end


  def update_many_reports
    Report.transaction do
      params.require(:reports).each do |inspection_id, report_params|
        inspection = Inspection.find(inspection_id)
        report     = inspection.report || inspection.build_report
        report.update!(report_params.permit(Report.column_names - %w[id inspection_id created_at updated_at]))
      end
    end
    redirect_to bash_fill_path,
                notice: "Reportes actualizados. Revísalos y guarda."
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Error: #{e.record.errors.full_messages.to_sentence}"
    @inspections = Inspection.includes(:report).where(id: params[:reports].keys)
    render :bash_fill_report, status: :unprocessable_entity
  end



end