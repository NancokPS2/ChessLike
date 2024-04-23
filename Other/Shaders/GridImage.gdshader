shader_type canvas_item;
#include "Includes/Grid.gdshaderinc"
#include "Includes/Time.gdshaderinc"
#include "Includes/Transform.gdshaderinc"

uniform sampler2D image;
uniform float columns = 2;
uniform float rows = 2;

void fragment() {
	vec2 sub_uv = clipped_uv_2d(UV, vec2(0.2,0.1), vec2(0.9,0.9));
	COLOR = grid_texture_color(UV, columns, rows, image);
	COLOR += grid_line_color(UV, columns, rows, vec4(1,1,1,1), 0.05);
	//COLOR *= pulse_per_seconds(5.0);

}

