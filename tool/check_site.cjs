const { chromium } = require('playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const origin = process.env.SITE_ORIGIN || 'http://127.0.0.1:8080';
(async () => {
  const browser = await chromium.launch({headless:true});
  fs.mkdirSync('/tmp/mynust-site-check', {recursive:true});
  let checked = 0;
  for (const width of [375, 768, 1440]) {
    for (const colorScheme of ['light', 'dark']) {
      const page = await browser.newPage({viewport:{width,height:1000},colorScheme,reducedMotion:'reduce'});
      const errors = [];
      page.on('pageerror', e => errors.push(e.message));
      for (const route of ['/', '/privacy/', '/terms/']) {
        const response = await page.goto(origin + route);
        assert.equal(response.status(), 200);
        assert.equal(await page.locator('h1').count(), 1);
        for (const image of await page.locator('img').all()) {
          await image.scrollIntoViewIfNeeded();
          await image.evaluate(i => i.complete ? Promise.resolve() : new Promise((resolve, reject) => {
            i.onload = resolve; i.onerror = reject;
          }));
        }
        assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
        assert.equal(await page.locator('img').evaluateAll(images => images.every(i => i.complete && i.naturalWidth > 0)), true);
        for (const href of await page.locator('a[href^="/"]').evaluateAll(links => links.map(a => a.getAttribute('href')))) {
          assert.equal((await page.request.get(origin + href)).status(), 200);
        }
        assert.equal(errors.length, 0);
        checked++;
      }
      await page.goto(origin + '/');
      await page.screenshot({path:`/tmp/mynust-site-check/${width}-${colorScheme}.png`,fullPage:true});
      await page.close();
    }
  }
  await browser.close();
  console.log(`${checked} page/viewport/theme checks passed.`);
})().catch(error => { console.error(error); process.exit(1); });
