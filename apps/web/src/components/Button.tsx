// Botón con variantes y soporte de asChild (composicion con Link u otros).

"use client";

import { Children, cloneElement, type ButtonHTMLAttributes, type ReactElement, type ReactNode } from "react";
import { cn } from "@/lib/utils";

type Variant = "primary" | "secondary" | "ghost" | "danger" | "outline";
type Size = "sm" | "md" | "lg" | "icon";

const VARIANTS: Record<Variant, string> = {
  primary:
    "bg-indigo-600 text-white hover:bg-indigo-500 focus-visible:ring-indigo-500/40 disabled:bg-indigo-600/50",
  secondary:
    "bg-slate-100 text-slate-800 hover:bg-slate-200 focus-visible:ring-slate-400/40 dark:bg-slate-800 dark:text-slate-100 dark:hover:bg-slate-700",
  ghost:
    "text-slate-600 hover:bg-slate-100 hover:text-slate-900 focus-visible:ring-slate-400/40 dark:text-slate-300 dark:hover:bg-slate-800 dark:hover:text-slate-100",
  danger: "bg-red-600 text-white hover:bg-red-500 focus-visible:ring-red-500/40",
  outline:
    "border border-slate-300 text-slate-700 hover:bg-slate-50 focus-visible:ring-slate-400/40 dark:border-slate-700 dark:text-slate-200 dark:hover:bg-slate-800",
};

const SIZES: Record<Size, string> = {
  sm: "h-8 px-3 text-sm",
  md: "h-10 px-4 text-sm",
  lg: "h-12 px-6 text-base",
  icon: "h-10 w-10",
};

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  size?: Size;
  asChild?: boolean;
  children: ReactNode;
}

export function Button({ variant = "primary", size = "md", asChild = false, className, children, ...props }: ButtonProps) {
  const classes = cn(
    "inline-flex items-center justify-center gap-2 rounded-lg font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 dark:focus-visible:ring-offset-slate-950 disabled:pointer-events-none",
    VARIANTS[variant],
    SIZES[size],
    className,
  );

  if (asChild) {
    const child = Children.only(children) as ReactElement<{ className?: string }>;
    return cloneElement(child, { className: cn(classes, child.props.className) });
  }

  return (
    <button type="button" className={classes} {...props}>
      {children}
    </button>
  );
}