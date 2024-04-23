shader_type spatial;
#include "Includes/Fresnel.gdshaderinc"

void fragment() {
	vec3 base_color = vec3(1.0);
	float basic_fresnel = fresnel(1.0, NORMAL, VIEW);
	ALPHA = basic_fresnel;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
