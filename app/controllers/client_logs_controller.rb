class ClientLogsController < ApplicationController
  skip_forgery_protection

  def create
    Rails.logger.info("[CLIENT] #{request.raw_post.to_s.first(2000)}")
    head :no_content
  end
end