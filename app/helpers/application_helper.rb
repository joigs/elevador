module ApplicationHelper
  #para paginacion
  include Pagy::Frontend

  def format_date(date)
    date.strftime('%d/%m/%Y') if date
  end


  def pagy_series(pagy)
    current_page = pagy.page
    total_pages = pagy.pages
    visible_pages = 8 # Número de páginas visibles adicionales a la página actual
    half_window = (visible_pages / 2).floor # Ventana alrededor de la página actual

    # Mostrar siempre la primera página
    pages = [1]

    # Calcular las páginas alrededor de la actual
    if current_page <= half_window + 1
      # Si la página actual está cerca del principio, mostrar las primeras `visible_pages` páginas
      pages += (2..[visible_pages + 1, total_pages - 1].min).to_a
    elsif current_page > total_pages - half_window
      # Si la página actual está cerca del final, mostrar las últimas `visible_pages` páginas
      pages += ([total_pages - visible_pages, 2].max..total_pages - 1).to_a
    else
      # Si la página actual está en el medio, mostrar `half_window` a cada lado
      pages += ([current_page - half_window, 2].max..[current_page + half_window, total_pages - 1].min).to_a
    end

    # Añadir la última página siempre
    pages << total_pages if total_pages > 1

    # Añadir los gaps (elipsis) si es necesario
    pages = add_gaps(pages, current_page, total_pages)

    pages
  end

  # Función para añadir elipsis ("...") en lugar de los gaps
  def add_gaps(pages, current_page, total_pages)
    # Añadir elipsis en el lado izquierdo si hay un salto entre la primera página y la segunda página mostrada
    if pages[1] > 2
      pages[1] = '...'
    end

    # Añadir elipsis en el lado derecho si hay un salto entre la penúltima página mostrada y la última página
    if pages[-2] < total_pages - 1
      pages[-2] = '...'
    end

    # Asegurarse de que la página actual no se duplique y esté en la posición correcta
    pages << current_page unless pages.include?(current_page)

    pages
  end




  def notification_class(notification_type)
    case notification_type.to_sym
    when :solicitud_pendiente
      "text-yellow-800 border-yellow-300 bg-yellow-50 dark:bg-gray-800 dark:text-yellow-300 dark:border-yellow-800"
    when :entrega_pendiente
      "text-blue-800 border-blue-300 bg-blue-50 dark:bg-gray-800 dark:text-blue-400 dark:border-blue-800"
    when :factura_pendiente
      "text-green-800 border-green-300 bg-green-50 dark:bg-gray-800 dark:text-green-400 dark:border-green-800"
    else
      "text-gray-800 border-gray-300 bg-gray-50 dark:border-gray-600 dark:bg-gray-800"
    end
  end



end
