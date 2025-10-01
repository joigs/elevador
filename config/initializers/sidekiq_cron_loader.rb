# config/initializers/sidekiq_cron_loader.rb
if defined?(Sidekiq) && Sidekiq.server?
  schedule_file = Rails.root.join('config', 'schedule', 'sidekiq_cron.yml')
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end
