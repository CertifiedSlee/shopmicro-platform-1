from flask import Flask, jsonify
import random
import os

# --- OpenTelemetry (minimal) ---
OTEL_ENABLED = os.getenv("OTEL_ENABLED", "false").lower() == "true"
if OTEL_ENABLED:
    from opentelemetry import trace
    from opentelemetry.instrumentation.flask import FlaskInstrumentor
    from opentelemetry.sdk.resources import Resource
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import BatchSpanProcessor
    from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter

app = Flask(__name__)

if OTEL_ENABLED:
    resource = Resource.create({"service.name": "ml-service"})
    provider = TracerProvider(resource=resource)
    exporter = OTLPSpanExporter(endpoint=os.getenv("OTEL_EXPORTER_OTLP_TRACES_ENDPOINT", "http://otel-collector:4318/v1/traces"))
    provider.add_span_processor(BatchSpanProcessor(exporter))
    trace.set_tracer_provider(provider)
    FlaskInstrumentor().instrument_app(app)

@app.get("/health")
def health():
    return jsonify({"status": "ok", "service": "ml-service"})

@app.get("/recommendations/<int:user_id>")
def recommendations(user_id: int):
    catalog = ["keyboard", "monitor", "headset", "mouse", "webcam"]
    random.seed(user_id)
    picks = random.sample(catalog, 3)
    return jsonify({"user_id": user_id, "recommendations": picks})

@app.get("/metrics")
def metrics():
    # placeholder metric so scrape doesn't fail in starter mode
    return "shopmicro_ml_requests_total 1\n", 200, {"Content-Type": "text/plain; version=0.0.4"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
