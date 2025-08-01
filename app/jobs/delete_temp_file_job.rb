class DeleteTempFileJob < ApplicationJob
  queue_as :default

  def perform(file_path)
    File.delete(file_path) if File.exist?(file_path)
  end
end