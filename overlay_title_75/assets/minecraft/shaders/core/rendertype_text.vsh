#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:globals.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

// --- LunaMine: animated titles (ops/rp/gen_title_shader.py, generated - do not edit) ---
// Titles in order: DRIFT, ETHER, WANDERER, METEOR, ALIEN, VAGRANT, NAVIGATOR, MOON_TIDE, ICE_COMET, SOLAR_WIND, STAR_WIND, DUST_CLOUD, PROTOSTAR, AURORA, CHRONONAUT, SPECTRUM, NEON, DREAMER, MIRAGE, KALEIDOSCOPE, PRISM, HOLOGRAM, FANTASIST, ILLUSIONIST, CHAOS, ANOMALY, INTERSTELLAR, MULTIVERSE, GALAXY_LORD, SINGULARITY, PILOT, ENGINEER, COSMONAUT, SATELLITE, PATHFINDER, CAPTAIN, STAR_PIRATE, COMMANDER, STAR_KNIGHT, MOON_GUARD, PLATINUM, MOON_KEEPER, ADMIRAL, EVENT_HORIZON, SPACE_LORD, SLEEPY, LUNATIC, SIGNAL, RED_DWARF, RADIO_WAVE, WHITE_DWARF, MOON_CAT, REACTOR, DARK_MATTER, MOON_SHADOW, NEUTRON_STAR, STAR_HEART, LUNAR_ECLIPSE, ABYSS, COLLAPSE, SPARK, FIREFLY, LITTLE_STAR, STARGAZER, SNOWFLAKE, EMBER, ASTROLOGER, HOARFROST, FALLING_STAR, FIREWORK, SUPERNOVA, DIAMOND_DUST, STAR_RAIN, STAR_PRINCE, STAR_QUEEN, MOON
const int LM_COUNT = 76;
const ivec3 LM_KEY[LM_COUNT] = ivec3[](ivec3(159, 180, 217), ivec3(205, 231, 247), ivec3(180, 140, 255), ivec3(255, 179, 71), ivec3(124, 240, 107), ivec3(217, 160, 102), ivec3(111, 214, 201), ivec3(142, 201, 255), ivec3(158, 231, 255), ivec3(255, 211, 110), ivec3(169, 185, 255), ivec3(216, 180, 166), ivec3(255, 158, 122), ivec3(91, 245, 177), ivec3(125, 227, 244), ivec3(240, 184, 255), ivec3(125, 255, 181), ivec3(255, 184, 230), ivec3(255, 224, 138), ivec3(176, 255, 138), ivec3(184, 240, 255), ivec3(138, 243, 255), ivec3(255, 201, 163), ivec3(211, 166, 255), ivec3(255, 111, 163), ivec3(157, 255, 218), ivec3(229, 139, 247), ivec3(163, 184, 255), ivec3(255, 138, 217), ivec3(237, 237, 237), ivec3(167, 196, 217), ivec3(224, 169, 79), ivec3(143, 211, 245), ivec3(215, 222, 233), ivec3(156, 214, 122), ivec3(94, 155, 255), ivec3(242, 181, 69), ivec3(199, 91, 91), ivec3(185, 198, 232), ivec3(154, 168, 201), ivec3(229, 228, 226), ivec3(59, 195, 253), ivec3(46, 95, 209), ivec3(108, 92, 231), ivec3(212, 175, 55), ivec3(181, 185, 217), ivec3(195, 207, 235), ivec3(123, 232, 123), ivec3(255, 107, 87), ivec3(127, 209, 255), ivec3(242, 244, 255), ivec3(245, 230, 169), ivec3(166, 255, 77), ivec3(155, 93, 229), ivec3(140, 147, 179), ivec3(159, 242, 255), ivec3(255, 107, 139), ivec3(224, 122, 95), ivec3(90, 63, 160), ivec3(255, 79, 109), ivec3(255, 196, 138), ivec3(216, 242, 123), ivec3(255, 233, 168), ivec3(233, 196, 107), ivec3(207, 239, 255), ivec3(255, 159, 90), ivec3(180, 156, 255), ivec3(169, 216, 232), ivec3(138, 166, 255), ivec3(255, 94, 126), ivec3(255, 122, 61), ivec3(196, 246, 255), ivec3(185, 141, 255), ivec3(127, 168, 255), ivec3(255, 154, 213), ivec3(248, 250, 255));
const vec3 LM_ALT[LM_COUNT] = vec3[](vec3(0.4353, 0.4980, 0.7216), vec3(0.5608, 0.7098, 0.9098), vec3(0.3608, 0.8824, 0.9020), vec3(1.0000, 0.3059, 0.2275), vec3(0.1373, 0.6588, 0.4314), vec3(0.5451, 0.3529, 0.2353), vec3(0.1843, 0.4980, 0.8157), vec3(0.9137, 0.9451, 1.0000), vec3(0.3098, 0.4902, 0.9490), vec3(1.0000, 0.4824, 0.3294), vec3(0.9529, 0.7765, 1.0000), vec3(0.5569, 0.4353, 0.6588), vec3(1.0000, 0.9059, 0.6392), vec3(0.4157, 0.5490, 1.0000), vec3(0.7529, 0.4863, 1.0000), vec3(1.0000, 1.0000, 1.0000), vec3(0.0000, 1.0000, 0.7843), vec3(1.0000, 0.7529, 0.9098), vec3(1.0000, 0.8235, 0.4784), vec3(0.6118, 1.0000, 0.4196), vec3(0.6235, 0.9098, 1.0000), vec3(0.3529, 0.8196, 1.0000), vec3(1.0000, 0.6392, 0.4196), vec3(0.6078, 0.4196, 1.0000), vec3(1.0000, 0.1804, 0.4314), vec3(0.2314, 1.0000, 0.6039), vec3(0.7882, 0.6510, 1.0000), vec3(0.4196, 0.5451, 1.0000), vec3(1.0000, 0.8471, 0.4196), vec3(0.1020, 0.0392, 0.1804), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 0.9451, 0.7686), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 1.0000, 1.0000), vec3(0.9373, 1.0000, 0.8510), vec3(0.8392, 0.9020, 1.0000), vec3(1.0000, 0.9569, 0.7882), vec3(1.0000, 0.8157, 0.7882), vec3(1.0000, 1.0000, 1.0000), vec3(0.9098, 0.9412, 1.0000), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 0.8784, 0.5412), vec3(0.9725, 0.7647, 1.0000), vec3(1.0000, 1.0000, 1.0000), vec3(0.4314, 0.4510, 0.6118), vec3(0.4902, 0.5608, 0.8196), vec3(0.1647, 0.5490, 0.2275), vec3(0.6118, 0.1647, 0.1333), vec3(0.1725, 0.4353, 0.7216), vec3(0.6039, 0.6510, 0.8392), vec3(0.7255, 0.6392, 0.9412), vec3(0.2471, 0.5608, 0.0706), vec3(0.2353, 0.1176, 0.4392), vec3(0.1686, 0.1843, 0.2706), vec3(0.2353, 0.4902, 1.0000), vec3(1.0000, 0.8196, 0.8627), vec3(0.2275, 0.1098, 0.1098), vec3(0.0549, 0.0314, 0.1255), vec3(0.1647, 0.0392, 0.2275), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 1.0000, 0.8784), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 0.8941, 0.6902), vec3(1.0000, 0.9490, 0.6902), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 0.9412, 0.6275), vec3(1.0000, 0.9490, 0.6902), vec3(1.0000, 1.0000, 1.0000), vec3(1.0000, 0.9490, 0.6902), vec3(1.0000, 0.9059, 0.6275), vec3(1.0000, 0.9647, 0.7843), vec3(0.7059, 0.7843, 1.0000));
// Effect: 0 flow, 1 rainbow, 2 shine, 3 pulse, 4 sparkle, 5 float.
const int LM_FX[LM_COUNT] = int[](0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5);

