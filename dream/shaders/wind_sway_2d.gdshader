shader_type canvas_item;
render_mode blend_mix;

// Based on Maujoe / HungryProton 2D wind sway (godotshaders.com/shader/2d-wind-sway/)
// UV.y falloff keeps feet planted; optional pixel snap for nearest-filtered art.

uniform float speed = 1.0;
uniform float min_strength : hint_range(0.0, 1.0) = 0.02;
uniform float max_strength : hint_range(0.0, 1.0) = 0.055;
uniform float strength_scale = 7.0;
uniform float interval = 3.5;
uniform float detail = 1.0;
uniform float height_offset : hint_range(0.0, 1.0) = 0.0;
uniform float phase_offset = 0.0;
uniform bool pixel_snap = true;

float get_wind(vec2 uv, float time) {
	float diff = max(0.0, max_strength - min_strength);
	float strength = (min_strength + diff * 0.5 + sin(time / interval) * diff * 0.5) * strength_scale;
	float falloff = max(0.0, (1.0 - uv.y) - height_offset);
	return (sin(time) + cos(time * detail)) * strength * falloff;
}

void vertex() {
	float time = TIME * speed + phase_offset;
	float wind = get_wind(UV, time);
	if (pixel_snap) {
		// VERTEX is in local pixels for Sprite2D — snap to whole pixels.
		wind = floor(wind + 0.5);
	}
	VERTEX.x += wind;
}
