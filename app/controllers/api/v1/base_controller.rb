module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false

      skip_before_action :protect_pages, raise: false
      skip_before_action :restrict_relleno_access, raise: false
    end
  end
end