require 'minitest/autorun'
require 'pry'
require 'rack/test'
require 'sidekiq'
require './sidekiq_exporter'

Sidekiq.configure_client do |config|
  config.redis = {
    size: 1,
    url: "redis://#{ENV['SIDEKIQUI_REDIS_HOST']}:6379/0"
  }
end

class SidekiquiTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      eval File.read(File.dirname(__FILE__) + '/config.ru')
    end
  end

  def test_sidekiqui_root
    get '/'

    assert last_response.ok?
    assert last_response.body.match(/Dashboard/)
  end

  def test_get_metrics
    # Queue some jobs...
    3.times { AccountsTestJob.perform_async }
    ConversationsTestJob.perform_async

    metric_lines = []
    tries = 0

    # Loop until we get live metrics from the Prometheus endpoint
    while metric_lines.empty? && tries < 20
      tries += 1

      sleep 0.1
      get '/_metrics'

      if !last_response.body.empty?
        metric_lines = last_response.body.split("\n").reject { |line| line[0] == '#' }
      end
    end

    assert last_response.ok?

    assert last_response.body.match('queue_size{queue="accounts"} 3.0')
    assert last_response.body.match('queue_latency{queue="accounts"}')

    assert last_response.body.match('queue_size{queue="conversations"} 1.0')
    assert last_response.body.match('queue_latency{queue="conversations"}')

    Sidekiq::Queue.all.each { |queue| queue.clear }
  end
end

class AccountsTestJob
  include Sidekiq::Worker
  sidekiq_options queue: 'accounts'
  def perform; end
end

class ConversationsTestJob
  include Sidekiq::Worker
  sidekiq_options queue: 'conversations'
  def perform; end
end
