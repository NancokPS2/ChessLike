float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

float global_inverted_fresnel(vec3 screen_uv, vec3 vertex_uv){
	return distance(screen_uv, vertex_uv);
}