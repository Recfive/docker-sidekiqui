require 'prometheus/client'
require 'sidekiq'

class SidekiqExporter
  def initialize
    @registry = Prometheus::Client.registry
    @queue_size = @registry.gauge(:queue_size, 'A gauge of the number of the queue size')
    @queue_latency = @registry.gauge(:queue_latency, 'A gauge of the latency of the queue')
  end

  def run
    while true
      Sidekiq::Queue.all.each do |queue|
        @queue_size.set({ queue: queue.name }, queue.size)
        @queue_latency.set({ queue: queue.name }, queue.latency)
      end

      sleep 1
    end
  end
end
