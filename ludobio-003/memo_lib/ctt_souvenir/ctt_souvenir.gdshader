shader_type canvas_item;
uniform float reco_strength = 0;
uniform float clarity_strength = 0;

void fragment(){
	vec4 image_color = texture(TEXTURE, UV);
	image_color.b = clarity_strength;
	//image_color.a = reco_strength ;
	COLOR = image_color;
}