shader_type canvas_item;

uniform float progreso : hint_range(0.0, 1.0) = 0.0;

uniform float grosor_borde : hint_range(0.0, 0.1) = 0.02;

uniform vec4 color_brillo : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float intensidad_brillo : hint_range(1.0, 10.0) = 3.0;

void fragment() {
	vec4 color_original = texture(TEXTURE, UV);
	
	// Calculamos la escala de grises para el fondo
	float gris = dot(color_original.rgb, vec3(0.299, 0.587, 0.114));
	vec4 color_gris = vec4(vec3(gris), color_original.a);
	
	// Invertimos el eje Y para que el progreso suba (0.0 abajo, 1.0 arriba)
	float altura = 1.0 - UV.y;
	
	// Si el progreso está en 0 o en 1, evitamos dibujar la línea de brillo
	if (progreso <= 0.001 || progreso >= 0.999) {
		if (altura < progreso) {
			COLOR = color_original;
		} else {
			COLOR = color_gris;
		}
	} else {
		// Detectamos si el píxel actual está en la zona de transición (borde)
		if (altura >= progreso - grosor_borde && altura <= progreso) {
			// Añadimos el brillo respetando la transparencia del sprite original
			COLOR = vec4(color_brillo.rgb * intensidad_brillo, color_original.a);
		}
		// Si está por debajo de la línea, ya se recuperó el color
		else if (altura < progreso) {
			COLOR = color_original;
		} 
		// Si está por encima, se queda en gris
		else {
			COLOR = color_gris;
		}
	}
}
