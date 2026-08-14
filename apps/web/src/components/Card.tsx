// Tarjeta contenedora con variantes de padding y subcomponentes.

import type { HTMLAttributes, ReactNode } from "react";
import { cn } from "@/lib/utils";

interface CardProps extends HTMLAttributes<HTMLDivElement> {
  padding?: "md" | "lg" | "none";
  children: ReactNode;
}

export function Card({ padding = "md", className, children, ...props }: CardProps) {
  return (
    <div
      className={cn(
        "rounded-xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900",
        padding === "md" && "p-5",
        padding === "lg" && "p-8",
        className,
      )}
      {...props}
    >
      {children}
    </div>
  );
}

export function CardHeader({ className, children }: { className?: string; children: ReactNode }) {
  return <div className={cn("mb-4", className)}>{children}</div>;
}

export function CardTitle({ className, children }: { className?: string; children: ReactNode }) {
  return <h3 className={cn("text-lg font-semibold text-slate-900 dark:text-slate-100", className)}>{children}</h3>;
}

export function CardDescription({ className, children }: { className?: string; children: ReactNode }) {
  return <p className={cn("mt-1 text-sm text-slate-500 dark:text-slate-400", className)}>{children}</p>;
}

export function CardContent({ className, children }: { className?: string; children: ReactNode }) {
  return <div className={className}>{children}</div>;
}