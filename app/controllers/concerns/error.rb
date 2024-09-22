module Error
  extend ActiveSupport::Concern
  included do

    rescue_from ActiveRecord::RecordNotFound do
      flash[:alert] = "No se ha encontrado"
      redirect_to home_path
    end


  end
end