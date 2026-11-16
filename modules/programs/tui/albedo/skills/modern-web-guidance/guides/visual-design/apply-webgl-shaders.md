# Apply WebGL shaders to HTML content

WebGL shaders give GPU-accelerated effects such as ripple distortions, lighting models, color grading and custom vertex transformations. The HTML-in-Canvas API lets you use HTML content as a WebGL texture, so fragment and vertex shaders can run on fully interactive UI (buttons, input fields, rich text) while the content keeps native accessibility, text selection and DOM event handling.

## How to implement

1. Check that the browser supports HTML-in-Canvas:

```js
if ('content' in HTMLCanvasElement.prototype) {
  // Use the HTML-in-Canvas API.
} else {
  // Use a fallback strategy.
}
```

2. Add `content="drawable"` to the `<canvas>` element.
3. Put the HTML content inside the `<canvas>` and add the `drawable` attribute to every element you draw. A `drawable` element captures its subtree, except nested descendants that are themselves `drawable`.

```html
<canvas id="canvas" content="drawable">
  <div id="html-content" drawable></div>
</canvas>
```

4. Size the canvas grid to the device pixel ratio so the result isn't blurry:

```js
const observer = new ResizeObserver(([entry]) => {
  const dpc = entry.devicePixelContentBoxSize;
  canvas.width = dpc
    ? dpc[0].inlineSize
    : Math.round(entry.contentRect.width * window.devicePixelRatio);
  canvas.height = dpc
    ? dpc[0].blockSize
    : Math.round(entry.contentRect.height * window.devicePixelRatio);
  // Resizing clears the canvas, so request a repaint.
  canvas.requestPaint();
});

const supportsDevicePixelContentBox =
  typeof ResizeObserverEntry !== "undefined" &&
  "devicePixelContentBoxSize" in ResizeObserverEntry.prototype;
const options = supportsDevicePixelContentBox
  ? { box: "device-pixel-content-box" }
  : {};
observer.observe(canvas, options);
```

5. Pre-allocate the texture with `texImage2D()`. The snippets in this guide use a WebGL 2 context (`canvas.getContext("webgl2")`).

   Calling `texImage2D()` with `null` instead of pixel data reserves GPU memory of the given size and format without uploading pixels.
   - Size the texture from `canvas.captureElementImage(element)`. Its `width` and `height` are in canvas grid (backing store) pixels; round them up with `Math.ceil()`. `captureElementImage()` throws if the element has no paint record yet: call `requestPaint()` and retry on the next `paint` event.
   - Allocate level 0 only on the first upload or when the size changes, because reallocating clears the texture. Use mutable storage: immutable `texStorage2D()` storage can't be resized when the element changes size.

```js
// Returns the element's size in canvas grid pixels, or null if the element
// has no paint record yet.
function getElementImageSize(canvas, element) {
  let elementImage;
  try {
    elementImage = canvas.captureElementImage(element);
  } catch (err) {
    canvas.requestPaint(); // No paint record yet: retry on the next paint event.
    return null;
  }
  const width = Math.ceil(elementImage.width);
  const height = Math.ceil(elementImage.height);
  elementImage.close();
  return width > 0 && height > 0 ? { width, height } : null;
}

// Binds the texture and allocates its storage on the first upload and when
// the element size changes. `state` records the allocated size.
function allocateElementTexture(gl, texture, state, width, height) {
  gl.bindTexture(gl.TEXTURE_2D, texture);
  if (state.width === width && state.height === height) return;

  gl.texImage2D(
    gl.TEXTURE_2D,
    0,                // Mipmap level
    gl.RGBA8,         // Internal format: 8 bits per RGBA channel
    width,            // Size in canvas grid pixels
    height,
    0,                // Border: must be 0
    gl.RGBA,          // Format and type matching RGBA8
    gl.UNSIGNED_BYTE,
    null              // Reserve memory without uploading pixels
  );
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
  state.width = width;
  state.height = height;
}

const texture = gl.createTexture();
const textureState = { width: 0, height: 0 };
```

