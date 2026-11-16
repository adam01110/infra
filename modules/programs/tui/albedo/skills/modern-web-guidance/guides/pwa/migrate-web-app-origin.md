# Migrating the origin of an installed web app

Moving an installed web app (PWA) to a new origin normally means users
uninstall the old app and reinstall the new one by hand, which loses OS-level
integration such as taskbar shortcuts and notification permissions. Web App
Origin Migration automates moving the installation through a verified
handover: the new site claims the old site as its predecessor, and the old
site authorizes the new site as its successor.

Only the installation migrates (shortcuts, home screen icons). User data
(LocalStorage, IndexedDB, cookies) and browser permissions (notifications,
geolocation) belong to the origin and are not transferred, so they are lost
just as in a manual reinstall. Migrate data
separately, through cross-origin messaging or server-side synchronization.

## Implementation steps

### 1. Confirm the origins are same-site

The old and new origins must be same-site, meaning they share a registrable
domain (eTLD+1).

* Allowed: `app.example.com` to `new.example.com` (both `example.com`).
* Allowed: `example.com/app1` to `example.com/app2`.
* Not allowed: `example.com` to `example.org` (different registrable domains).

### 2. Declare the predecessor in the new app

The new app must have an `id`. In the new site's `manifest.json`, add
`migrate_from`. In this example the manifest is served from
`https://new-app.example.com`, so its relative `id` resolves to the manifest ID
`https://new-app.example.com/demo.html`, which steps 3 and 4 use:

```json
{
  "name": "My New App",
  "id": "/demo.html",
  "start_url": "/demo.html",
  "migrate_from": [
    {
      "id": "https://old-app.example.com/"
    }
  ]
}
```

### 3. Authorize the migration on the old origin

The old origin must explicitly authorize the migration, which prevents origin
hijacking. Serve this file at
`https://old-app.example.com/.well-known/web-app-origin-association`:

```json
{
  "https://new-app.example.com/demo.html": {
    "allow_migration": true
  }
}
```

### 4. Optionally signal the migration from the old app

To let the browser discover the migration from the old installation, without
waiting for users to visit the new site, add `migrate_to` to the old site's
`manifest.json`. Set its `id` to the new app's manifest ID:

```json
{
  "migrate_to": {
    "id": "https://new-app.example.com/demo.html",
    "install_url": "https://new-app.example.com/demo.html"
  }
}
```

### 5. Optionally require the migration

By default the browser suggests the migration to users. To make it mandatory,
set `behavior` to `force` in the new app's manifest:

```json
{
  "migrate_from": [
    {
      "id": "https://old-app.example.com/",
      "behavior": "force"
    }
  ]
}
```

`"force"` does not silently delete the old app. The browser shows a dialog in
which the user must either choose "Update" to move to the new version or
"Remove" to remove the app entirely.

## Fallbacks and browser support

Browser support for Web app origin migration: Limited availability.
Supported by: Chrome 149 (Jun 2026) and Edge 149 (Jun 2026).
Unsupported in: Firefox and Safari.

### Manual reinstallation prompt

In browsers without automatic migration, users stay on the old installation:
their settings are not migrated and the old app is not uninstalled
automatically. Add a UI element on the old origin, such as a notification
banner, that directs users to the new site.
