SIDEKIQ_REDIS_CONFIGURATION = {
    url: ENV.fetch("REDIS_PROVIDER", nil),
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    network_timeout: 5,
    pool_timeout: 5,
}
  
Sidekiq.configure_server do |config|
    config.redis = SIDEKIQ_REDIS_CONFIGURATION
end

Sidekiq.configure_client do |config|
    config.redis = SIDEKIQ_REDIS_CONFIGURATION
end