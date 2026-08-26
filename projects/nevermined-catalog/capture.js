// Nevermined Catalog walkthrough — playwright-cli run-code hero script.
// All-forward navigation so page.screencast survives same-tab route changes.
async page => {
  const scrollTo = (y, dur) =>
    page.evaluate(
      ({ y, dur }) =>
        new Promise((res) => {
          const start = window.scrollY, delta = y - start, t0 = performance.now();
          const step = (now) => {
            const p = Math.min(1, (now - t0) / dur);
            const e = p < 0.5 ? 2 * p * p : 1 - Math.pow(-2 * p + 2, 2) / 2; // easeInOutQuad
            window.scrollTo(0, start + delta * e);
            if (p < 1) requestAnimationFrame(step); else res();
          };
          requestAnimationFrame(step);
        }),
      { y, dur }
    );

  await page.screencast.start({ path: 'capture.webm', size: { width: 1600, height: 900 } });

  // Chapter 1 — Browse the catalog
  await page.waitForTimeout(2600);        // hold on hero
  await scrollTo(660, 1900);              // peek the featured services
  await page.waitForTimeout(1400);
  await scrollTo(0, 1100);               // back to top (reveal the sidebar)
  await page.waitForTimeout(700);

  // Chapter 2 — Filter by category
  await page.getByRole('link', { name: /Crypto & Blockchain/ }).first().click();
  await page.waitForURL(/category=Crypto/, { timeout: 15000 });
  await page.waitForTimeout(1900);
  await scrollTo(720, 2600);             // browse the filtered grid
  await page.waitForTimeout(1300);

  // Chapter 3 — View a service
  const svc = page.locator('a[href="/catalog/ai-agent-oracle"]').first();
  if (await svc.count()) await svc.click();
  else await page.locator('article a[href^="/catalog/"]').first().click();
  await page.waitForURL(/\/catalog\/[a-z0-9-]+\/?$/, { timeout: 15000 });
  await page.waitForTimeout(2200);       // let the detail settle
  await scrollTo(1150, 3200);            // scroll through the details
  await page.waitForTimeout(1300);

  await page.screencast.stop();
}
