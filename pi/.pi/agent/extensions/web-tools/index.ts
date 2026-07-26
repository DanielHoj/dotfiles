import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { DEFAULT_MAX_BYTES, DEFAULT_MAX_LINES, formatSize, truncateHead } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

type SearchProvider = "auto" | "searxng" | "duckduckgo" | "brave" | "tavily";

type SearchResult = {
	title: string;
	url: string;
	snippet?: string;
	source?: string;
};

const SearchParams = Type.Object({
	query: Type.String({ description: "Search query" }),
	provider: Type.Optional(
		Type.Union([
			Type.Literal("auto"),
			Type.Literal("searxng"),
			Type.Literal("duckduckgo"),
			Type.Literal("brave"),
			Type.Literal("tavily"),
		], { description: "Search backend. Defaults to WEB_SEARCH_PROVIDER or auto." }),
	),
	limit: Type.Optional(Type.Number({ description: "Maximum results to return (default 5, max 20)" })),
});

const FetchParams = Type.Object({
	url: Type.String({ description: "URL to fetch" }),
	maxChars: Type.Optional(Type.Number({ description: "Maximum text characters to return before truncation (default 20000)" })),
});

function clampLimit(limit: unknown): number {
	const n = typeof limit === "number" && Number.isFinite(limit) ? Math.floor(limit) : 5;
	return Math.max(1, Math.min(20, n));
}

function chooseProvider(requested?: SearchProvider): Exclude<SearchProvider, "auto"> {
	const provider = requested && requested !== "auto" ? requested : (process.env.WEB_SEARCH_PROVIDER as SearchProvider | undefined);
	if (provider && provider !== "auto") return provider as Exclude<SearchProvider, "auto">;
	if (process.env.SEARXNG_URL) return "searxng";
	if (process.env.BRAVE_API_KEY) return "brave";
	if (process.env.TAVILY_API_KEY) return "tavily";
	return "duckduckgo";
}

