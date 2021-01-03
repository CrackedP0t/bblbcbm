shader_type spatial;
render_mode unshaded;
render_mode cull_disabled;

uniform sampler2D tex: hint_albedo;
uniform vec2 tex_size = vec2(1.0, 1.0);
uniform vec2 decal_position = vec2(0.0);
uniform float decal_scale = 1.0;
uniform float fade = 1.0;

varying vec2 tex_position;

void vertex() {
  tex_position = VERTEX.xy;
}

void fragment(){
	vec2 tp = tex_position - decal_position;
	
	float ratio = tex_size.x / tex_size.y;
	vec2 scaled = vec2(ratio * decal_scale, decal_scale);
	
	if (tp.x > scaled.x || tp.y > scaled.y || tp.x < 0.0 || tp.y < 0.0) {
		ALPHA = 0.0;
	} else {
		vec4 color = texture(tex, tp * vec2(1.0, -1.0) / scaled) * fade;
		ALPHA = color.a;
		ALBEDO = color.rgb;
	}
}