vec3 lm_hue(float h) {
    return clamp(abs(fract(h + vec3(0.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0) - 1.0, 0.0, 1.0);
}

// Matches a title by its exact vertex colour (or colour / 4 - the vanilla text shadow)
// and recolours the vertex; float also moves it. Other text is untouched.
void lm_apply(inout vec3 pos, inout vec4 color) {
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
        // The second colour tints the rainbow, so rainbow titles differ from each other.
        rgb = mix(lm_hue(fract(t / 4.0 - x / 64.0)), b, 0.25);
    } else if (fx == 2) {
        float d = abs(fract(x / 96.0 - t / 3.0) - 0.5);
        rgb = mix(a, b, 1.0 - smoothstep(0.03, 0.09, d));
    } else if (fx == 3) {
        rgb = mix(a, b, 0.5 + 0.5 * sin(6.2831853 * t / 2.0));
    } else if (fx == 5) {
        // Float (emoji titles): the glyph bobs one font pixel up and down and breathes towards
        // the cool second colour at the top. Time only, no x: all four vertices of the glyph
        // move together, so the picture never shears.
        float s = sin(6.2831853 * t / 3.0);
        rgb = mix(a, b, 0.5 - 0.5 * s);
        vec3 up = vec3(ModelViewMat[0][1], ModelViewMat[1][1], ModelViewMat[2][1]);
        pos += gui ? vec3(0.0, s, 0.0) : up * (-s / 40.0);
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
    vec3 lmPos = Position;
    lm_apply(lmPos, lmColor);
    gl_Position = ProjMat * ModelViewMat * vec4(lmPos, 1.0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = lmColor * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
}