6. Render the HTML content into the texture with `texElementSubImage2D()` inside a `canvas.onpaint` handler.
   - An element can be uploaded only after the canvas has painted it. Upload from the `paint` event, and call `canvas.requestPaint()` to request one.
   - Pass `{ width, height }` in the config so the copy fills the allocated texture however the canvas is scaled.
   - Reallocate the texture if the size changed, as in step 5.

```js
// Uploads the element into the texture. Returns false if the element has no
// paint record yet; it is then uploaded on the next paint event.
function uploadElementWebGL(gl, canvas, texture, element, state) {
  const size = getElementImageSize(canvas, element);
  if (!size) return false;
  const { width, height } = size;

  // Bind, and reallocate if the size changed (step 5).
  allocateElementTexture(gl, texture, state, width, height);
  gl.texElementSubImage2D(gl.TEXTURE_2D, 0, 0, 0, element, { width, height });
  return true;
}

canvas.onpaint = () => {
  try {
    uploadElementWebGL(gl, canvas, texture, uiElement, textureState);
  } catch (err) {
    console.error('texElementSubImage2D copy failed:', err);
  }
};
```

   When a `requestAnimationFrame` loop renders the scene, call `canvas.requestPaint()` in the loop so the HTML content is rendered to the canvas. `event.changedElements` lists the elements whose rendering changed; re-upload the texture only when a descendant HTML element has changed:

```js
function render() {
  canvas.requestPaint();
  requestAnimationFrame(render);
}
requestAnimationFrame(render);

canvas.onpaint = (event) => {
  if (event.changedElements && event.changedElements.length > 0) {
    // Update the texture with uploadElementWebGL().
  }
  // Render the scene and sync the element geometry (step 7).
};
```

7. Sync the element geometry.

   Compute a `DOMMatrix` that maps the element's border box, in CSS pixels, to the canvas, in CSS pixels. The browser needs a viewport transform to map from the 3D coordinate space into CSS coordinates:
   - Normalize the HTML element. HTML elements are sized in pixels (say 200px wide), while WebGL usually treats objects as unit squares, for example from -0.5 to 0.5. Without normalizing, a 200px button appears 200 times too large. This step also flips the Y axis, because down is positive in CSS and up is positive in WebGL.
   - Convert the WebGL MVP matrix to a `DOMMatrix`.
   - Map to the canvas viewport: stretch the unit-space result back out to the CSS pixel size of the `<canvas>` on screen, and flip the Y axis back.
   - Multiply in the order Viewport × MVP × Normalization. The combined transform tells the browser exactly where the HTML element sits so it lines up with the 3D drawing. The browser performs the perspective divide.

```js
// Maps the element's border box (CSS pixels) to the canvas (CSS pixels), for a
// quad that spans -0.5 to 0.5 in model space and is drawn with the `mvp` matrix.
function computeCanvasTransform(canvas, element, mvp) {
  const width = element.offsetWidth;
  const height = element.offsetHeight;

  // 1. CSS pixels -> WebGL model space.
  const toGLModel = new DOMMatrix()
    // Scale pixels to 1 unit and flip Y (down in CSS, up in WebGL).
    .scale(1 / width, -1 / height, 1 / height)
    // Center the origin.
    .translate(-width / 2, -height / 2);

  // 2. WebGL MVP matrix as a DOMMatrix.
  const mvpDOM = new DOMMatrix(Array.from(mvp));

  // 3. Clip space -> canvas viewport, in CSS pixels.
  const clipToCanvasViewport = new DOMMatrix()
    .translate(canvas.clientWidth / 2, canvas.clientHeight / 2)
    // Scale clip space (-1..1) to the viewport and flip Y back.
    .scale(canvas.clientWidth / 2, -canvas.clientHeight / 2, canvas.clientHeight / 2);

  // 4. (clip -> pixels) * MVP * (pixels -> unit square)
  return clipToCanvasViewport.multiply(mvpDOM).multiply(toGLModel);
}
```

   Pass the transform to `canvas.updateElementGeometry()` as `canvasTransform`. This places the HTML element directly over its rendered pixels, so clicks and text selection hit the real element. The browser also uses the transform for the element's accessibility bounds, such as screen-reader focus rings:

