Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
            "Queue" = "Geometry"
        }
        LOD 100
        BLEND SrcAlpha ZERO

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 color : COLOR0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 color : COLOR0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half3 VertexLightingTmp(float3 positionWS, half3 normalWS)
            {
                half3 vertexLightColor = half3(0.0, 0.0, 0.0);

                uint lightsCount = GetAdditionalLightsCount();
                LIGHT_LOOP_BEGIN(lightsCount)
                    Light light = GetAdditionalLight(lightIndex, positionWS);
                    half3 lightColor = light.color * light.distanceAttenuation;
                    vertexLightColor += LightingLambert(lightColor, light.direction, normalWS)*1.4;
                LIGHT_LOOP_END

                return vertexLightColor;
            }

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v); //挿入
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o); //挿入
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                const float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 normalWS = TransformObjectToWorldNormal(v.normal);
                float3 vertexLight = VertexLightingTmp(positionWS, normalWS);
                o.color = vertexLight;
                // o.color = float3(0.5*GetAdditionalLightsCount(), 0, 0);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return half4(i.color.x, i.color.y, i.color.z, i.color.y);
            }
            ENDHLSL
        }
    }
}