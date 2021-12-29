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
#define LIGHT1
#define HEMILIGHT1

#define SHADER_NAME fragment:default
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
#define CUSTOM_FRAGMENT_BEGIN
#define RECIPROCAL_PI2 0.15915494
uniform vec3 vEyePosition;
uniform vec3 vAmbientColor;
in vec3 vPositionW;
in vec3 vNormalW;
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
uniform Light0 {
    vec4 vLightData;
    vec4 vLightDiffuse;
    vec4 vLightSpecular;
    vec3 vLightGround;
    vec4 shadowsInfo;
    vec2 depthValues;
}
light0;
uniform Light1 {
    vec4 vLightData;
    vec4 vLightDiffuse;
    vec4 vLightSpecular;
    vec3 vLightGround;
    vec4 shadowsInfo;
    vec2 depthValues;
}
light1;
struct lightingInfo {
    vec3 diffuse;
    vec3 specular;
};
lightingInfo computeLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec3 diffuseColor, vec3 specularColor, float range, float glossiness) {
    lightingInfo result;
    vec3 lightVectorW;
    float attenuation = 1.0;
    if (lightData.w == 0.) {
        vec3 direction = lightData.xyz-vPositionW;
        attenuation = max(0., 1.0-length(direction)/range);
        lightVectorW = normalize(direction);
    }
    else {
        lightVectorW = normalize(-lightData.xyz);
    }
    float ndl = max(0., dot(vNormal, lightVectorW));
    result.diffuse = ndl*diffuseColor*attenuation;
    vec3 angleW = normalize(viewDirectionW+lightVectorW);
    float specComp = max(0., dot(vNormal, angleW));
    specComp = pow(specComp, max(1., glossiness));
    result.specular = specComp*specularColor*attenuation;
    return result;
}
lightingInfo computeSpotLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec4 lightDirection, vec3 diffuseColor, vec3 specularColor, float range, float glossiness) {
    lightingInfo result;
    vec3 direction = lightData.xyz-vPositionW;
    vec3 lightVectorW = normalize(direction);
    float attenuation = max(0., 1.0-length(direction)/range);
    float cosAngle = max(0., dot(lightDirection.xyz, -lightVectorW));
    if (cosAngle >= lightDirection.w) {
        cosAngle = max(0., pow(cosAngle, lightData.w));
        attenuation *= cosAngle;
        float ndl = max(0., dot(vNormal, lightVectorW));
        result.diffuse = ndl*diffuseColor*attenuation;
        vec3 angleW = normalize(viewDirectionW+lightVectorW);
        float specComp = max(0., dot(vNormal, angleW));
        specComp = pow(specComp, max(1., glossiness));
        result.specular = specComp*specularColor*attenuation;
        return result;
    }
    result.diffuse = vec3(0.);
    result.specular = vec3(0.);
    return result;
}
lightingInfo computeHemisphericLighting(vec3 viewDirectionW, vec3 vNormal, vec4 lightData, vec3 diffuseColor, vec3 specularColor, vec3 groundColor, float glossiness) {
    lightingInfo result;
    float ndl = dot(vNormal, lightData.xyz)*0.5+0.5;
    result.diffuse = mix(groundColor, diffuseColor, ndl);
    vec3 angleW = normalize(viewDirectionW+lightData.xyz);
    float specComp = max(0., dot(vNormal, angleW));
    specComp = pow(specComp, max(1., glossiness));
    result.specular = specComp*specularColor;
    return result;
}
#define inline
vec3 computeProjectionTextureDiffuseLighting(sampler2D projectionLightSampler, mat4 textureProjectionMatrix) {
    vec4 strq = textureProjectionMatrix*vec4(vPositionW, 1.0);
    strq /= strq.w;
    vec3 textureColor = texture(projectionLightSampler, strq.xy).rgb;
    return textureColor;
}
vec4 applyImageProcessing(vec4 result) {
    result.rgb = toGammaSpace(result.rgb);
    result.rgb = saturate(result.rgb);
    return result;
}
#define CUSTOM_FRAGMENT_DEFINITIONS
out vec4 glFragColor;
void main(void) {
    #define CUSTOM_FRAGMENT_MAIN_BEGIN
    vec3 viewDirectionW = normalize(vEyePosition-vPositionW);
    vec4 baseColor = vec4(1., 1., 1., 1.);
    vec3 diffuseColor = vDiffuseColor.rgb;
    float alpha = vDiffuseColor.a;
    vec3 normalW = normalize(vNormalW);
    vec2 uvOffset = vec2(0.0, 0.0);
    #define CUSTOM_FRAGMENT_UPDATE_DIFFUSE
    vec3 baseAmbientColor = vec3(1., 1., 1.);
    #define CUSTOM_FRAGMENT_BEFORE_LIGHTS
    float glossiness = vSpecularColor.a;
    vec3 specularColor = vSpecularColor.rgb;
    vec3 diffuseBase = vec3(0., 0., 0.);
    lightingInfo info;
    vec3 specularBase = vec3(0., 0., 0.);
    float shadow = 1.;
    info = computeHemisphericLighting(viewDirectionW, normalW, light0.vLightData, light0.vLightDiffuse.rgb, light0.vLightSpecular.rgb, light0.vLightGround, glossiness);
    shadow = 1.;
    diffuseBase += info.diffuse*shadow;
    specularBase += info.specular*shadow;
    info = computeHemisphericLighting(viewDirectionW, normalW, light1.vLightData, light1.vLightDiffuse.rgb, light1.vLightSpecular.rgb, light1.vLightGround, glossiness);
    shadow = 1.;
    diffuseBase += info.diffuse*shadow;
    specularBase += info.specular*shadow;
    vec4 refractionColor = vec4(0., 0., 0., 1.);
    vec4 reflectionColor = vec4(0., 0., 0., 1.);
    vec3 emissiveColor = vEmissiveColor;
    vec3 finalDiffuse = clamp(diffuseBase*diffuseColor+emissiveColor+vAmbientColor, 0.0, 1.0)*baseColor.rgb;
    vec3 finalSpecular = specularBase*specularColor;
    vec4 color = vec4(finalDiffuse*baseAmbientColor+finalSpecular+reflectionColor.rgb+refractionColor.rgb, alpha);
    #define CUSTOM_FRAGMENT_BEFORE_FOG
    color.rgb = max(color.rgb, 0.);
    color.a *= visibility;
    #define CUSTOM_FRAGMENT_BEFORE_FRAGCOLOR
    glFragColor = color;
}
