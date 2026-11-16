# Web Privacy Guidelines for Developers

Treat privacy as an architectural requirement, not a legal compliance checkbox. The web is moving away from passive tracking toward explicit, user-consented interactions, and privacy-preserving applications earn user trust and are more secure.

## Principles

1. **Avoid privacy labor and automation asymmetry.** Do not shift the work of protecting privacy onto the user (privacy labor), and do not overwhelm users with complex consent dialogs (automation asymmetry). Users have limited time and attention, so pushing privacy choices onto them is often ineffective and causes fatigue. Make the system privacy-protective by default.
2. **Data minimization.** "If you don't have the data, you can't lose it." Collect only the minimum the immediate task needs. Storing less reduces breach risk and builds trust.
3. **Purpose limitation.** Data collected for one purpose is not used for another without fresh consent. Repurposing data without explicit agreement breaks the user's trust.
4. **Transparency by default.** State clearly why data is collected, where it goes, and how long it is kept. Transparency builds trust and can set your application apart.
5. **Trustworthy agency.** Your application acts on the user's behalf: protect them from intrusive behavior and unnecessary data exposure, and serve their interests as a loyal fiduciary rather than serving third parties.

## 1. Data minimization and purpose limitation

Collecting less data and limiting its use is the most effective way to protect privacy.

- Collect data at the lowest granularity you need. If you only need an age bracket (such as 18-34), ask for the bracket, not the date of birth.
- Offer guest checkout in e-commerce instead of forcing account creation. It reduces data collection and cart abandonment.
- Delete data as soon as the purpose it was collected for is fulfilled.
- For aggregate statistics, fuzz the data or add noise (differential privacy).
- Do not collect data speculatively, "just in case" it becomes useful later.
- Do not reuse data collected for one purpose (such as security verification) for another (such as marketing) without explicit consent.

Ask for a bracket instead of an exact age:

```html
<label for="age-bracket">Age bracket:</label>
<select id="age-bracket" name="age-bracket">
  <option value="18-34">18-34</option>
  <option value="35-49">35-49</option>
  <option value="50+">50+</option>
</select>
```

## 2. Transparency and trust

Be open about data practices and give users easy ways to control their data.

- Explain why each piece of data is requested, inline, directly next to the input field. Explanations buried in a long, complex privacy policy do not serve this purpose.
- Before requesting a powerful browser permission (such as camera or location), give the user the reason and context.
- Where supported, consider a Page Embedded Permission Control (PEPC) element. It makes permission requests declarative and user-initiated, and it acts as a data mediator: the element can hand over the data itself instead of only granting permission. The generic `<permission type="...">` element only ran as an origin trial (Chrome 126 to 143) and has been replaced by capability-specific elements such as `<geolocation>`, available from Chrome 144. Browsers that do not support an element render its children instead, so put the fallback inside it.
- Send the `Clear-Site-Data` header when a user logs out so no data lingers in the browser.
- Make opting out or deleting an account as easy as signing up.
- Do not use deceptive (dark) patterns to trick users into consenting.

Inline explanation:

```html
<div>
  <label for="phone">Phone number (optional)</label>
  <input id="phone" type="tel" name="phone">
  <a href="#phone-help">Why do we ask for this?</a>
  <aside id="phone-help">
    We only use your phone number to send two-factor authentication codes for account security.
  </aside>
</div>
```

`Clear-Site-Data` on logout:

```http
HTTP/1.1 200 OK
Clear-Site-Data: "*"
```

When the header clears the cache, do not send it on the main navigation response: on slow devices it can block UI rendering. Trigger it from a subresource request instead.

`<geolocation>` element with a fallback button that uses the Geolocation API:

```html
<geolocation onlocation="handleLocation(event)">
  <button onclick="navigator.geolocation.getCurrentPosition(updateMap)">
    Use my location
  </button>
</geolocation>

<script>
function handleLocation(event) {
  // The element exposes a GeolocationPosition or a GeolocationPositionError.
  if (event.target.position) {
    updateMap(event.target.position);
  } else if (event.target.error) {
    console.error(event.target.error.message);
  }
}
</script>
```

Other attributes: `autolocate` fetches the location on load, but only when permission is already granted, so it never prompts unexpectedly; `accuracymode="precise"` or `"approximate"` maps to `enableHighAccuracy`; `watch` fires continuously, like `watchPosition()`.

## 3. Security and data handling

Privacy depends on secure code. Application vulnerabilities and insecure storage lead directly to privacy violations.

- Scrub personally identifiable information (PII) from application logs, with automated masking for emails, tokens, and IDs.
- Set `HttpOnly` on cookies that hold session identifiers so scripts cannot read them.
- Rate-limit sensitive endpoints (such as user search or profile views) to prevent bulk scraping.
- For 1:1 embeds that do not share state across top-level sites, use CHIPS (Cookies Having Independent Partitioned State) by adding the `Partitioned` attribute.
- Do not store sensitive tokens or PII in `localStorage`: any script embedded in the page can read it.
- Do not rely on unpartitioned `SameSite=None` cookies: browsers restrict third-party cookies, so they may not be sent in cross-site contexts.

