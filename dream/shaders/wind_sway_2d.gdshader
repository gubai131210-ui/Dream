shader_type canvas_item;
render_mode blend_mix;

// Maujoe-style 2D wind: top of sprite leans, feet stay planted (UV.y falloff).
// amplitude_px is in local Sprite2D pixels — keep it clearly visible (4–12).

uniform float speed = 1.2;
uniform float amplitude_px = 8.0;
uniform float detail = 1.25;
uniform float height_offset : hint_range(0.0, 0.6) = 0.12;
uniform float phase_offset = 0.0;
uniform float gust_interval = 3.2;
uniform float gust_boost = 0.35;

void vertex() {
	float time = TIME * speed + phase_offset;
	// Primary sway + slower gust envelope so motion never looks flat.
	float wave = sin(time) + 0.55 * sin(time * detail + 1.7);
	float gust = 1.0 + gust_boost * sin(time / max(gust_interval, 0.2));
	float falloff = max(0.0, (1.0 - UV.y) - height_offset);
	falloff = pow(falloff, 0.9);
	VERTEX.x += wave * amplitude_px * gust * falloff;
}
