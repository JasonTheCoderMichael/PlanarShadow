Shader "MJ/PlanarShadow"
{
    Properties
    {
        _PlanarShadowColor("Planar Shadow Color", Color) = (1,1,1,1)
        _PlanePosY("Plane Pos Y", float) = 0
        _MainTex ("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4x4 _Matrix_Test;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }

        Pass
        {
            Name "Planar Shadow"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _PlanarShadowColor;
            float _PlanePosY;
            float3 _PlaneNormal;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            // v2f vert (appdata v)
            // {
            //     v2f o;
            //     float3 posWS = mul(unity_ObjectToWorld, v.vertex).xyz;
            //     float3 n = float3(0, 1, 0);
            //     posWS.y = max(posWS.y, _PlanePosY);
            //     float3 lightDir = normalize(UnityWorldSpaceLightDir(posWS));
            //     float dist = (posWS.y - _PlanePosY)/dot(lightDir, -n);
            //     float3 posWS_New = posWS + lightDir * dist;
            //     o.vertex = UnityWorldToClipPos(posWS_New);
            //     return o;
            // }

            v2f vert (appdata v)
            {
                v2f o;
                float3 posWS = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 p0 = float3(0, 0.01, 0);
                
                float3 n = normalize(_PlaneNormal);
                float3 lightDir = normalize(-UnityWorldSpaceLightDir(posWS));

                // dot(A - B, C) = dot(A, C) - dot(B, C) //
                // float dist = (dot(posWS, n) - dot(p0, n))/dot(lightDir, -n);
                float dist = dot(p0 - posWS, -n)/dot(lightDir, -n);
                float3 posWS_New = posWS + lightDir * dist;
                posWS_New = lerp(posWS, posWS_New, dist>0);     // 如果点在平面背部，则不修改 //
                o.vertex = UnityWorldToClipPos(posWS_New);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return _PlanarShadowColor;
            }
            ENDCG
        }
    }
}
