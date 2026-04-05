# Cloudflare Worker: OpenAI-compatible proxy for browser (CORS)

Flutter **web** runs in the browser. Browsers block most cross-origin `fetch` calls to APIs like `https://api.deepseek.com` unless that API sends permissive CORS headers (DeepSeek does not for arbitrary sites). Native Android/iOS/desktop builds are **not** affected.

This worker forwards requests to `https://api.deepseek.com` with the same path and query string, and adds CORS headers so your static web app can call **your** worker URL instead.

## Security

- The client still sends `Authorization: Bearer …` through the worker; the key is visible in the browser bundle or network tab. This only fixes **CORS**, not secret exposure.
- Prefer per-user keys in settings, rate limits on the worker, and optional auth on the worker for production.

## Deploy (Cloudflare)

1. Create a Worker, paste `worker.mjs` as the module entry.
2. Deploy (e.g. `https://ai-proxy.your-account.workers.dev`).
3. In the app **Base URL** use: `https://ai-proxy.your-account.workers.dev/v1`  
   (same `/v1` suffix as direct DeepSeek OpenAI-compatible base).

## Local quick test

```bash
curl -sS -X POST "https://YOUR_WORKER/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-..." \
  -d '{"model":"deepseek-chat","messages":[{"role":"user","content":"hi"}]}'
```

If this works but the browser still fails, check the exact Base URL (must include `/v1` if your paths are `/v1/chat/completions`).
