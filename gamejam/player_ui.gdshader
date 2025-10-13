shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float grain_amount : hint_range(0.0, 1.0) = 0.05;
uniform float grain_size : hint_range(0.1, 10.0) = 1.0;
uniform float speed : hint_range(0.0, 10.0) = 1.0; // how fast the grain changes

void fragment() {
    vec4 original_color = texture(screen_texture, SCREEN_UV);

    // Add TIME to make noise move each frame
    float noise = fract(
        sin(dot(UV * grain_size + vec2(TIME * speed, TIME * speed * 0.5),
                vec2(12.9898, 78.233)))
        * 43758.5453
    );

    // Center around 0 for symmetric brightness variation
    noise = (noise - 0.5) * 2.0;

    // Apply grain
    original_color.rgb += noise * grain_amount;

    COLOR = clamp(original_color, 0.0, 1.0);
}
