#version 300 es
#define WEBGL2
#define DIFFUSEDIRECTUV 0
#define DETAILDIRECTUV 0
#define DETAIL_NORMALBLENDMETHOD 0
#define AMBIENTDIRECTUV 0
#define OPACITYDIRECTUV 0
#define EMISSIVEDIRECTUV 0
#define SPECULARDIRECTUV 0
#define BUMPDIRECTUV 0
#define SPECULARTERM
#define NORMAL
#define NUM_BONE_INFLUENCERS 0
#define BonesPerMesh 0
#define LIGHTMAPDIRECTUV 0
#define NUM_MORPH_INFLUENCERS 0
#define ALPHABLEND
#define PREPASS_IRRADIANCE_INDEX -1
#define PREPASS_ALBEDO_INDEX -1
#define PREPASS_DEPTHNORMAL_INDEX -1
#define PREPASS_POSITION_INDEX -1
#define PREPASS_VELOCITY_INDEX -1
#define PREPASS_REFLECTIVITY_INDEX -1
#define SCENE_MRT_COUNT 0
#define VIGNETTEBLENDMODEMULTIPLY
#define SAMPLER3DGREENDEPTH
#define SAMPLER3DBGRMAP
#define LIGHT0
#define HEMILIGHT0

#define SHADER_NAME vertex:default
precision highp float;
layout(std140, column_major) uniform;
uniform Material {
    vec4 diffuseLeftColor;
    vec4 diffuseRightColor;
    vec4 opacityParts;
    vec4 reflectionLeftColor;
    vec4 reflectionRightColor;
    vec4 refractionLeftColor;
    vec4 refractionRightColor;
    vec4 emissiveLeftColor;
    vec4 emissiveRightColor;
    vec2 vDiffuseInfos;
    vec2 vAmbientInfos;
    vec2 vOpacityInfos;
    vec2 vReflectionInfos;
    vec3 vReflectionPosition;
    vec3 vReflectionSize;
    vec2 vEmissiveInfos;
    vec2 vLightmapInfos;
    vec2 vSpecularInfos;
    vec3 vBumpInfos;
    mat4 diffuseMatrix;
    mat4 ambientMatrix;
    mat4 opacityMatrix;
    mat4 reflectionMatrix;
    mat4 emissiveMatrix;
    mat4 lightmapMatrix;
    mat4 specularMatrix;
    mat4 bumpMatrix;
    vec2 vTangentSpaceParams;
    float pointSize;
    mat4 refractionMatrix;
    vec4 vRefractionInfos;
    vec4 vSpecularColor;
    vec3 vEmissiveColor;
    float visibility;
    vec4 vDiffuseColor;
    vec4 vDetailInfos;
    mat4 detailMatrix;
};
uniform Scene {
    mat4 viewProjection;
    mat4 view;
};
#define CUSTOM_VERTEX_BEGIN
in vec3 position;
in vec3 normal;
const float PI = 3.1415926535897932384626433832795;
const float HALF_MIN = 5.96046448e-08;
const float LinearEncodePowerApprox = 2.2;
const float GammaEncodePowerApprox = 1.0/LinearEncodePowerApprox;
const vec3 LuminanceEncodeApprox = vec3(0.2126, 0.7152, 0.0722);
const float Epsilon = 0.0000001;
#define saturate(x) clamp(x, 0.0, 1.0)
#define absEps(x) abs(x)+Epsilon
#define maxEps(x) max(x, Epsilon)
#define saturateEps(x) clamp(x, Epsilon, 1.0)
mat3 transposeMat3(mat3 inMatrix) {
    vec3 i0 = inMatrix[0];
    vec3 i1 = inMatrix[1];
    vec3 i2 = inMatrix[2];
    mat3 outMatrix = mat3(
    vec3(i0.x, i1.x, i2.x), vec3(i0.y, i1.y, i2.y), vec3(i0.z, i1.z, i2.z)
    );
    return outMatrix;
}
mat3 inverseMat3(mat3 inMatrix) {
    float a00 = inMatrix[0][0], a01 = inMatrix[0][1], a02 = inMatrix[0][2];
    float a10 = inMatrix[1][0], a11 = inMatrix[1][1], a12 = inMatrix[1][2];
    float a20 = inMatrix[2][0], a21 = inMatrix[2][1], a22 = inMatrix[2][2];
    float b01 = a22*a11-a12*a21;
    float b11 = -a22*a10+a12*a20;
    float b21 = a21*a10-a11*a20;
    float det = a00*b01+a01*b11+a02*b21;
    return mat3(b01, (-a22*a01+a02*a21), (a12*a01-a02*a11), b11, (a22*a00-a02*a20), (-a12*a00+a02*a10), b21, (-a21*a00+a01*a20), (a11*a00-a01*a10))/det;
}
float toLinearSpace(float color) {
    return pow(color, LinearEncodePowerApprox);
}
vec3 toLinearSpace(vec3 color) {
    return pow(color, vec3(LinearEncodePowerApprox));
}
vec4 toLinearSpace(vec4 color) {
    return vec4(pow(color.rgb, vec3(LinearEncodePowerApprox)), color.a);
}
vec3 toGammaSpace(vec3 color) {
    return pow(color, vec3(GammaEncodePowerApprox));
}
vec4 toGammaSpace(vec4 color) {
    return vec4(pow(color.rgb, vec3(GammaEncodePowerApprox)), color.a);
}
float toGammaSpace(float color) {
    return pow(color, GammaEncodePowerApprox);
}
float square(float value) {
    return value*value;
}
float pow5(float value) {
    float sq = value*value;
    return sq*sq*value;
}
float getLuminance(vec3 color) {
    return clamp(dot(color, LuminanceEncodeApprox), 0., 1.);
}
float getRand(vec2 seed) {
    return fract(sin(dot(seed.xy, vec2(12.9898, 78.233)))*43758.5453);
}
float dither(vec2 seed, float varianceAmount) {
    float rand = getRand(seed);
    float dither = mix(-varianceAmount/255.0, varianceAmount/255.0, rand);
    return dither;
}
const float rgbdMaxRange = 255.0;
vec4 toRGBD(vec3 color) {
    float maxRGB = maxEps(max(color.r, max(color.g, color.b)));
    float D = max(rgbdMaxRange/maxRGB, 1.);
    D = clamp(floor(D)/255.0, 0., 1.);
    vec3 rgb = color.rgb*D;
    rgb = toGammaSpace(rgb);
    return vec4(rgb, D);
}
vec3 fromRGBD(vec4 rgbd) {
    rgbd.rgb = toLinearSpace(rgbd.rgb);
    return rgbd.rgb/rgbd.a;
}
uniform mat4 world;
out vec3 vPositionW;
out vec3 vNormalW;
uniform Light0 {
    vec4 vLightData;
    vec4 vLightDiffuse;
    vec4 vLightSpecular;
    vec3 vLightGround;
    vec4 shadowsInfo;
    vec2 depthValues;
}
light0;
#define CUSTOM_VERTEX_DEFINITIONS
void main(void) {
    #define CUSTOM_VERTEX_MAIN_BEGIN
    vec3 positionUpdated = position;
    vec3 normalUpdated = normal;
    #define CUSTOM_VERTEX_UPDATE_POSITION
    #define CUSTOM_VERTEX_UPDATE_NORMAL
    mat4 finalWorld = world;
    vec4 worldPos = finalWorld*vec4(positionUpdated, 1.0);
    mat3 normalWorld = mat3(finalWorld);
    vNormalW = normalize(normalWorld*normalUpdated);
    #define CUSTOM_VERTEX_UPDATE_WORLDPOS
    gl_Position = viewProjection*worldPos;
    vPositionW = vec3(worldPos);
    vec2 uvUpdated = vec2(0., 0.);
    vec2 uv2 = vec2(0., 0.);
    #define CUSTOM_VERTEX_MAIN_END
}