function decodeHtml(input: string): string {
	return input
		.replace(/&amp;/g, "&")
		.replace(/&lt;/g, "<")
		.replace(/&gt;/g, ">")
		.replace(/&quot;/g, '"')
		.replace(/&#39;/g, "'")
		.replace(/&#x2F;/g, "/")
		.replace(/&#(\d+);/g, (_m, n) => String.fromCharCode(Number(n)))
		.replace(/&#x([0-9a-fA-F]+);/g, (_m, n) => String.fromCharCode(Number.parseInt(n, 16)));
}

function absoluteDuckUrl(href: string): string {
	const decoded = decodeHtml(href);
	try {
		const url = new URL(decoded, "https://duckduckgo.com");
		const uddg = url.searchParams.get("uddg");
		return uddg ? decodeURIComponent(uddg) : url.toString();
	} catch {
		return decoded;
	}
}

async function searchSearxng(query: string, limit: number, signal?: AbortSignal): Promise<SearchResult[]> {
	const base = process.env.SEARXNG_URL;
	if (!base) throw new Error("SEARXNG_URL is required for provider=searxng");
	const url = new URL("/search", base);
	url.searchParams.set("q", query);
	url.searchParams.set("format", "json");
	url.searchParams.set("language", "en");
	const res = await fetch(url, { headers: { accept: "application/json" }, signal });
	if (!res.ok) throw new Error(`SearxNG search failed: HTTP ${res.status}`);
	const data = (await res.json()) as { results?: Array<{ title?: string; url?: string; content?: string; engine?: string }> };
	return (data.results ?? [])
		.filter((r) => r.title && r.url)
		.slice(0, limit)
		.map((r) => ({ title: r.title!, url: r.url!, snippet: r.content, source: r.engine ?? "searxng" }));
}

async function searchBrave(query: string, limit: number, signal?: AbortSignal): Promise<SearchResult[]> {
	const key = process.env.BRAVE_API_KEY;
	if (!key) throw new Error("BRAVE_API_KEY is required for provider=brave");
	const url = new URL("https://api.search.brave.com/res/v1/web/search");
	url.searchParams.set("q", query);
	url.searchParams.set("count", String(limit));
	const res = await fetch(url, {
		headers: { accept: "application/json", "x-subscription-token": key },
		signal,
	});
	if (!res.ok) throw new Error(`Brave search failed: HTTP ${res.status}`);
	const data = (await res.json()) as { web?: { results?: Array<{ title?: string; url?: string; description?: string }> } };
	return (data.web?.results ?? [])
		.filter((r) => r.title && r.url)
		.slice(0, limit)
		.map((r) => ({ title: r.title!, url: r.url!, snippet: r.description, source: "brave" }));
}

async function searchTavily(query: string, limit: number, signal?: AbortSignal): Promise<SearchResult[]> {
	const key = process.env.TAVILY_API_KEY;
	if (!key) throw new Error("TAVILY_API_KEY is required for provider=tavily");
	const res = await fetch("https://api.tavily.com/search", {
		method: "POST",
		headers: { "content-type": "application/json" },
		body: JSON.stringify({ api_key: key, query, max_results: limit, search_depth: "basic" }),
		signal,
	});
	if (!res.ok) throw new Error(`Tavily search failed: HTTP ${res.status}`);
	const data = (await res.json()) as { results?: Array<{ title?: string; url?: string; content?: string }> };
	return (data.results ?? [])
		.filter((r) => r.title && r.url)
		.slice(0, limit)
		.map((r) => ({ title: r.title!, url: r.url!, snippet: r.content, source: "tavily" }));
}

async function searchDuckDuckGo(query: string, limit: number, signal?: AbortSignal): Promise<SearchResult[]> {
	const url = new URL("https://duckduckgo.com/html/");
	url.searchParams.set("q", query);
	const res = await fetch(url, {
		headers: {
			"user-agent": "Mozilla/5.0 (compatible; pi-web-tools/1.0)",
			accept: "text/html",
		},
		signal,
	});
	if (!res.ok) throw new Error(`DuckDuckGo search failed: HTTP ${res.status}`);
	const html = await res.text();
	const results: SearchResult[] = [];
	const blockRe = /<div class="result[\s\S]*?(?=<div class="result|<\/body>)/g;
	for (const blockMatch of html.matchAll(blockRe)) {
		const block = blockMatch[0];
		const titleMatch = block.match(/<a[^>]+class="result__a"[^>]+href="([^"]+)"[^>]*>([\s\S]*?)<\/a>/);
		if (!titleMatch) continue;
		const snippetMatch = block.match(/<a[^>]+class="result__snippet"[^>]*>([\s\S]*?)<\/a>|<div[^>]+class="result__snippet"[^>]*>([\s\S]*?)<\/div>/);
		const title = decodeHtml(titleMatch[2].replace(/<[^>]+>/g, "").trim());
		const resultUrl = absoluteDuckUrl(titleMatch[1]);
		const snippetHtml = snippetMatch?.[1] ?? snippetMatch?.[2] ?? "";
		const snippet = decodeHtml(snippetHtml.replace(/<[^>]+>/g, "").replace(/\s+/g, " ").trim());
		if (title && resultUrl) results.push({ title, url: resultUrl, snippet, source: "duckduckgo" });
		if (results.length >= limit) break;
	}
	return results;
}

async function runSearch(provider: Exclude<SearchProvider, "auto">, query: string, limit: number, signal?: AbortSignal) {
	switch (provider) {
		case "searxng":
			return searchSearxng(query, limit, signal);
		case "brave":
			return searchBrave(query, limit, signal);
		case "tavily":
			return searchTavily(query, limit, signal);
		case "duckduckgo":
			return searchDuckDuckGo(query, limit, signal);
	}
}

function formatResults(query: string, provider: string, results: SearchResult[]): string {
	if (results.length === 0) return `No results for ${JSON.stringify(query)} via ${provider}.`;
	return [
		`Search results for ${JSON.stringify(query)} via ${provider}:`,
		"",
		...results.map((r, i) => {
			const lines = [`${i + 1}. ${r.title}`, `   URL: ${r.url}`];
			if (r.snippet) lines.push(`   Snippet: ${r.snippet}`);
			return lines.join("\n");
		}),
	].join("\n");
}

function htmlToText(html: string): string {
	return decodeHtml(
		html
			.replace(/<script[\s\S]*?<\/script>/gi, " ")
			.replace(/<style[\s\S]*?<\/style>/gi, " ")
			.replace(/<noscript[\s\S]*?<\/noscript>/gi, " ")
			.replace(/<[^>]+>/g, " ")
			.replace(/\s+/g, " ")
			.trim(),
	);
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "web_search",
		label: "Web Search",
		description:
			"Search the web. Providers: searxng (set SEARXNG_URL), brave (BRAVE_API_KEY), tavily (TAVILY_API_KEY), or experimental duckduckgo fallback. Use web_fetch to read result pages.",
		promptSnippet: "Search the web for current facts, docs, and public pages",
		promptGuidelines: [
			"Use web_search when the user asks for current information, web research, or up-to-date documentation beyond local files.",
			"After web_search, use web_fetch on promising result URLs when details or citations matter.",
		],
		parameters: SearchParams,
		async execute(_toolCallId, params, signal) {
			const provider = chooseProvider(params.provider as SearchProvider | undefined);
			const limit = clampLimit(params.limit);
			const results = await runSearch(provider, params.query, limit, signal);
			const text = formatResults(params.query, provider, results);
			const truncation = truncateHead(text, { maxLines: DEFAULT_MAX_LINES, maxBytes: DEFAULT_MAX_BYTES });
			return {
				content: [{ type: "text", text: truncation.content }],
				details: { provider, query: params.query, count: results.length, results, truncation },
			};
		},
	});

	pi.registerTool({
		name: "web_fetch",
		label: "Web Fetch",
		description: "Fetch a URL and return readable text extracted from HTML or raw text, truncated for context safety.",
		promptSnippet: "Fetch and extract readable text from a URL",
		promptGuidelines: ["Use web_fetch to inspect specific URLs from web_search results or URLs provided by the user."],
		parameters: FetchParams,
		async execute(_toolCallId, params, signal) {
			const res = await fetch(params.url, {
				headers: { "user-agent": "Mozilla/5.0 (compatible; pi-web-tools/1.0)", accept: "text/html,text/plain,*/*" },
				signal,
			});
			if (!res.ok) throw new Error(`Fetch failed: HTTP ${res.status}`);
			const contentType = res.headers.get("content-type") ?? "";
			const raw = await res.text();
			const extracted = contentType.includes("text/html") || raw.includes("<html") ? htmlToText(raw) : raw;
			const maxBytes = Math.max(1_000, Math.min(100_000, params.maxChars ?? 20_000));
			const truncation = truncateHead(extracted, { maxLines: DEFAULT_MAX_LINES, maxBytes });
			let text = `Fetched ${params.url}\nContent-Type: ${contentType || "unknown"}\n\n${truncation.content}`;
			if (truncation.truncated) {
				text += `\n\n[Content truncated: showing ${truncation.outputLines} of ${truncation.totalLines} lines (${formatSize(truncation.outputBytes)} of ${formatSize(truncation.totalBytes)}).]`;
			}
			return {
				content: [{ type: "text", text }],
				details: { url: params.url, status: res.status, contentType, truncation },
			};
		},
	});
}
