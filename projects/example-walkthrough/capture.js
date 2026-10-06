// playwright-cli hero script for the example-walkthrough — a silent tour of the public RealWorld
// demo app (demo.realworld.io: no login, no PII). Run via scripts/capture.sh. The selectors below are a
// STARTING POINT — confirm them in the Explore step (SKILL §2) before recording; each beat has a fallback.
// Conduit uses hash routing (#/, #/article/<slug>), so a tag filter updates the feed in place (no URL change).
async page => {
  const scrollTo = (y, dur) =>
    page.evaluate(({ y, dur }) => new Promise((res) => {
      const start = window.scrollY, delta = y - start, t0 = performance.now();
      const step = (now) => {
        const p = Math.min(1, (now - t0) / dur);
        const e = p < 0.5 ? 2 * p * p : 1 - Math.pow(-2 * p + 2, 2) / 2; // easeInOutQuad
        window.scrollTo(0, start + delta * e);
        if (p < 1) requestAnimationFrame(step); else res();
      };
      requestAnimationFrame(step);
    }), { y, dur });

  await page.screencast.start({ path: 'capture.webm', size: { width: 1600, height: 900 } });

  // ── Beat 1 — the global feed (t≈0) ─────────────────────────────────
  await page.waitForTimeout(2600);          // hold on the landing state
  await scrollTo(660, 1900);                // reveal the article list
  await page.waitForTimeout(1400);
  await scrollTo(0, 1100);
  await page.waitForTimeout(700);

  // ── Beat 2 — filter by a popular tag (t≈7.5) — feed updates in place, no URL change ──
  {
    const tag = page.locator('.sidebar a.tag-pill, .tag-list a.tag-pill').first();
    if (await tag.count()) await tag.click();
    else await page.getByRole('link').filter({ hasText: /\w/ }).nth(4).click(); // fallback: a sidebar tag
  }
  await page.waitForTimeout(2200);
  await scrollTo(520, 1800);
  await page.waitForTimeout(1200);

  // ── Beat 3 — open an article (t≈13.8) — hash becomes #/article/<slug> ──
  {
    const art = page.locator('.article-preview a.preview-link, a.preview-link').first();
    if (await art.count()) await art.click();
    else await page.locator('a[href*="#/article/"]').first().click();
    await page.waitForURL(/#\/article\//, { timeout: 15000 }).catch(() => {}); // tolerate hash-route quirks
  }
  await page.waitForTimeout(2200);
  await scrollTo(1100, 3000);               // scroll through the article body
  await page.waitForTimeout(1300);

  await page.screencast.stop();
}
