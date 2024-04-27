shader_type spatial;
#include "Includes/Transform.gdshaderinc"

void vertex() {
	//VERTEX = scaled_3d(VERTEX, get_milis() + 1.0);
	VERTEX = skewed_3d(VERTEX, vec3(1,0,0), sin(TIME));
	VERTEX = skewed_3d(VERTEX, vec3(0,0,0.5), sin(TIME));
}

