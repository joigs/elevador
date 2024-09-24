module ApplicationHelper
  #para paginacion
  include Pagy::Frontend

  def format_date(date)
    date.strftime('%d/%m/%Y') if date
  end


  def pagy_series(pagy)
    series = pagy.series(size: [1, 2, 2, 1])
    series.map { |page| page == :gap ? '...' : page }
  end

end
