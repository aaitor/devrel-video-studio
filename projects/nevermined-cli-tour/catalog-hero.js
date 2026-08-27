// Browser beat — nevermined.app/catalog. Run: scripts/capture.sh catalog-hero.js https://nevermined.app/catalog 1600x900
// All-forward navigation, eased scrolls, deliberate pauses (same rules as templates/hero-script.js).
async page => {
  const scrollTo = (y, dur) =>
    page.evaluate(({ y, dur }) => new Promise((res) => {
      const start = window.scrollY, delta = y - start, t0 = performance.now();
      const step = (now) => {
        const p = Math.min(1, (now - t0) / dur);
        const e = p < 0.5 ? 2*p*p : 1 - Math.pow(-2*p+2,2)/2; // easeInOutQuad
        window.scrollTo(0, start + delta*e);
        if (p < 1) requestAnimationFrame(step); else res();
      };
      requestAnimationFrame(step);
    }), { y, dur });

  await page.screencast.start({ path: 'capture.webm', size: { width: 1600, height: 900 } });
  await page.waitForTimeout(2600);          // land on the catalog
  await scrollTo(700, 2000);                // browse the grid
  await page.waitForTimeout(1400);
  await scrollTo(1500, 2200);               // keep browsing
  await page.waitForTimeout(1300);
  await scrollTo(0, 1400);                  // back to top
  await page.waitForTimeout(900);
  await page.screencast.stop();
}
