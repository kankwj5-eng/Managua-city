shader_type canvas_item;

// Denoiser ligero IA-inspirado para móvil.
// Usa vecinos con pesos adaptativos según diferencia de luminancia.
uniform float denoise_strength : hint_range(0.0, 1.0) = 0.32;
uniform float sharpen_strength : hint_range(0.0, 0.35) = 0.06;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

float luminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

void fragment() {
    vec2 pixel = SCREEN_PIXEL_SIZE;
    vec3 center = texture(screen_texture, SCREEN_UV).rgb;
    float center_luma = luminance(center);
    vec3 sum = center;
    float total_weight = 1.0;

    // Cinco muestras: centro + cruz. Bajo costo para gama baja.
    for (int i = 0; i < 4; i++) {
        vec2 direction = (i == 0) ? vec2(1.0, 0.0) :
                         (i == 1) ? vec2(-1.0, 0.0) :
                         (i == 2) ? vec2(0.0, 1.0) : vec2(0.0, -1.0);
        vec3 sample_color = texture(screen_texture, SCREEN_UV + direction * pixel).rgb;
        float difference = abs(luminance(sample_color) - center_luma);
        float weight = exp(-difference * 12.0);
        sum += sample_color * weight;
        total_weight += weight;
    }

    vec3 denoised = sum / total_weight;
    vec3 result = mix(center, denoised, denoise_strength);
    result += (center - denoised) * sharpen_strength;
    COLOR = vec4(result, 1.0);
}
