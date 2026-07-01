shader_type canvas_item;

// Controla el modo de mezcla para que se sume como el modo "Add"
render_mode blend_add;

uniform float speed : hint_range(0.1, 5.0) = 1.0;
uniform float intensity : hint_range(0.1, 3.0) = 1.2;
uniform float frequency : hint_range(1.0, 20.0) = 5.0;

// Función simple de ruido pseudo-aleatorio para generar ondas de luz
float noise(vec2 uv) {
    return sin(uv.x * frequency + TIME * speed) * cos(uv.y * frequency + TIME * speed * 0.8);
}

void fragment() {
    // 1. Guardamos el color que viene del modulate/animación (COLOR original de Godot)
    vec4 modulate_color = COLOR;

    // Tomamos la textura del gradiente radial
    vec4 texture_color = texture(TEXTURE, UV);
    
    // Creamos dos capas de movimiento sutil para la luz
    float movement1 = noise(UV + vec2(TIME * 0.05 * speed, 0.0));
    float movement2 = noise(UV - vec2(0.0, TIME * 0.02 * speed));
    
    // Combinamos los movimientos para romper la simetría
    float final_noise = (movement1 + movement2) * 0.15 + 0.85;
    
    // 2. Aplicamos tu lógica de ruido e intensidad
    vec3 final_rgb = texture_color.rgb * intensity * final_noise;
    float final_alpha = texture_color.a * final_noise;

    // 3. Multiplicamos el resultado final por el color de la animación (modulate)
    COLOR.rgb = final_rgb * modulate_color.rgb;
    COLOR.a = final_alpha * modulate_color.a;
}
