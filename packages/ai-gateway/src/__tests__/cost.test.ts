// Pruebas del costeo por llamada (plan FREE/BYOK/CREDITS y ledger de auditoría).

import { describe, expect, it } from "vitest";
import { costUsd, creditsForModel } from "../cost.js";

describe("costUsd", () => {
  it("calcula gemini-flash (0.075$ in / 0.3$ out por millón)", () => {
    expect(costUsd("gemini-flash", 1_000_000, 1_000_000)).toBeCloseTo(0.375, 5);
  });

  it("calcula gpt-4o-mini (0.15$ in / 0.6$ out)", () => {
    expect(costUsd("gpt-4o-mini", 1_000_000, 500_000)).toBeCloseTo(0.45, 5);
  });

  it("usa precio conservador para modelos desconocidos", () => {
    expect(costUsd("modelo-futuro", 1_000_000, 1_000_000)).toBeCloseTo(3, 5);
  });

  it("0 tokens cuestan 0", () => {
    expect(costUsd("claude-sonnet-5", 0, 0)).toBe(0);
  });
});

describe("creditsForModel", () => {
  it("usa el peso configurado por modelo", () => {
    expect(creditsForModel("claude-sonnet-5")).toBe(15);
    expect(creditsForModel("gemini-flash")).toBe(1);
    expect(creditsForModel("claude-opus-4-8")).toBe(60);
  });

  it("modelo sin peso definido → 5 (default)", () => {
    expect(creditsForModel("blu-light-v3")).toBe(5);
  });
});