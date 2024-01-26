class ApplicationController < ActionController::Base
  include Authentication #Manejo de usuarios y sesiones
  include Authorization #Permisos
  include Pagy::Backend #Paginacion para que este más optimizado
  include Error #Manejo de errores supongo


end
