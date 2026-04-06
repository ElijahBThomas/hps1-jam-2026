shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D colorA : hint_default_white;
uniform sampler2D colorB : hint_default_white;
uniform float frequency = 0.05;
uniform float amplitude = 0.05;

void fragment() {
    // Calculate UV coordinates
	vec2 uv = SCREEN_UV;
    // Offset the UV coordinates based on a sine wave
    uv.x += sin(SCREEN_UV.y * 10.0 + TIME) * frequency; // Adjust the frequency and amplitude as needed
    uv.y += sin(SCREEN_UV.x * 5.0 + TIME) * amplitude;

    // Sample the texture using the modified UV coordinates
    vec4 screen = texture(screen_texture, uv);
	COLOR = screen;
}