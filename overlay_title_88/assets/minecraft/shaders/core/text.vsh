#version 330

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:sample_lightmap.glsl>
#endif

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:globals.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
in ivec2 UV2;
#endif

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
uniform sampler2D Sampler2;
out float sphericalVertexDistance;
out float cylindricalVertexDistance;
#endif

out vec4 vertexColor;
out vec2 texCoord0;

// --- LunaMine: animated titles (ops/rp/gen_title_shader.py, generated - do not edit) ---
// Titles in order: LUNATIC, STARGAZER, COSMONAUT, ALIEN, METEOR, WANDERER, MOON_CAT, STAR_PIRATE, DARK_MATTER, AURORA, MOON_KEEPER, SUPERNOVA, EVENT_HORIZON, INTERSTELLAR, GALAXY_LORD
const int LM_COUNT = 15;
const ivec3 LM_KEY[LM_COUNT] = ivec3[](ivec3(195, 207, 235), ivec3(233, 196, 107), ivec3(143, 211, 245), ivec3(124, 240, 107), ivec3(255, 179, 71), ivec3(180, 140, 255), ivec3(245, 230, 169), ivec3(242, 181, 69), ivec3(155, 93, 229), ivec3(91, 245, 177), ivec3(59, 195, 253), ivec3(255, 122, 61), ivec3(108, 92, 231), ivec3(229, 139, 247), ivec3(255, 138, 217));
const vec3 LM_ALT[LM_COUNT] = vec3[](vec3(0.4902, 0.5608, 0.8196), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 1.0000, 1.0000), vec3(0.1373, 0.6588, 0.4314), vec3(1.0000, 0.3059, 0.2275), vec3(0.3608, 0.8824, 0.9020), vec3(0.7255, 0.6392, 0.9412), vec3(1.0000, 0.9569, 0.7882), vec3(0.2353, 0.1176, 0.4392), vec3(0.4157, 0.5490, 1.0000), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 0.9490, 0.6902), vec3(0.9725, 0.7647, 1.0000), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 1.0000, 1.0000));
// Effect: 0 flow, 1 rainbow, 2 shine, 3 pulse, 4 sparkle.
const int LM_FX[LM_COUNT] = int[](3, 4, 2, 0, 0, 0, 3, 2, 3, 0, 2, 4, 2, 1, 1);

vec3 lm_hue(float h) {
    return clamp(abs(fract(h + vec3(0.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0) - 1.0, 0.0, 1.0);
}

// Matches a title by its exact vertex colour (or colour / 4 - the vanilla text shadow)
// and recolours the vertex. Other text is untouched.
void lm_apply(vec3 pos, inout vec4 color) {
    ivec3 c = ivec3(round(color.rgb * 255.0));
    int found = -1;
    bool shadow = false;
    for (int i = 0; i < LM_COUNT; i++) {
        if (c == LM_KEY[i]) { found = i; break; }
        if (c == LM_KEY[i] / 4) { found = i; shadow = true; break; }
    }
    if (found < 0) return;

    vec3 a = vec3(LM_KEY[found]) / 255.0;
    vec3 b = LM_ALT[found];
    int fx = LM_FX[found];

    // Seconds. GameTime is the fraction of a 20 minute cycle; every period below divides
    // 1200 evenly, so nothing jumps when the cycle wraps.
    float t = GameTime * 1200.0;
    // GUI uses an orthographic projection with positions in GUI pixels. In the world (name tags)
    // measure along the camera's right axis in font pixels (1/40 block).
    bool gui = ProjMat[3][3] == 1.0;
    vec3 right = vec3(ModelViewMat[0][0], ModelViewMat[1][0], ModelViewMat[2][0]);
    float x = gui ? pos.x : dot(pos, right) * 40.0;

    vec3 rgb = a;
    if (fx == 0) {
        rgb = mix(a, b, 0.5 + 0.5 * sin(6.2831853 * (t / 3.0 - x / 48.0)));
    } else if (fx == 1) {
        rgb = mix(lm_hue(fract(t / 4.0 - x / 64.0)), vec3(1.0), 0.2);
    } else if (fx == 2) {
        float d = abs(fract(x / 96.0 - t / 3.0) - 0.5);
        rgb = mix(a, b, 1.0 - smoothstep(0.03, 0.09, d));
    } else if (fx == 3) {
        rgb = mix(a, b, 0.5 + 0.5 * sin(6.2831853 * t / 2.0));
    } else {
        // Two drifting sine waves multiplied: short bright glints wander over the letters.
        float g = sin(x * 0.9 + t * 3.1415927) * sin(x * 0.37 - t * 2.0943951);
        rgb = mix(a, b, pow(max(g, 0.0), 6.0));
    }
    color.rgb = shadow ? rgb * 0.25 : rgb;
}
// --- end LunaMine ---

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    vec4 lmColor = Color;
    lm_apply(Position, lmColor);

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = lmColor * sample_lightmap(Sampler2, UV2);
#else
    vertexColor = lmColor;
#endif
    texCoord0 = UV0;
}
