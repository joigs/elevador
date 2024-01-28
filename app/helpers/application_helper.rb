module ApplicationHelper
  #para paginacion
  include Pagy::Frontend

  def format_date(date)
    date.strftime('%d/%m/%Y') if date
  end

end
