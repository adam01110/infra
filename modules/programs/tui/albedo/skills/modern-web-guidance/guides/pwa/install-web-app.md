# Installing web applications

The Web Install API gives users an explicit, in-page way to install a web app,
through either the HTML `<install>` element or the JavaScript
`navigator.install()` method. Installation always completes through
browser-controlled consent UI, so a site cannot install an app silently.

## Choose between `<install>` and `navigator.install()`

`<install>` element:

* The browser provides the control, so the installation experience is
  consistent and trustworthy.
* Installing another app shows no separate permission prompt before the
  installation confirmation dialog.
* No JavaScript is needed to trigger installation.
* Visual customization of the button is restricted.
* User-agent anti-spam limits cap how many `<install>` elements a page can
  have, so `navigator.install()` fits large app catalogs better.

`navigator.install()` method:

* The installation UI can be fully customized to match the site.
* The browser does not limit how many installation UI elements a page has.
* Requires JavaScript to trigger installation.
* Installing another app first shows a `web-app-installation` permission
  prompt, then the installation confirmation dialog.

## Prepare the web app

The app being installed needs a web app manifest. Give the manifest a stable
`id` so the browser can keep the app's identity separate from its launch URL.
To install the current app, link the manifest from the document; the
no-argument install APIs use the current document's manifest.

```html
<link rel="manifest" href="/manifest.webmanifest">
```

```json
{
  "id": "/",
  "name": "Example application",
  "short_name": "Example",
  "start_url": "/",
  "display": "standalone",
  "icons": [
    {
      "src": "/icons/app-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icons/app-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

Keep the manifest URL stable. Requirements:

* Current-document installation: the manifest must explicitly declare an `id`
  that is same-origin with the document.
* Offering a different app by manifest URL: the manifest must be reachable over
  HTTPS without credentials or redirects (CORS headers are not required), must
  return a JSON MIME `Content-Type` such as `application/manifest+json`, and
  must share the origin of that app's `start_url`.

## Use the HTML `<install>` element

`<install>` renders a user-agent-controlled button. Prefer it when the
browser's standard label and presentation are acceptable, because a
browser-owned control is a trustworthy installation affordance.

With no attributes it installs the current document's linked web app:

```html
<install></install>
```

To offer another web app, including a cross-origin app from an app catalog or
suite launcher, give its manifest URL. The manifest URL and its `start_url`
must share an origin, and the manifest must be reachable without credentials or
redirects and return a JSON MIME `Content-Type`:

```html
<install manifest="https://app.example/manifest.webmanifest"></install>
```

Prefer an explicit, stable `id` in the target manifest. If the target manifest
has no `id`, you must supply its computed manifest ID in the `manifestid`
attribute so the browser can verify the expected app identity.

```html
<install
  manifest="https://app.example/manifest.webmanifest"
  manifestid="https://app.example/"
></install>
```

When a manifest omits `id`, the browser computes a fallback ID by resolving the
manifest's `start_url` against the manifest URL (not the installing page) and
stripping any URL fragment while keeping query parameters. For example, a
manifest at `https://app.example/catalog/manifest.webmanifest` with no `id` and
`"start_url": "../launch?source=catalog"` has the computed ID
`https://app.example/launch?source=catalog`. `manifestid` only checks that
computed identity. It does not override the manifest, and it does not keep the
identity stable if `start_url` changes later.

`manifestid` may be absolute or relative. A relative value is resolved against
the installing document's base URL, and the result must match the target
manifest's processed ID.

Do not imitate, overlay, or transform the browser-controlled element. Its
presentation and activation restrictions protect users from deceptive
installation prompts.

### Handle `<install>` results

Listen for the `installresult` event and read `event.result`:

* `"success"`: the app was installed, or the user approved an action (such as
  opening) for an already-installed app. The page cannot tell these apart.
* `"aborted"`: the user canceled, or a browser condition stopped the
  installation from completing.
* `"invalid-data"`: the `manifest` or `manifestid` attribute value, the
  manifest response, or required manifest fields are invalid.

