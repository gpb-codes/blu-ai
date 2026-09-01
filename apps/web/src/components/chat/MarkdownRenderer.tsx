"use client";

import { useState } from "react";

export function MarkdownRenderer({ text }: { text: string }) {
  // Simple markdown: code blocks ```, inline `code`, **bold**, lists, links
  const parts = splitCodeBlocks(text);
  return (
    <div className="prose prose-sm max-w-none prose-p:my-2 prose-headings:font-geist prose-headings:font-semibold prose-code:text-sm prose-pre:my-3">
      {parts.map((part, i) =>
        part.type === "code" ? (
          <CodeBlock key={i} code={part.content} lang={part.lang} />
        ) : (
          <InlineMarkdown key={i} text={part.content} />
        ),
      )}
    </div>
  );
}

type Part = { type: "text"; content: string } | { type: "code"; content: string; lang?: string };

function splitCodeBlocks(text: string): Part[] {
  const re = /```(\w*)\n([\s\S]*?)```/g;
  const out: Part[] = [];
  let last = 0;
  let m: RegExpExecArray | null;
  while ((m = re.exec(text))) {
    if (m.index > last) out.push({ type: "text", content: text.slice(last, m.index) });
    out.push({ type: "code", content: m[2].trim(), lang: m[1] || undefined });
    last = m.index + m[0].length;
  }
  if (last < text.length) out.push({ type: "text", content: text.slice(last) });
  if (out.length === 0) out.push({ type: "text", content: text });
  return out;
}

function InlineMarkdown({ text }: { text: string }) {
  // Very light: split paragraphs, handle **bold**, `inline code`, [link](url), lists
  const paragraphs = text.split(/\n{2,}/);
  return (
    <>
      {paragraphs.map((para, idx) => {
        if (para.match(/^[-*]\s/m)) {
          const items = para.split("\n").filter((l) => l.trim().match(/^[-*]\s/));
          return (
            <ul key={idx} className="my-2 list-disc pl-5">
              {items.map((it, j) => (
                <li key={j} className="text-sm leading-relaxed text-blu-on">
                  <Inline text={it.replace(/^[-*]\s/, "")} />
                </li>
              ))}
            </ul>
          );
        }
        if (para.trim().startsWith("|") && para.includes("|")) {
          return <MarkdownTable key={idx} text={para} />;
        }
        return (
          <p key={idx} className="my-2 text-[15px] leading-relaxed text-blu-on">
            <Inline text={para} />
          </p>
        );
      })}
    </>
  );
}

function Inline({ text }: { text: string }) {
  // **bold**, `code`, [link](url)
  const tokens: React.ReactNode[] = [];
  const re = /(\*\*.*?\*\*|`[^`]+`|\[.*?\]\(.*?\))/g;
  let last = 0;
  let m: RegExpExecArray | null;
  let key = 0;
  while ((m = re.exec(text))) {
    if (m.index > last) tokens.push(text.slice(last, m.index));
    const raw = m[0];
    if (raw.startsWith("**")) tokens.push(<strong key={key++} className="font-semibold text-blu-on">{raw.slice(2, -2)}</strong>);
    else if (raw.startsWith("`")) tokens.push(<code key={key++} className="rounded bg-blu-surface-high px-1 py-0.5 font-mono text-[13px] text-blu-on">{raw.slice(1, -1)}</code>);
    else if (raw.startsWith("[")) {
      const mm = /\[([^\]]+)\]\(([^)]+)\)/.exec(raw);
      if (mm) tokens.push(<a key={key++} href={mm[2]} target="_blank" rel="noopener noreferrer" className="text-blu-primary-solid underline hover:text-blu-primary">{mm[1]}</a>);
      else tokens.push(raw);
    }
    last = m.index + m[0].length;
  }
  if (last < text.length) tokens.push(text.slice(last));
  return <>{tokens}</>;
}

function MarkdownTable({ text }: { text: string }) {
  const rows = text
    .trim()
    .split("\n")
    .map((r) => r.split("|").map((c) => c.trim()).filter(Boolean));
  if (rows.length < 2) return <InlineMarkdown text={text} />;
  const header = rows[0];
  const body = rows.slice(2);
  return (
    <div className="my-3 overflow-x-auto rounded-lg border border-blu-outline/20">
      <table className="w-full text-sm">
        <thead className="bg-blu-surface-low">
          <tr>
            {header.map((h, i) => (
              <th key={i} className="px-3 py-2 text-left font-medium text-blu-on">
                {h}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {body.map((row, i) => (
            <tr key={i} className="border-t border-blu-outline/10">
              {row.map((cell, j) => (
                <td key={j} className="px-3 py-2 text-blu-on-variant">
                  {cell}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function CodeBlock({ code, lang }: { code: string; lang?: string }) {
  const [copied, setCopied] = useState(false);
  const copy = async () => {
    await navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 1200);
  };
  return (
    <div className="my-3 overflow-hidden rounded-lg border border-blu-outline/20 bg-blu-surface-low">
      <div className="flex items-center justify-between border-b border-blu-outline/10 bg-blu-surface px-3 py-1.5">
        <span className="font-mono text-xs text-blu-on-variant">{lang || "code"}</span>
        <button
          type="button"
          onClick={copy}
          className="rounded px-2 py-1 font-mono text-xs text-blu-on-variant hover:bg-blu-surface-high hover:text-blu-on"
        >
          {copied ? "Copiado" : "Copiar"}
        </button>
      </div>
      <pre className="overflow-x-auto p-4 font-mono text-sm leading-relaxed text-blu-on">
        <code>{code}</code>
      </pre>
    </div>
  );
}
