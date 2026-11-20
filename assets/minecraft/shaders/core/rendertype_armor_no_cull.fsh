//// This exact piece of code was taken straight from KirbAvions TRONLine resource pack on Github. Big shoutout to them. Hopefully they don't mind us taking this...?
//// https://github.com/KirbAvion/TRONLines/blob/main/assets/minecraft/shaders/core/rendertype_armor_cutout_no_cull.fsh
//// The code is absolutely untouched starting from line 5 of this file.

#version 150

//This uses a trick I first saw in a shader pack by ShockMicro. https://github.com/ShockMicro/VanillaDynamicEmissives

//Kirven was here. www.brennynsabar.us

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
	
    if (color.a * 255 < 1) {
        discard;
    }
	
    if (color.a * 255 <= 254 && color.a * 255 >= 1) {
	
        color = texture(Sampler0, texCoord0) * vec4(min(vertexColor.r + color.a, 1), min(vertexColor.g + color.a, 1), min(vertexColor.b + color.a, 1), 1) * ColorModulator;
    }
	
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}