```html
<install></install>
<p id="install-status" role="status"></p>

<script type="module">
  const installButton = document.querySelector("install");
  const installStatus = document.querySelector("#install-status");

  installButton.addEventListener("installresult", (event) => {
    switch (event.result) {
      case "success":
        installStatus.textContent = "The app was installed or opened.";
        break;
      case "aborted":
        installStatus.textContent =
          "Installation was canceled or could not complete.";
        break;
      case "invalid-data":
        installStatus.textContent =
          "Installation could not start because the app data is invalid.";
        break;
    }
  });
</script>
```

## Use the JavaScript `navigator.install()` method

Use `navigator.install()` when you need custom page UI. It requires a secure
context (HTTPS) and transient user activation, so call it directly from the
click handler: a delayed call loses the activation. Keep the button hidden
until a supported installation mechanism is available.

```html
<button id="install-app" type="button" hidden>Install app</button>
<p id="install-status" role="status"></p>

<script type="module">
  const installButton = document.querySelector("#install-app");
  const installStatus = document.querySelector("#install-status");
  const supportsWebInstall =
    typeof Navigator.prototype.install === "function";

  if (supportsWebInstall) {
    installButton.hidden = false;
  }

  installButton.addEventListener("click", async () => {
    if (installButton.getAttribute("aria-disabled") === "true") {
      return;
    }
    // aria-disabled instead of disabled, so the button keeps focus.
    installButton.setAttribute("aria-disabled", "true");

    try {
      await navigator.install();
      installStatus.textContent = "The app was installed or opened.";
      installButton.hidden = true;
    } catch (error) {
      if (error.name === "AbortError") {
        // Cancellation is an expected choice; keep the button for a retry.
        installStatus.textContent =
          "Installation was canceled or could not complete.";
      } else {
        installStatus.textContent = "Installation could not start.";
        // Surfaces invalid manifests and platform failures to developers.
        console.error(error);
      }
    } finally {
      installButton.removeAttribute("aria-disabled");
    }
  });
</script>
```

With no arguments, `navigator.install()` installs the current document's linked
app, and the manifest must declare an `id`.

To offer another app, including a cross-origin one, pass its manifest URL. The
manifest URL and its `start_url` must share an origin, and the manifest must be
served over HTTPS with a JSON MIME `Content-Type`:

```js
await navigator.install({
  manifest: "https://app.example/manifest.webmanifest",
});
```

Prefer an explicit, stable `id` in the target manifest. If it has no `id`, also
pass the target app's computed manifest ID (`start_url` resolved against the
manifest URL, without the fragment) so the browser can verify the expected
identity:

```js
await navigator.install({
  manifest: "https://app.example/manifest.webmanifest",
  manifestId: "https://app.example/",
});
```

`manifestId` may be absolute or relative. A relative value is resolved against
the installing document's base URL, and the result must match the target
manifest's processed ID.

### Handle `navigator.install()` results

The promise resolves when installation completes or when the user approves an
action (such as opening) for an already-installed app; the page cannot tell
these apart. It rejects with:

* `AbortError`: the user aborted; permission was denied; the environment does
  not support installation; several installation attempts ran concurrently; or
  the page navigated during installation.
* `DataError`: missing linked manifest; invalid or unreachable manifest URL,
  a redirect, or a non-JSON `Content-Type`; missing required manifest fields,
  or a `start_url` not same-origin with the manifest; the manifest omits `id`
  and no `manifestId` was given, or `manifestId` does not match the manifest's
  processed ID.
* `NotAllowedError`: no transient user activation.
* `TypeError`: an options argument omits `manifest`, or `manifest` or
  `manifestId` is empty or cannot be parsed as a URL.
* `InvalidStateError`: called from a detached document, a subframe, or a fenced
  frame.
* `SecurityError`: the `web-app-installation` Permissions Policy is disabled,
  or the document is sandboxed.

## Fallback strategies

The Web Install API is a progressive enhancement. Browsers without either entry
point still offer their own installation UI when they support installing web
apps.

