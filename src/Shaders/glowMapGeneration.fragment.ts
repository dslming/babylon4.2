import { Effect } from "../Materials/effect";

let name = 'glowMapGenerationPixelShader';
let shader = `#ifdef DIFFUSE
varying vec2 vUVDiffuse;
uniform sampler2D diffuseSampler;
#endif
#ifdef OPACITY
varying vec2 vUVOpacity;
uniform sampler2D opacitySampler;
uniform float opacityIntensity;
#endif
#ifdef EMISSIVE
varying vec2 vUVEmissive;
uniform sampler2D emissiveSampler;
#endif
#ifdef VERTEXALPHA
varying vec4 vColor;
#endif
uniform vec4 glowColor;
void main(void)
{
vec4 finalColor=glowColor;

#ifdef DIFFUSE
vec4 albedoTexture=texture2D(diffuseSampler,vUVDiffuse);
#ifdef GLOW

finalColor.a*=albedoTexture.a;
#endif
#ifdef HIGHLIGHT

finalColor.a=albedoTexture.a;
#endif
#endif
#ifdef OPACITY
vec4 opacityMap=texture2D(opacitySampler,vUVOpacity);
#ifdef OPACITYRGB
finalColor.a*=getLuminance(opacityMap.rgb);
#else
finalColor.a*=opacityMap.a;
#endif
finalColor.a*=opacityIntensity;
#endif
#ifdef VERTEXALPHA
finalColor.a*=vColor.a;
#endif
#ifdef ALPHATEST
if (finalColor.a<ALPHATESTVALUE)
discard;
#endif
#ifdef EMISSIVE
gl_FragColor=texture2D(emissiveSampler,vUVEmissive)*finalColor;
#else
gl_FragColor=finalColor;
#endif
#ifdef HIGHLIGHT

gl_FragColor.a=glowColor.a;
#endif
}`;

Effect.ShadersStore[name] = shader;
/** @hidden */
export var glowMapGenerationPixelShader = { name, shader };
