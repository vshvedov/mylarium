#version 460 core
#include <flutter/runtime_effect.glsl>

// High-quality page sampler for the reader. When a page is drawn larger than its
// native size (pinch-zoom), the engine's default sampler (bilinear on Impeller)
// produces a soft, blurry upscale. This replaces it with a Catmull-Rom bicubic
// kernel (16 taps): sharp, interpolating, the same family Komelia uses on
// desktop. It invents no detail - it just stops throwing sharpness away.

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

// Catmull-Rom weights for the four taps at relative positions -1, 0, 1, 2 given
// the fractional position f in [0, 1]. Sums to 1; can be slightly negative
// (overshoot), which we clamp away at the end.
vec4 catmullRom(float f) {
  float f2 = f * f;
  float f3 = f2 * f;
  return 0.5 * vec4(
    -f3 + 2.0 * f2 - f,
    3.0 * f3 - 5.0 * f2 + 2.0,
    -3.0 * f3 + 4.0 * f2 + f,
    f3 - f2
  );
}

void main() {
  vec2 uv = (FlutterFragCoord().xy - uOffset) / uResolution;
  vec2 tc = uv * uTexSize;
  vec2 base = floor(tc - 0.5);
  vec2 f = fract(tc - 0.5);

  vec4 wx = catmullRom(f.x);
  vec4 wy = catmullRom(f.y);

  vec4 color = vec4(0.0);
  for (int j = -1; j <= 2; j++) {
    for (int i = -1; i <= 2; i++) {
      vec2 texel = base + vec2(float(i), float(j)) + 0.5;
      vec2 sampleUv = clamp(texel / uTexSize, vec2(0.0), vec2(1.0));
      color += texture(uTex, sampleUv) * (wx[i + 1] * wy[j + 1]);
    }
  }

  // Clamp overshoot from the (sharpening) negative lobes so ringing never
  // produces out-of-range colors.
  fragColor = clamp(color, vec4(0.0), vec4(1.0));
}