### Web app manifest fallback

Browser support for Web app manifest: Limited availability.
Supported by: Chrome 53 (Aug 2016), Edge 79 (Jan 2020), Safari 17 (Sep 2023), and Safari iOS 15.4 (Mar 2022).
Unsupported in: Firefox.

Browsers that do not use web app manifests still show the app as a normal
website. Treat installation and standalone display as enhancements, and keep
core functionality available when manifest-based installation is not.

### `<install>` fallback

`<install>` is not natively supported by any major browser yet.

`<install>` renders its child content in browsers that do not provide the
browser-controlled button. When the product has a maintained installation help
page, link to it from the child content:

```html
<install>
  <a href="/install-help">How to install this app</a>
</install>
```

If browser-specific instructions would be inaccurate or hard to maintain, leave
the element empty, so unsupported browsers render no non-functional
replacement.

Render a custom install button separately, with `hidden`, and reveal it only
when `navigator.install()` is supported or a `beforeinstallprompt` event has
been captured. Do not put an always-visible imitation of the browser-controlled
button in the fallback content.

### `navigator.install()` fallback

`navigator.install()` is not natively supported by any major browser yet.

Where it is unavailable, use the `beforeinstallprompt` event to install the
current app. Unlike `navigator.install()`, this event cannot install a
different app.

### `beforeinstallprompt` fallback

Browser support for beforeinstallprompt: Limited availability.
Supported by: Chrome 76 (Jul 2019) and Edge 79 (Jan 2020).
Unsupported in: Firefox and Safari.

Capture the event, prevent its automatic prompt, and reveal the custom button
only after the browser has confirmed that prompting is possible. Use one click
handler that calls `navigator.install()` when available and otherwise uses the
captured event. The event is single-use, so discard it before awaiting the
user's choice, and hide the button unless a new `beforeinstallprompt` event
fires. This handler replaces the one in the `navigator.install()` example; use
it with the same button and status markup.

```js
const installButton = document.querySelector("#install-app");
const installStatus = document.querySelector("#install-status");
const supportsWebInstall =
  typeof Navigator.prototype.install === "function";
let deferredInstallPrompt;

if (supportsWebInstall) {
  installButton.hidden = false;
}

window.addEventListener("beforeinstallprompt", (event) => {
  event.preventDefault();
  deferredInstallPrompt = event;

  // navigator.install() wins when both mechanisms are available.
  if (!supportsWebInstall) {
    installButton.hidden = false;
  }
});

installButton.addEventListener("click", async () => {
  if (installButton.getAttribute("aria-disabled") === "true") {
    return;
  }
  // aria-disabled instead of disabled, so the button keeps focus.
  installButton.setAttribute("aria-disabled", "true");

  try {
    if (supportsWebInstall) {
      // Called directly from the handler to keep transient user activation.
      await navigator.install();
      installStatus.textContent = "The app was installed or opened.";
      installButton.hidden = true;
    } else if (deferredInstallPrompt) {
      // Clear the single-use event before awaiting the user's choice.
      const promptEvent = deferredInstallPrompt;
      deferredInstallPrompt = undefined;
      await promptEvent.prompt();
      const { outcome } = await promptEvent.userChoice;

      installStatus.textContent =
        outcome === "accepted"
          ? "The app was installed."
          : "Installation canceled.";
      if (!deferredInstallPrompt) {
        installButton.hidden = true;
      }
    }
  } catch (error) {
    if (error.name === "AbortError") {
      // Cancellation is an expected choice; keep the button for a retry.
      installStatus.textContent =
        "Installation was canceled or could not complete.";
    } else {
      installStatus.textContent = "Installation could not start.";
      console.error(error);
    }
  } finally {
    installButton.removeAttribute("aria-disabled");
  }
});
```

In browsers that support neither mechanism, keep the button hidden rather than
showing one that does nothing; users can still use their browser's own
installation affordance. Do not replace the hidden button with browser-specific
step-by-step instructions unless the product has a tested, maintained
onboarding flow for those browsers.
