# config/initializers/sidekiq_cron.rb
if defined?(Sidekiq) && Sidekiq.server? && Rails.env.production?
  schedule_file = Rails.root.join('config', 'schedule', 'sidekiq_cron.yml')
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end
