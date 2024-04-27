vec2 translated_2d(vec2 uv, vec2 displacement_uv){
	return uv + displacement_uv;
}

vec2 rotated_2d(vec2 uv, vec2 pivot, float angle){
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));

	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

vec2 scaled_2d(vec2 uv, float x, float y)
{
	mat2 scale = mat2(vec2(x, 0.0), vec2(0.0, y));

	uv -= 0.5;
	uv = uv * scale;
	uv += 0.5;
	return uv;
}

vec3 translated_3d(vec3 vertex, vec3 displacement_vertex){
	return vertex + displacement_vertex;
}

//vec3 rotated_3d(vec3 vertex, vec3 pivot, float angle){
	//mat3 rotation = mat3(vec3(sin(angle), -cos(angle)),
						//vec3(cos(angle), sin(angle)));
//
	//vertex -= pivot;
	//vertex = vertex * rotation;
	//vertex += pivot;
	//return uv;
//}

vec3 scaled_3d(vec3 vertex, float scale){
	return vertex * scale;
}

vec3 skewed_3d(vec3 vertex, vec3 skew_direction, float intensity){
	return vertex += (skew_direction * distance(vertex.y, 1.0) * intensity);
}