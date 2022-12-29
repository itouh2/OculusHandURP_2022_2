Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
             HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //Lighting.hlslがライト情報を格納するコアpackage
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 color : COLOR0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 color : COLOR0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz); 
                float3 normalWS = TransformObjectToWorldNormal(v.normal); 
                float3 vertexLight = VertexLighting(positionWS, normalWS);
                o.color = vertexLight;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return half4(i.color.x, 0, 0, i.color.x);
            }
            ENDHLSL
        }
    }
}
