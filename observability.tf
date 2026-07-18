# Holds the non-secret collector configuration injected into each sidecar.
resource "aws_ssm_parameter" "grafana_collector_config" {
  name = "/${var.name_prefix}/otel/config"
  type = "String"

  value = <<-YAML
    receivers:
      otlp:
        protocols:
          http:
            endpoint: 127.0.0.1:4318
      prometheus:
        config:
          scrape_configs:
            - job_name: $${env:OTEL_SERVICE_NAME}
              metrics_path: /metrics
              static_configs:
                - targets: ["$${env:METRICS_ENDPOINT}"]
      awsecscontainermetrics:
        collection_interval: 60s
    extensions:
      basicauth/grafana:
        client_auth:
          username: $${env:GRAFANA_OTLP_USERNAME}
          password: $${env:GRAFANA_OTLP_TOKEN}
    processors:
      batch: {}
      resource/metrics:
        attributes:
          - action: upsert
            key: service.name
            value: $${env:OTEL_SERVICE_NAME}
    exporters:
      otlphttp/grafana:
        endpoint: $${env:GRAFANA_OTLP_ENDPOINT}
        auth:
          authenticator: basicauth/grafana
        retry_on_failure:
          enabled: true
    service:
      extensions: [basicauth/grafana]
      pipelines:
        traces:
          receivers: [otlp]
          processors: [batch]
          exporters: [otlphttp/grafana]
        logs:
          receivers: [otlp]
          processors: [batch]
          exporters: [otlphttp/grafana]
        metrics:
          receivers: [prometheus, awsecscontainermetrics]
          processors: [resource/metrics, batch]
          exporters: [otlphttp/grafana]
  YAML
}

# Provides a workshop placeholder that participants replace with their Grafana write token.
resource "aws_ssm_parameter" "grafana_otlp_token" {
  name  = "/${var.name_prefix}/grafana/otlp/token"
  type  = "SecureString"
  value = "SET_ME"

  lifecycle {
    ignore_changes = [value]
  }
}
