// instrumentation.js — Next.js instrumentation hook
// Catches and suppresses transient socket drop errors (ECONNRESET, EPIPE, ECONNABORTED)
// common on TechZone Power VMs so they do not crash the Next.js process.

export async function register() {
  if (process.env.NEXT_RUNTIME === 'nodejs') {
    const ignoredCodes = ['ECONNRESET', 'EPIPE', 'ECONNABORTED'];
    process.on('uncaughtException', (err) => {
      if (err && err.code && ignoredCodes.includes(err.code)) {
        console.warn(`[instrumentation] Suppressed transient socket error: ${err.code}`);
        return;
      }
      console.error('[instrumentation] Uncaught exception:', err);
    });

    process.on('unhandledRejection', (reason) => {
      console.error('[instrumentation] Unhandled rejection:', reason);
    });
  }
}
