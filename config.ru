require 'prometheus/middleware/exporter'
require 'sidekiq/web'
require './sidekiq_exporter'

Sidekiq.configure_client do |config|
  config.redis = {
    size: 1,
    url: "redis://#{ENV['SIDEKIQUI_REDIS_HOST']}:6379/0"
  }
end

use Prometheus::Middleware::Exporter, path: '/_metrics'
use Rack::Session::Cookie, secret: ENV['SIDEKIQUI_COOKIE_SECRET']

Thread.new { SidekiqExporter.new.run }

run Sidekiq::Web
