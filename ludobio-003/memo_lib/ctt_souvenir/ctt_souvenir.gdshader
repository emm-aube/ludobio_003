
shader_type canvas_item;

//uniform means it can be written by things outside the shader 

// sampler2d is a type of variable for shaders only (it's reading the screen / part of it to apply shader on)
// hint_screen_texture means it copies the whole screen, filter_nearest is for rendering (smooth = linear/ sharp - nearet)
uniform sampler2D whole_screen : hint_screen_texture, filter_nearest;

// we use mouseposition later, here just declare a var for it, modified in gd script on the rect
uniform vec2 mouse_pos;

// Adjustable parameters for distance and strentgh of glow 
// CHAT GPT PROPOSAL (hint_range adds a slider in the Inspector uniform): float glow_max : hint_range(0.0, 2.0) = 0.5;
// floats are how much we add / remove from current value
// uniform is like @export
const float glow_max = 0.9;
const float dark_max = 1.0;
// distance are percentages of the screen (calculater later)
const float glow_distance = 0.1;
const float dark_distance = 1.0;
const float flicker_max = 0.03;
// BLOOM VALUES
// how dark a pixel must be to be lightened by neighnours
const float bloom_receiver_threshold = 0.1; 
// how bright a color must be to lighten neighbours
const float bloom_giver_threshold = 0.7;
const float bloom_min_strength = 0.1;
const float bloom_max_strength = 0.3;

// fragment goes pixel per pixel on the whole screen
void fragment() {
	// just take the position (uv) and value (texture with original texture + position) of original pixel
    vec2 original_px_pos = SCREEN_UV;
    vec4 original_px = texture(whole_screen, original_px_pos);

	// bloom stuff
	// check all the pixels around
	vec3 bloom_strength = vec3(0.);
	float original_px_brightness = (original_px.r + original_px.b + original_px.g) /3.0;
	if(original_px_brightness < bloom_receiver_threshold){
		vec3 max_color = vec3(0.0);
		for (int x = -1; x < 2; x++){
			for (int y = -1; y < 2; y++){
				if(x == 0 && y == 0){
					continue;
				}
				// based on the offset of each
				vec2 px_offset = vec2(float(x), float(y)) * SCREEN_PIXEL_SIZE;
				// find the color of each
				vec3 px_color = texture(whole_screen, original_px_pos + px_offset).rgb;
				// then keep the stronger one
				max_color = max(px_color, max_color);
			}
		}
		float neighbor_px_brightness = (max_color.r + max_color.b + max_color.g) / 3.0;
		if(neighbor_px_brightness > bloom_giver_threshold){
			// bloom_strength = vec3(randf_range(bloom_min_strength, bloom_max_strength) / 3)
			bloom_strength = vec3(0.2);
			// COLOR = vec4(original_px.rgb + vec3(randf_range(bloom_min_strength, bloom_max_strength) / 3), original_px.a);
		}
	}

	// check difference between mouse pos and current pixel
    vec2 delta = original_px_pos - mouse_pos;
	// to adjust for screen size (CHAT GPT STUFF' takes y as base and adjust the x delta depending on size ratio)
    delta.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	// then lookcs at the vec lentgh (cursor to current treated pixel)
    float current_distance = length(delta);

	// then define glow and darkness and flicker values based on distance
	// if current distance > than glow dist, obv goes to 0
    float glow_multiplier = 1.0 - clamp(current_distance/glow_distance, 0.0, 1.0);
	float dark_multiplier = clamp((current_distance - glow_distance) / (dark_distance - glow_distance), 0.0, 1.0);
	// create a sinusoidal function for the flickering. this is just some CHAT GPT stuff Idon't get it fully
    float flicker_modifier = sin(TIME * 3.0) * flicker_max;
	
	// calcultae final brightness, 1 being original value then modifiers (multipliers * max value)
    float brightness = 1.0 + glow_multiplier * glow_max - dark_multiplier * dark_max + flicker_modifier;

	// apply it to the pixel
    COLOR = vec4((original_px.rgb + bloom_strength) * max(brightness, 0.0) , original_px.a);
}
