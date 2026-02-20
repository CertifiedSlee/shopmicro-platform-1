const express = require("express");
const { Pool } = require("pg");
const redis = require("redis");

// --- OpenTelemetry (minimal, safe defaults) ---
const { NodeSDK } = require("@opentelemetry/sdk-node");
const { getNodeAutoInstrumentations } = require("@opentelemetry/auto-instrumentations-node");
const { OTLPTraceExporter } = require("@opentelemetry/exporter-trace-otlp-http");
const { OTLPMetricExporter } = require("@opentelemetry/exporter-metrics-otlp-http");
const { PeriodicExportingMetricReader } = require("@opentelemetry/sdk-metrics");

function startOtel() {
  const tracesUrl = process.env.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT || "http://otel-collector:4318/v1/traces";
  const metricsUrl = process.env.OTEL_EXPORTER_OTLP_METRICS_ENDPOINT || "http://otel-collector:4318/v1/metrics";

  const sdk = new NodeSDK({
    traceExporter: new OTLPTraceExporter({ url: tracesUrl }),
    metricReader: new PeriodicExportingMetricReader({
      exporter: new OTLPMetricExporter({ url: metricsUrl }),
    }),
    instrumentations: [getNodeAutoInstrumentations()],
  });

  try {
  const maybePromise = sdk.start();
  if (maybePromise && typeof maybePromise.catch === "function") {
    maybePromise.catch(() => {});
  }
} catch (_) {}
}

if (process.env.OTEL_ENABLED === "true") startOtel();

const app = express();
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST || "postgres",
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "postgres",
  database: process.env.DB_NAME || "shopmicro",
  port: Number(process.env.DB_PORT || 5432),
});

const cache = redis.createClient({
  url: process.env.REDIS_URL || "redis://redis:6379",
});
cache.connect().catch(() => {});

app.get("/health", async (_req, res) => {
  res.json({ status: "ok", service: "backend" });
});

app.get("/products", async (_req, res) => {
  try {
    const cached = await cache.get("products");
    if (cached) return res.json(JSON.parse(cached));
    const result = await pool.query("SELECT id, name, price FROM products ORDER BY id");
    await cache.setEx("products", 30, JSON.stringify(result.rows));
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: "backend_error", detail: err.message });
  }
});

app.listen(8080, () => console.log("backend listening on 8080"));
