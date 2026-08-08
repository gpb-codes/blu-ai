import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    include: [
      "packages/*/src/**/*.test.ts",
      "apps/api/src/**/*.test.ts",
      "apps/api/test/**/*.e2e.spec.ts",
    ],
    testTimeout: 20000,
    env: {
      DATABASE_URL: "postgresql://postgres:blu_local_dev@localhost:5434/blu_ia",
      JWT_SECRET: "test-secret-for-vitest",
      JWT_EXPIRES_IN: "15m",
      JWT_REFRESH_EXPIRES_IN: "30d",
    },
  },
});