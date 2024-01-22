module InspectionsHelper
  def display_periodicity(validation)
    case validation
    when 1
      '1 año'
    when 2
      '2 años'
    else
      'Error: el valor ingresado no está permitido, en caso de que la periodicidad ya no sea solo de 1 o dos años, modificar el codigo en app/controllers/helpers/inspections_helper.rb' # Add a default value if needed
    end
  end
end
