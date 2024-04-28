float line(vec2 p1, vec2 p2, float width, vec2 uv, float screen_pixel_size)
{
	float dist = distance(p1, p2); // Distance between points
	float dist_uv = distance(p1, uv); // Distance from p1 to current pixel

	// If point is on line, according to dist, it should match current UV
	// Ideally the '0.001' should be SCREEN_PIXEL_SIZE.x, but we can't use that outside of the fragment function.
	return 1.0 - floor(1.0 - (screen_pixel_size * width) + distance (mix(p1, p2, clamp(dist_uv / dist, 0.0, 1.0)),  uv));
}