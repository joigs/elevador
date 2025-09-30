# app/workers/check_expirations_worker.rb
class CheckExpirationsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3, queue: :default

  def perform
    Inspection.check_all_expirations
  end
end
