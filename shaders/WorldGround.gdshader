// NOTE: Shader automatically converted from Godot Engine 3.5.1.stable.mono's SpatialMaterial.

shader_type spatial;
render_mode async_visible,blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float falloff : hint_range(0,2);
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}




void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	float dist = length(UV - 0.5);
	vec2 c = fract(UV.xy * 12.0);
	ALBEDO = vec3(c.x < 0.5 ? 0.0 : 1.0, c.y < 0.5 ? 0.0 : 1.0, c.y < 0.5 ? 0.0 : 1.0);
	ALBEDO *= albedo.rgb * albedo_tex.rgb * pow(1.0 - dist * 2.0, falloff);
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	
	if (dist > 0.5)
		discard;
}
