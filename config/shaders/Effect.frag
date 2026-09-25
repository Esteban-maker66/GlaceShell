#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float timeUniform;
    vec2 resolution;
} ubuf;

void main() {
    vec2 uv = qt_TexCoord0;

    float wave1 = sin(uv.x * 6.0 + ubuf.timeUniform * 0.8) * 0.1;
    float wave2 = cos(uv.y * 4.0 - ubuf.timeUniform * 0.4) * 0.12;

    vec3 baseBlue = vec3(0.0, 0.45, 0.95);
    vec3 deepBlue = vec3(0.0, 0.20, 0.65);

    vec3 finalColor = mix(baseBlue, deepBlue, uv.y + wave1 + wave2);

    fragColor = vec4(finalColor, 1.0) * ubuf.qt_Opacity;
}