```js
canvas.updateElementGeometry(targetHTMLElement, {
  canvasTransform: computeCanvasTransform(canvas, targetHTMLElement, htmlElementMVP),
});
```

   Hit-testing options:

- Each `updateElementGeometry()` call moves the element to the top of the hit-testing order. Pass `{ preserveHitTestOrder: true }` to keep its position.
- `canvas.clearElementGeometry(element)` removes an element from hit testing, for example when you hide it.
- `{ canvasClip }`, a `DOMRectInit` in the coordinate space of `canvasTransform`, limits the hit-testable area, for example when only part of the element is drawn.

## Example

The example sets up its own texture and `onpaint` handler, replacing the step snippets' `texture`, `textureState` and `onpaint`; take only the helper functions from the steps. Combine it with the step 4 `ResizeObserver` and, for animated scenes, the `requestAnimationFrame` loop.

```html
<canvas id="canvas" content="drawable" style="width: 400px; height: 400px;">
  <div id="ui-element" drawable>
    <p>WebGL UI Element</p>
    <button>Action</button>
  </div>
</canvas>

<script>
  const canvas = document.getElementById("canvas");
  const gl = canvas.getContext("webgl2");
  const uiElement = document.getElementById("ui-element");

  // getElementImageSize() and allocateElementTexture() are defined in step 5,
  // uploadElementWebGL() in step 6, computeCanvasTransform() in step 7.

  const texture = gl.createTexture();
  gl.bindTexture(gl.TEXTURE_2D, texture);
  const textureState = { width: 0, height: 0 };

  canvas.onpaint = () => {
    // 1. Update the texture with the HTML content.
    try {
      uploadElementWebGL(gl, canvas, texture, uiElement, textureState);
    } catch (err) {
      console.error('texElementSubImage2D copy failed:', err);
    }

    // ... Render the 3D scene here, computing htmlElementMVP ...

    // 2. Sync DOM position, hit testing and accessibility bounds with the scene.
    canvas.updateElementGeometry(uiElement, {
      canvasTransform: computeCanvasTransform(canvas, uiElement, htmlElementMVP),
    });
  };
</script>
```

## Checklist

- Check for HTML-in-Canvas support before using it.
- Add `content="drawable"` to the `<canvas>`.
- Add `drawable` to the canvas's direct children, and to every element you want to draw independently of its ancestors.
- Render the HTML content to the canvas from an `onpaint` handler.
- Pre-allocate the texture with `texImage2D()` when it is initialized and again only when the element size changes, and set `TEXTURE_MIN_FILTER` to `LINEAR`.
- Render the HTML into that texture with `texElementSubImage2D()`, sizing it from `captureElementImage()`.
- Sync the element's geometry with the rendered content through `canvas.updateElementGeometry(element, { canvasTransform })`.
- Keep the canvas sized to device pixels with a `ResizeObserver`.
- Don't put cross-origin content in the canvas; it isn't supported.
- Don't create the `ResizeObserver` inside the `onpaint` handler; that can leak memory.

## Fallback strategies

Browser support for HTML-in-canvas: Limited availability.
Supported by: Chrome 157 (Nov 2026) and Edge 157 (Nov 2026).
Unsupported in: Firefox and Safari.

Because support is limited, you usually need a fallback. Still use HTML-in-Canvas where it is supported, for its performance benefits.

The fallback depends on the use case. For interactive HTML content in a canvas, for example, place the HTML over the canvas with CSS when HTML-in-Canvas is unsupported.

### HTML-in-Canvas polyfill

The `three-html-render` library mimics the HTML-in-Canvas API in browsers that lack it.

1. Install it from npm (`npm install three-html-render`) or load it from a CDN:

```html
<script src="https://cdn.jsdelivr.net/npm/three-html-render/dist/polyfill.js"></script>
```

2. Call `installHtmlInCanvasPolyfill()` to provide the HTML-in-Canvas API.
