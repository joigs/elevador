class HomeController < ApplicationController
  def index
  end


  def sync_data

    render json: { status: "success" }, status: :ok
  end

end
