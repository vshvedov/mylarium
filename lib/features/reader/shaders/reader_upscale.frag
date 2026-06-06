#version 460 core
#include <flutter/runtime_effect.glsl>

// High-quality page sampler for the reader. When a page is drawn larger than its
// native size (pinch-zoom), the engine's default sampler (bilinear on Impeller)
// produces a soft, blurry upscale. This replaces it with a Lanczos-3 kernel
// (windowed sinc, 36 taps): sharper than bicubic, the family Komga clients use.
// It invents no detail - it just stops throwing sharpness away.
//
// Cost is bounded by the on-screen area (only covered fragments run), so it is
// fine even for a full page. Derivative-based up/down-scale gating (fwidth) is
// avoided on purpose: it is unsupported by the SkSL backend and would make the
// shader fail to compile there.

precision highp float;

// Destination draw size (the on-screen page rect, device px). uv spans 0..1
// across the page: uv = (fragCoord - uOffset) / uResolution.
uniform vec2 uResolution;
// Top-left of the page rect within the painter (device px). Lets the page be
// letterboxed/panned while FlutterFragCoord stays relative to the painter.
uniform vec2 uOffset;
// Source texture size in texels (the decoded page's pixel dimensions).
uniform vec2 uTexSize;
uniform sampler2D uTex;

out vec4 fragColor;

float lanczos(float x) {
  x = abs(x);
  if (x < 1e-4) return 1.0;
  if (x >= 3.0) return 0.0;
  float px = 3.14159265358979 * x;
  return (sin(px) / px) * (sin(px / 3.0) / (px / 3.0));
}

void main() {
  vec2 uv = (FlutterFragCoord().xy - uOffset) / uResolution;
  vec2 tc = uv * uTexSize;

  vec2 base = floor(tc - 0.5);
  vec2 f = fract(tc - 0.5);

  vec4 color = vec4(0.0);
  float wsum = 0.0;
  for (int j = -2; j <= 3; j++) {
    float wy = lanczos(f.y - float(j));
    for (int i = -2; i <= 3; i++) {
      float w = lanczos(f.x - float(i)) * wy;
      vec2 texel = base + vec2(float(i), float(j)) + 0.5;
      vec2 sampleUv = clamp(texel / uTexSize, vec2(0.0), vec2(1.0));
      color += texture(uTex, sampleUv) * w;
      wsum += w;
    }
  }

  // Normalize (Lanczos weights do not sum to exactly 1 over a finite window) and
  // clamp the sharpening overshoot so ringing never goes out of range.
  fragColor = clamp(color / wsum, 0.0, 1.0);
}
