shader_type spatial;

uniform vec3 direction = vec3(1,0,0);
uniform float strength = 0.1;
uniform float sway_frequency = 2.0;

vec3 deformed_3d(vec3 vertex, vec3 deform_pivot, vec3 deform_vector){
	return vertex += deform_vector * distance(vertex, deform_pivot);
}

void vertex() {
	//Get the offset based of strength and how often it sways
	float total_sway = sin(TIME*sway_frequency) * strength;

	//The closer the VERTEX is to the center, the less it moves
	total_sway *= distance(vec3(0,1,0), direction*1.5);
	//total_sway *= distance(VERTEX, direction*1.5);

	vec3 drop = vec3(0,1.0 * total_sway/3.0,0);

	VERTEX = deformed_3d(VERTEX, vec3(0,-1,0), (direction * total_sway) - drop);
}