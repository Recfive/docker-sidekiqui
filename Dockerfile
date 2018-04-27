FROM r5/ruby

# DataDog autodiscovery of Prometheus endpoint
LABEL "com.datadoghq.ad.check_names"='["prometheus"]'
LABEL "com.datadoghq.ad.init_configs"='[{}]'
LABEL "com.datadoghq.ad.instances"='[{"prometheus_url": "http://%%host%%:%%port%%/metrics.txt", "namespace": "r5.sidekiq", "metrics": ["*"]}]'

RUN mkdir -p /app
WORKDIR /app

ENV BUNDLE_GEMFILE=/app/Gemfile BUNDLE_JOBS=2 BUNDLE_PATH=/bundle

COPY prometheus-client_ruby /app/prometheus-client_ruby

# Load gems needed by images that extend this image
ADD Gemfile /app/
RUN bundle install --path /bundle

ADD . /app/

ENV RACK_ENV=production

CMD ["puma", "-p", "3000"]
