import HyperDX from "@hyperdx/node-opentelemetry";

HyperDX.init({
  apiKey: process.env.HYPERDX_API_KEY,
  service: process.env.HYPERDX_SERVICE_NAME ?? "production-app",
});
