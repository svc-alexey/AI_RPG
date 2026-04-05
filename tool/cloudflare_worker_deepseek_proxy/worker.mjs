/**
 * Forwards OpenAI-compatible paths to https://api.deepseek.com and adds CORS headers.
 * Deploy on Cloudflare Workers; set app Base URL to https://<your-worker>/v1
 */
const UPSTREAM_ORIGIN = "https://api.deepseek.com";

function corsHeaders(request) {
  const origin = request.headers.get("Origin");
  const allow = origin && origin.length > 0 ? origin : "*";
  const reqHdr = request.headers.get("Access-Control-Request-Headers");
  return {
    "Access-Control-Allow-Origin": allow,
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS, HEAD",
    "Access-Control-Allow-Headers":
      reqHdr || "Content-Type, Authorization, OpenAI-Beta",
    "Access-Control-Max-Age": "86400",
  };
}

export default {
  async fetch(request) {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders(request) });
    }

    const url = new URL(request.url);
    const targetUrl = UPSTREAM_ORIGIN + url.pathname + url.search;

    const fwdHeaders = new Headers(request.headers);
    fwdHeaders.delete("host");

    const init = {
      method: request.method,
      headers: fwdHeaders,
      redirect: "follow",
    };
    if (request.method !== "GET" && request.method !== "HEAD") {
      init.body = request.body;
    }

    const upstream = await fetch(targetUrl, init);
    const out = new Response(upstream.body, upstream);
    for (const [k, v] of Object.entries(corsHeaders(request))) {
      out.headers.set(k, v);
    }
    return out;
  },
};
