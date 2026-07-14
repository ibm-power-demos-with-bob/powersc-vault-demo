// api.js — returns the Express backend base URL.
//
// All fetch() calls for long-running routes (SSH, scan polling) must go
// directly to port 3002, bypassing the Next.js rewrite proxy which resets
// the socket on requests that take more than a few seconds (ECONNRESET).
//
// Short fast routes (<2s) continue to work fine through the proxy, but
// routing everything directly is simpler and more reliable.

export function apiBase() {
  if (typeof window === 'undefined') return 'http://localhost:3002';
  return `${window.location.protocol}//${window.location.hostname}:3002`;
}
