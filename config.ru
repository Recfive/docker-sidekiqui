require 'prometheus/middleware/exporter'

require 'sidekiq/web'

require 'sidekiq-failures'
require 'sidekiq/throttled/web'
require './sidekiq_exporter'

Sidekiq.configure_client do |config|
  config.redis = {
    size: 1,
    url: "redis://#{ENV['REDIS_HOST']}:6379/0"
  }
end

use Prometheus::Middleware::Exporter, path: '/metrics.txt'
#use Rack::Session::Cookie, secret: ENV['SIDEKIQUI_COOKIE_SECRET']

Sidekiq::Throttled::Web.enhance_queues_tab!

Thread.new { SidekiqExporter.new.run }

class SidekiqUIStatus < Sinatra::Base
  get '/' do
    "OK: SidekiqUI is running"
  end
end

run Rack::URLMap.new(
  "/" => Sidekiq::Web,
  "/sidekiqui/_status" => SidekiqUIStatus
)
