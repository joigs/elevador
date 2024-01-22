class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include Pagy::Backend
  include Error


end
