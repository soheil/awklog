if Rails.env.production?
  Sidekiq.default_worker_options = { 'backtrace' => true }

  $redis = Redis.new(:host => '10.128.15.203', :port => 6379, :timeout => 25)

  redis_conn = proc {
    $redis
  }
  Sidekiq.configure_client do |config|
    config.redis = ConnectionPool.new(size: 5, &redis_conn)
  end
  Sidekiq.configure_server do |config|
    config.redis = ConnectionPool.new(size: 1750, &redis_conn)
  end

  schedule_file = 'config/schedule.yml'

  if File.exist?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end

  Sidekiq::Extensions.enable_delay!

  Groupdate.time_zone = 'Pacific Time (US & Canada)'
end
