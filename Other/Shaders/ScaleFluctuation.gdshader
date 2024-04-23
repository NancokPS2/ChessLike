shader_type spatial;
#include "Includes/Transform.gdshaderinc"
#include "Includes/Time.gdshaderinc"

void vertex() {
	//VERTEX = scaled_3d(VERTEX, get_milis() + 1.0);
	VERTEX = waved_3d(VERTEX, vec3(1,0,0), 2.0, TIME*2.0);
	VERTEX = waved_3d(VERTEX, vec3(0,0,1), 2.0, TIME);
	VERTEX = skewed_3d(VERTEX,vec3(1,0,0), vec3(0,1,0), sin(TIME));
	VERTEX = skewed_3d(VERTEX,vec3(0,0,0.5), vec3(0,1,0), sin(TIME));
}

