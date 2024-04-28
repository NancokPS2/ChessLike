float get_milis(){
	return fract(TIME);
}

float get_milis_cos(){
	return cos(fract(TIME)*PI*2.0);
}

float get_milis_sin(){
	return sin(fract(TIME)*PI*2.0);
}

float get_milis_extended(float stretch_ratio){
	return 0.0;
}