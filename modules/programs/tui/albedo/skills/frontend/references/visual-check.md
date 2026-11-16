# Visual check recipe

Run these steps in python cells with the albedo browser binding
(`await api_docs.read("browser")` has the full API). Every call here was tested
in this harness.

- Serve the page the way the project does, and collect uncaught errors and
  console errors while it loads. A dev server prints its local address; a
  standalone prototype can open as a `file://` URL, but one that uses ES
  modules or `fetch` needs a server, such as
  `run("python3", "-u", "-m", "http.server", "8000", "--bind", "127.0.0.1", cwd=dir)`
  (`-u` makes it print its address unbuffered). For a plain `file://` page, set
  `url = Path(file).resolve().as_uri()` and skip the `run` lines below.

  ```python
  job = run("pnpm", "run", "dev")  # Or npm, yarn, or bun, per the lockfile.
  url_re = r"https?://(?:localhost|127\.0\.0\.1|\[::1\]):\d+[^\s)\"'>]*"
  url = re.search(url_re, await job.wait_for(re.compile(url_re), timeout=60)).group()
  b = await browser.spawn()
  page = await b.new_page()
  async with page.events("Runtime.exceptionThrown") as exc, \
          page.events("Runtime.consoleAPICalled") as con:
      await page.goto(url)
      await asyncio.sleep(0.5)
      print("errors:", [e["exceptionDetails"].get("exception", {}).get(
          "description", e["exceptionDetails"]["text"]) for e in exc.drain()])
      print("console:", [" ".join(str(a.get("value", a.get("description")))
          for a in c["args"]) for c in con.drain() if c["type"] == "error"])
  ```

  Fix errors the change caused before going on.

- Screenshot each width and look at it, then check overflow at 320 wide:

  ```python
  async def size(w, h):
      await page.cdp.send("Emulation.setDeviceMetricsOverride", {
          "width": w, "height": h, "deviceScaleFactor": 1, "mobile": w < 768,
      })
      # Let fonts, layout, and entrance motion settle before capturing.
      await page.evaluate("document.fonts.ready.then(() => true)")
      await asyncio.sleep(0.5)

  # Add (820, 1180) when the layout changes there.
  for w, h in [(1440, 900), (390, 844)]:
      await size(w, h)
      show_image(await page.screenshot())
  await size(320, 640)
  print("overflow at 320:", await page.evaluate("""(() => {
    const bad = [...document.querySelectorAll("body *")].filter(e => {
      const r = e.getBoundingClientRect();
      if (r.width <= 1 || r.height <= 1 || r.right <= 0) return false;
      if (r.right <= 321 && r.left >= -1) return false;
      for (let a = e; a && a !== document.body; a = a.parentElement) {
        const s = getComputedStyle(a);
        if (s.position === "fixed" || s.visibility === "hidden") return false;
        if (a !== e && s.overflowX !== "visible") return false;
      }
      return true;
    });
    const cls = e => (e.getAttribute("class") || "").trim().split(/\\s+/)[0];
    const name = e => e.tagName.toLowerCase() + (e.id ? "#" + e.id : "") +
      (cls(e) ? "." + cls(e) : "");
    return {count: bad.length, total: document.querySelectorAll("body *").length,
            first: bad.slice(0, 5).map(name)};
  })()"""))
  ```

  The check counts visible elements that extend past either edge of the
  emulated width, including overflow that `overflow-x: hidden` on the body only
  hides. It skips fixed off-canvas panels such as a closed drawer, content
  inside its own scroll or clip container such as a wide table, and
  screen-reader-only text, because those do not widen the page. `innerWidth`
  cannot be trusted here, since mobile emulation widens the layout viewport to
  fit wide content. Fix the listed elements and rerun until the count is 0; a
  count close to the total means the page has no viewport meta tag.

  Screenshots cover the viewport; scroll with `await page.scroll(dy=800)` to see
  more of a long page. Use `page.screenshot(full_page=True)` only on short
  pages, since `show_image` rejects images over 5 MiB, and split shots across
  cells past four, the per-cell limit.

- Reset to desktop with `await size(1440, 900)`. Press `await page.press("Tab")`
  until focus reaches a main control, checking where it is with
  `await page.evaluate("document.activeElement.outerHTML.slice(0, 120)")`; the
  control should show a clearly visible focus style. Then open one interactive
  state, for example with `await page.click_text("...")`, and
  `show_image(await page.screenshot())` again.

- For pages with motion or theme support, check each preference on its own.
  Media features apply to the next load, so reload after setting one:

  ```python
  for feature in [
      {"name": "prefers-reduced-motion", "value": "reduce"},
      # Use "light" when the page defaults to dark.
      {"name": "prefers-color-scheme", "value": "dark"},
  ]:
      await page.cdp.send("Emulation.setEmulatedMedia", {"features": [feature]})
      await page.goto(url)
      await size(1440, 900)
      show_image(await page.screenshot())
  await page.cdp.send("Emulation.setEmulatedMedia", {"features": []})
  ```

  With reduced motion, content and state changes stay visible without the
  movement.

- Finish with `await b.close()` and, if you started a server,
  `await job.stop()`, also when a step fails partway.
