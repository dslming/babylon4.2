import { Effect } from "../../Materials/effect";

let name = 'pbrHelperFunctions';
let shader = `
#define RECIPROCAL_PI2 0.15915494
#define RECIPROCAL_PI 0.31830988618

#define MINIMUMVARIANCE 0.0005
float convertRoughnessToAverageSlope(float roughness)
{

return square(roughness)+MINIMUMVARIANCE;
}
float fresnelGrazingReflectance(float reflectance0) {


float reflectance90=saturate(reflectance0*25.0);
return reflectance90;
}
vec2 getAARoughnessFactors(vec3 normalVector) {
#ifdef SPECULARAA
vec3 nDfdx=dFdx(normalVector.xyz);
vec3 nDfdy=dFdy(normalVector.xyz);
float slopeSquare=max(dot(nDfdx,nDfdx),dot(nDfdy,nDfdy));

float geometricRoughnessFactor=pow(saturate(slopeSquare),0.333);

float geometricAlphaGFactor=sqrt(slopeSquare);

geometricAlphaGFactor*=0.75;
return vec2(geometricRoughnessFactor,geometricAlphaGFactor);
#else
return vec2(0.);
#endif
}
#ifdef ANISOTROPIC


vec2 getAnisotropicRoughness(float alphaG,float anisotropy) {
float alphaT=max(alphaG*(1.0+anisotropy),MINIMUMVARIANCE);
float alphaB=max(alphaG*(1.0-anisotropy),MINIMUMVARIANCE);
return vec2(alphaT,alphaB);
}


vec3 getAnisotropicBentNormals(const vec3 T,const vec3 B,const vec3 N,const vec3 V,float anisotropy) {
vec3 anisotropicFrameDirection=anisotropy>=0.0 ? B : T;
vec3 anisotropicFrameTangent=cross(normalize(anisotropicFrameDirection),V);
vec3 anisotropicFrameNormal=cross(anisotropicFrameTangent,anisotropicFrameDirection);
vec3 anisotropicNormal=normalize(mix(N,anisotropicFrameNormal,abs(anisotropy)));
return anisotropicNormal;

}
#endif
#if defined(CLEARCOAT) || defined(SS_REFRACTION)



vec3 cocaLambert(vec3 alpha,float distance) {
return exp(-alpha*distance);
}

vec3 cocaLambert(float NdotVRefract,float NdotLRefract,vec3 alpha,float thickness) {
return cocaLambert(alpha,(thickness*((NdotLRefract+NdotVRefract)/(NdotLRefract*NdotVRefract))));
}

vec3 computeColorAtDistanceInMedia(vec3 color,float distance) {
return -log(color)/distance;
}
vec3 computeClearCoatAbsorption(float NdotVRefract,float NdotLRefract,vec3 clearCoatColor,float clearCoatThickness,float clearCoatIntensity) {
vec3 clearCoatAbsorption=mix(vec3(1.0),
cocaLambert(NdotVRefract,NdotLRefract,clearCoatColor,clearCoatThickness),
clearCoatIntensity);
return clearCoatAbsorption;
}
#endif




#ifdef MICROSURFACEAUTOMATIC
float computeDefaultMicroSurface(float microSurface,vec3 reflectivityColor)
{
const float kReflectivityNoAlphaWorkflow_SmoothnessMax=0.95;
float reflectivityLuminance=getLuminance(reflectivityColor);
float reflectivityLuma=sqrt(reflectivityLuminance);
microSurface=reflectivityLuma*kReflectivityNoAlphaWorkflow_SmoothnessMax;
return microSurface;
}
#endif`;

Effect.IncludesShadersStore[name] = shader;
/** @hidden */
export var pbrHelperFunctions = { name, shader };
