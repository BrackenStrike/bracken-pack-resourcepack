
#version 330

#extension GL_ARB_separate_shader_objects : require

uniform sampler2D InSampler;

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};

layout(location = 0) in vec2 texCoord;
layout(location = 0) out vec4 fragColor;

float luminance(vec3 color) {
    return dot(color, vec3(0.299, 0.587, 0.114));
}

float sampleLuminance(vec2 uv) {
    return luminance(texture(InSampler, uv).rgb);
}

vec3 rgbToHsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);

    vec4 p = mix(
        vec4(c.bg, K.wz),
        vec4(c.gb, K.xy),
        step(c.b, c.g)
    );

    vec4 q = mix(
        vec4(p.xyw, c.r),
        vec4(c.r, p.yzx),
        step(p.x, c.r)
    );

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;

    return vec3(
        abs(q.z + (q.w - q.y) / (6.0 * d + e)),
        d / (q.x + e),
        q.x
    );
}

float purpleMask(vec3 color) {
    vec3 hsv = rgbToHsv(color);

    float hueMask =
        smoothstep(0.66, 0.72, hsv.x) *
        (1.0 - smoothstep(0.90, 0.95, hsv.x));

    float saturationMask =
        smoothstep(0.12, 0.35, hsv.y);

    return hueMask * saturationMask;
}

void main() {
    vec2 texel = 1.0 / InSize;

    vec3 originalColor = texture(InSampler, texCoord).rgb;

    float tl = sampleLuminance(texCoord + vec2(-texel.x, texel.y));
    float tc = sampleLuminance(texCoord + vec2(0.0, texel.y));
    float tr = sampleLuminance(texCoord + vec2(texel.x, texel.y));

    float ml = sampleLuminance(texCoord + vec2(-texel.x, 0.0));
    float mr = sampleLuminance(texCoord + vec2(texel.x, 0.0));

    float bl = sampleLuminance(texCoord + vec2(-texel.x, -texel.y));
    float bc = sampleLuminance(texCoord + vec2(0.0, -texel.y));
    float br = sampleLuminance(texCoord + vec2(texel.x, -texel.y));

    float gx =
        -tl - 2.0 * ml - bl +
         tr + 2.0 * mr + br;

    float gy =
         tl + 2.0 * tc + tr -
         bl - 2.0 * bc - br;

    float edge = length(vec2(gx, gy));

    float wire = smoothstep(0.09, 0.28, edge);
    wire = pow(wire, 0.85);

    float purple = purpleMask(originalColor);

    vec3 backgroundColor = vec3(0.002, 0.009, 0.002);

    vec3 greenTint = vec3(0.018, 0.075, 0.012);

    vec3 edgeColor = mix(
        originalColor,
        vec3(
            originalColor.r * 0.75,
            originalColor.g * 1.15,
            originalColor.b * 0.75
        ),
        0.35
    );

    vec3 finalColor = mix(
        backgroundColor,
        greenTint,
        0.35
    );

    finalColor = mix(
        finalColor,
        edgeColor,
        wire
    );

    finalColor = mix(
        finalColor,
        originalColor,
        purple * wire
    );

    fragColor = vec4(finalColor, 1.0);
}
