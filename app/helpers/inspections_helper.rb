module InspectionsHelper

  #validation es un numero entero, pero el usuario lo debe ver como un string con la palabra años, asi que esto se encarga de eso
  def display_periodicity(validation)
    case validation
    when 1
      '1 año'
    when 2
      '2 años'
    else
      'Error al ingresar la periodicidad, por favor intente nuevamente'
    end
  end
end