Session cookie:

```http
Set-Cookie: session_id=xyz123; Secure; HttpOnly; SameSite=Lax
```

CHIPS cookie:

```http
Set-Cookie: theme_pref=dark; SameSite=None; Secure; Path=/; Partitioned; HttpOnly
```

## 4. Third parties

Third-party scripts and resources are a common source of privacy leaks, and you are responsible for the third parties you include.

- Audit network requests regularly with DevTools or HAR files to see what data third parties collect.
- Do not assume a third party is privacy-safe because it is popular.
- Use the facade pattern for heavy embeds (such as YouTube or TikTok): show a static thumbnail and load the interactive iframe only after the user clicks.
- Use privacy-preserving embed options when available, such as `youtube-nocookie.com`.
- Replace heavy social sharing SDKs with static HTML links that do not track users.
- Use the Federated Credential Management API (FedCM) to mediate sign-in flows in the browser. It prevents the identity provider (IdP) from tracking relying parties before the user consents.
- Do not load third-party scripts on pages that handle sensitive data (such as checkout or health information) unless strictly necessary.

Social sharing without an SDK:

```html
<a href="https://x.com/intent/tweet?text=Check%20this%20out&url=https%3A%2F%2Fexample.com"
   rel="noopener" target="_blank">
  Share on X
</a>
```

Video facade:

```html
<div id="video-container" data-video-id="abc123">
  <button type="button" id="play-btn">
    <img src="https://img.youtube.com/vi/abc123/maxresdefault.jpg" alt="Play video">
  </button>
</div>

<script>
document.getElementById('play-btn').addEventListener('click', () => {
  const container = document.getElementById('video-container');
  const videoId = container.dataset.videoId;
  container.innerHTML = `<iframe src="https://www.youtube-nocookie.com/embed/${videoId}?autoplay=1" title="YouTube video" allow="autoplay; encrypted-media; picture-in-picture" allowfullscreen></iframe>`;
  // Replacing the button drops keyboard focus; move it to the player.
  container.querySelector('iframe').focus();
});
</script>
```

FedCM sign-in. Pass the nonce inside `params`: Chrome 143 and 144 accept both forms during a transition period, and Chrome 145 drops the top-level `nonce`. The IdP's ID assertion endpoint then receives the nonce inside `params` too.

```javascript
async function signIn() {
  try {
    const credential = await navigator.credentials.get({
      identity: {
        providers: [{
          configURL: "https://idp.example/fedcm.json",
          clientId: "rp-client-id-123",
          params: { nonce: "a_secure_random_nonce_value" }
        }]
      }
    });
    authenticateWithBackend(credential.token);
  } catch (error) {
    // Handle FedCM sign-in failure.
  }
}
```

## 5. Privacy headers

Use standard HTTP headers to have the browser enforce privacy boundaries.

- Use `Permissions-Policy` to disable powerful features (such as camera, microphone, and geolocation) by default and enable them only where required.
- Set a strict `Referrer-Policy` so sensitive URL parameters do not leak to third parties. `strict-origin-when-cross-origin` is the browser default, so setting it explicitly guards against older defaults and overrides; `same-origin` or `no-referrer` are stricter.

```http
Referrer-Policy: strict-origin-when-cross-origin
```

This policy disables the listed features for all origins, including your own. On pages that need a feature, allow it for your origin, for example `geolocation=(self)`:

```http
Permissions-Policy: geolocation=(), camera=(), microphone=(), accelerometer=()
```

## 6. Fingerprinting and User-Agent reduction

Do not covertly identify users from their device configuration. Fingerprinting removes user control: it relies on characteristics that do not change and happens invisibly, so users cannot opt out or clear the identifier.

- Do not build a device fingerprint from canvas rendering, font lists, or audio/video device enumeration.
- Use feature detection, not User-Agent sniffing, to check whether the browser supports a capability.
- Do not rely on the full detail of the traditional `navigator.userAgent` string. When you need specific device targeting, use User-Agent Client Hints (UA-CH) where the browser supports them.

Feature detection:

```javascript
if ('IntersectionObserver' in window) {
  const observer = new IntersectionObserver(onIntersect);
} else {
  // Fallback.
}

// Avoid UA sniffing such as: navigator.userAgent.includes("Chrome/100")
```

User-Agent Client Hints:

```javascript
if (navigator.userAgentData) {
  navigator.userAgentData.getHighEntropyValues(["platformVersion", "architecture"])
    .then(ua => {
      console.log(ua.platformVersion);
    });
}
```

## 7. Data rights and user control

Let users exercise their rights over their personal data.

- Give users a clear way to access all the data you have collected about them.
- Provide automated or easy manual flows for data deletion (erasure). If sign-up was automated, do not make deletion harder or require contacting support.
- Let users correct inaccurate information associated with their identity.
- Do not retaliate against users who exercise their data rights by denying them access to services that do not depend on that data.
