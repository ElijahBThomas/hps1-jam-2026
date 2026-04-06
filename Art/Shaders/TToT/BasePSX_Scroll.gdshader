shader_type spatial;
render_mode vertex_lighting, skip_vertex_transform, diffuse_burley,
			cull_disabled, depth_draw_always, unshaded;

uniform float fog_near			= 6.0;
uniform float fog_far			= 20.0;
uniform sampler2D albedo: source_color, filter_nearest, repeat_enable;
uniform sampler2D noise_texture: source_color, filter_nearest, repeat_enable;
uniform float scroll_speed_1;
uniform float scroll_speed_2;
uniform float distortion_strength = 10;

uniform float jitter: hint_range(0.0, 1.0) = 0.5;
uniform bool jitter_z_coordinate = true;
uniform bool jitter_depth_independent = true;
uniform bool affine_texture_mapping = true;
uniform float alpha_scissor: hint_range(0.0, 1.0) = 0.1;



uniform vec4  fog_color :source_color = vec4(0.0);

void vertex() {
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

	float z_orig = VERTEX.z;
	float i = (1.0 - jitter) * min(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y) / 2.0;

	if (jitter_depth_independent) {
		float w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
		VERTEX = round(VERTEX / w * i) / i * w;
	} else {
		VERTEX = round(VERTEX * i) / i;
	}

	if (!jitter_z_coordinate) {
		VERTEX.z = z_orig;
	}

	if (affine_texture_mapping) {
		UV *= VERTEX.z /0.5;
	}
}

void fragment() {
	vec2 uv = vec2(UV.x + (TIME * scroll_speed_1), UV.y - (TIME * scroll_speed_2));

	float dn = texture(noise_texture, UV + TIME * 0.1).r;

	uv += dn * distortion_strength;
	uv -= distortion_strength / 2.0;

	if (affine_texture_mapping) {
		uv /= (VERTEX.z*2.0);
	}


	ALBEDO = mix(texture(albedo, uv).rgb, fog_color.rgb, clamp(-(((VERTEX.z * 2.2) * (1.0 / fog_near)) / fog_far), 0.0, 1.0));
	ALPHA = COLOR.a;
	//ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
}