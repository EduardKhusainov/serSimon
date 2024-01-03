Shader "Clouds"
{
    Properties
    {
        _Vector4("Vector4", Vector) = (1, 0, 0, 0)
        _Noise_Scale("Noise Scale", Float) = 9.1
        _Noise_Speed("Noise Speed", Float) = 0.1
        _Wave_Power("Wave Power", Float) = 0.3
        _Noise_remap("Noise remap", Vector) = (0, 1, -1, 1)
        [HDR]_Color_Peak("Color Peak", Color) = (0.1902368, 0.8579263, 0.8962264, 0)
        [HDR]_Color_Valley("Color Valley", Color) = (0.3083838, 0.3789095, 0.3962264, 0)
        _Noise_Edge_1("Noise Edge_1", Float) = 1.4
        _Noise_Edge_2("Noise Edge_2", Float) = -0.37
        _Noise_Power("Noise Power", Float) = 1
        _Base_Scale("Base Scale", Float) = 5
        _Base_Speed("Base Speed", Float) = 0.2
        _Base_Strength("Base Strength", Float) = 2
        _Emission_Strength("Emission Strength", Float) = 0.5
        _Fade_Depth("Fade Depth", Float) = 50
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        #define _RECEIVE_SHADOWS_OFF 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 fogFactorAndVertexLight : INTERP5;
             float3 positionWS : INTERP6;
             float3 normalWS : INTERP7;
             float3 viewDirectionWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            output.viewDirectionWS.xyz = input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            output.viewDirectionWS = input.viewDirectionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Vector4;
        float _Noise_Scale;
        float _Noise_Speed;
        float _Wave_Power;
        float4 _Noise_remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float3 _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxx), _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2);
            float _Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0 = _Wave_Power;
            float3 _Multiply_44326421fae14295b263bd0e303abac4_Out_2;
            Unity_Multiply_float3_float3(_Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2, (_Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0.xxx), _Multiply_44326421fae14295b263bd0e303abac4_Out_2);
            float3 _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_44326421fae14295b263bd0e303abac4_Out_2, _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2);
            description.Position = _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba583cc797d840689c683c09e8849329_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Peak) : _Color_Peak;
            float4 _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Valley) : _Color_Valley;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float4 _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3;
            Unity_Lerp_float4(_Property_ba583cc797d840689c683c09e8849329_Out_0, _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxxx), _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3);
            float _Property_bab22ee5e7804a31adb4e31adbaa740e_Out_0 = _Emission_Strength;
            float4 _Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2;
            Unity_Multiply_float4_float4(_Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3, (_Property_bab22ee5e7804a31adb4e31adbaa740e_Out_0.xxxx), _Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2);
            float _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1);
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_R_1 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_G_2 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_B_3 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4 = 0;
            float _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2;
            Unity_Subtract_float(_Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4, 1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2);
            float _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2;
            Unity_Subtract_float(_SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2, _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2);
            float _Property_18142e5433da4239ab181ca6ea2d946e_Out_0 = _Fade_Depth;
            float _Divide_2249a86b76794140bfae1af272018ca8_Out_2;
            Unity_Divide_float(_Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2, _Property_18142e5433da4239ab181ca6ea2d946e_Out_0, _Divide_2249a86b76794140bfae1af272018ca8_Out_2);
            float _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            Unity_Saturate_float(_Divide_2249a86b76794140bfae1af272018ca8_Out_2, _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1);
            surface.BaseColor = (_Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        #define _RECEIVE_SHADOWS_OFF 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 fogFactorAndVertexLight : INTERP5;
             float3 positionWS : INTERP6;
             float3 normalWS : INTERP7;
             float3 viewDirectionWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            output.viewDirectionWS.xyz = input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            output.viewDirectionWS = input.viewDirectionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Vector4;
        float _Noise_Scale;
        float _Noise_Speed;
        float _Wave_Power;
        float4 _Noise_remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float3 _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxx), _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2);
            float _Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0 = _Wave_Power;
            float3 _Multiply_44326421fae14295b263bd0e303abac4_Out_2;
            Unity_Multiply_float3_float3(_Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2, (_Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0.xxx), _Multiply_44326421fae14295b263bd0e303abac4_Out_2);
            float3 _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_44326421fae14295b263bd0e303abac4_Out_2, _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2);
            description.Position = _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba583cc797d840689c683c09e8849329_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Peak) : _Color_Peak;
            float4 _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Valley) : _Color_Valley;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float4 _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3;
            Unity_Lerp_float4(_Property_ba583cc797d840689c683c09e8849329_Out_0, _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxxx), _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3);
            float _Property_bab22ee5e7804a31adb4e31adbaa740e_Out_0 = _Emission_Strength;
            float4 _Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2;
            Unity_Multiply_float4_float4(_Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3, (_Property_bab22ee5e7804a31adb4e31adbaa740e_Out_0.xxxx), _Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2);
            float _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1);
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_R_1 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_G_2 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_B_3 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4 = 0;
            float _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2;
            Unity_Subtract_float(_Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4, 1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2);
            float _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2;
            Unity_Subtract_float(_SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2, _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2);
            float _Property_18142e5433da4239ab181ca6ea2d946e_Out_0 = _Fade_Depth;
            float _Divide_2249a86b76794140bfae1af272018ca8_Out_2;
            Unity_Divide_float(_Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2, _Property_18142e5433da4239ab181ca6ea2d946e_Out_0, _Divide_2249a86b76794140bfae1af272018ca8_Out_2);
            float _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            Unity_Saturate_float(_Divide_2249a86b76794140bfae1af272018ca8_Out_2, _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1);
            surface.BaseColor = (_Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float3 positionWS : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Vector4;
        float _Noise_Scale;
        float _Noise_Speed;
        float _Wave_Power;
        float4 _Noise_remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float3 _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxx), _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2);
            float _Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0 = _Wave_Power;
            float3 _Multiply_44326421fae14295b263bd0e303abac4_Out_2;
            Unity_Multiply_float3_float3(_Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2, (_Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0.xxx), _Multiply_44326421fae14295b263bd0e303abac4_Out_2);
            float3 _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_44326421fae14295b263bd0e303abac4_Out_2, _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2);
            description.Position = _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1);
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_R_1 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_G_2 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_B_3 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4 = 0;
            float _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2;
            Unity_Subtract_float(_Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4, 1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2);
            float _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2;
            Unity_Subtract_float(_SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2, _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2);
            float _Property_18142e5433da4239ab181ca6ea2d946e_Out_0 = _Fade_Depth;
            float _Divide_2249a86b76794140bfae1af272018ca8_Out_2;
            Unity_Divide_float(_Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2, _Property_18142e5433da4239ab181ca6ea2d946e_Out_0, _Divide_2249a86b76794140bfae1af272018ca8_Out_2);
            float _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            Unity_Saturate_float(_Divide_2249a86b76794140bfae1af272018ca8_Out_2, _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float3 positionWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Vector4;
        float _Noise_Scale;
        float _Noise_Speed;
        float _Wave_Power;
        float4 _Noise_remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float3 _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxx), _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2);
            float _Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0 = _Wave_Power;
            float3 _Multiply_44326421fae14295b263bd0e303abac4_Out_2;
            Unity_Multiply_float3_float3(_Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2, (_Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0.xxx), _Multiply_44326421fae14295b263bd0e303abac4_Out_2);
            float3 _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_44326421fae14295b263bd0e303abac4_Out_2, _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2);
            description.Position = _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba583cc797d840689c683c09e8849329_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Peak) : _Color_Peak;
            float4 _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Valley) : _Color_Valley;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float4 _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3;
            Unity_Lerp_float4(_Property_ba583cc797d840689c683c09e8849329_Out_0, _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxxx), _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3);
            float _Property_bab22ee5e7804a31adb4e31adbaa740e_Out_0 = _Emission_Strength;
            float4 _Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2;
            Unity_Multiply_float4_float4(_Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3, (_Property_bab22ee5e7804a31adb4e31adbaa740e_Out_0.xxxx), _Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2);
            float _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1);
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_R_1 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_G_2 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_B_3 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4 = 0;
            float _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2;
            Unity_Subtract_float(_Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4, 1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2);
            float _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2;
            Unity_Subtract_float(_SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2, _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2);
            float _Property_18142e5433da4239ab181ca6ea2d946e_Out_0 = _Fade_Depth;
            float _Divide_2249a86b76794140bfae1af272018ca8_Out_2;
            Unity_Divide_float(_Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2, _Property_18142e5433da4239ab181ca6ea2d946e_Out_0, _Divide_2249a86b76794140bfae1af272018ca8_Out_2);
            float _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            Unity_Saturate_float(_Divide_2249a86b76794140bfae1af272018ca8_Out_2, _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1);
            surface.BaseColor = (_Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3.xyz);
            surface.Emission = (_Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2.xyz);
            surface.Alpha = _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Vector4;
        float _Noise_Scale;
        float _Noise_Speed;
        float _Wave_Power;
        float4 _Noise_remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float3 _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxx), _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2);
            float _Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0 = _Wave_Power;
            float3 _Multiply_44326421fae14295b263bd0e303abac4_Out_2;
            Unity_Multiply_float3_float3(_Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2, (_Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0.xxx), _Multiply_44326421fae14295b263bd0e303abac4_Out_2);
            float3 _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_44326421fae14295b263bd0e303abac4_Out_2, _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2);
            description.Position = _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1);
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_R_1 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_G_2 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_B_3 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4 = 0;
            float _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2;
            Unity_Subtract_float(_Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4, 1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2);
            float _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2;
            Unity_Subtract_float(_SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2, _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2);
            float _Property_18142e5433da4239ab181ca6ea2d946e_Out_0 = _Fade_Depth;
            float _Divide_2249a86b76794140bfae1af272018ca8_Out_2;
            Unity_Divide_float(_Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2, _Property_18142e5433da4239ab181ca6ea2d946e_Out_0, _Divide_2249a86b76794140bfae1af272018ca8_Out_2);
            float _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            Unity_Saturate_float(_Divide_2249a86b76794140bfae1af272018ca8_Out_2, _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1);
            surface.Alpha = _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Vector4;
        float _Noise_Scale;
        float _Noise_Speed;
        float _Wave_Power;
        float4 _Noise_remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float3 _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxx), _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2);
            float _Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0 = _Wave_Power;
            float3 _Multiply_44326421fae14295b263bd0e303abac4_Out_2;
            Unity_Multiply_float3_float3(_Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2, (_Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0.xxx), _Multiply_44326421fae14295b263bd0e303abac4_Out_2);
            float3 _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_44326421fae14295b263bd0e303abac4_Out_2, _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2);
            description.Position = _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1);
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_R_1 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_G_2 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_B_3 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4 = 0;
            float _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2;
            Unity_Subtract_float(_Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4, 1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2);
            float _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2;
            Unity_Subtract_float(_SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2, _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2);
            float _Property_18142e5433da4239ab181ca6ea2d946e_Out_0 = _Fade_Depth;
            float _Divide_2249a86b76794140bfae1af272018ca8_Out_2;
            Unity_Divide_float(_Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2, _Property_18142e5433da4239ab181ca6ea2d946e_Out_0, _Divide_2249a86b76794140bfae1af272018ca8_Out_2);
            float _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            Unity_Saturate_float(_Divide_2249a86b76794140bfae1af272018ca8_Out_2, _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1);
            surface.Alpha = _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Vector4;
        float _Noise_Scale;
        float _Noise_Speed;
        float _Wave_Power;
        float4 _Noise_remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float3 _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxx), _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2);
            float _Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0 = _Wave_Power;
            float3 _Multiply_44326421fae14295b263bd0e303abac4_Out_2;
            Unity_Multiply_float3_float3(_Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2, (_Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0.xxx), _Multiply_44326421fae14295b263bd0e303abac4_Out_2);
            float3 _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_44326421fae14295b263bd0e303abac4_Out_2, _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2);
            description.Position = _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba583cc797d840689c683c09e8849329_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Peak) : _Color_Peak;
            float4 _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Valley) : _Color_Valley;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float4 _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3;
            Unity_Lerp_float4(_Property_ba583cc797d840689c683c09e8849329_Out_0, _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxxx), _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3);
            float _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1);
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_R_1 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_G_2 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_B_3 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4 = 0;
            float _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2;
            Unity_Subtract_float(_Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4, 1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2);
            float _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2;
            Unity_Subtract_float(_SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2, _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2);
            float _Property_18142e5433da4239ab181ca6ea2d946e_Out_0 = _Fade_Depth;
            float _Divide_2249a86b76794140bfae1af272018ca8_Out_2;
            Unity_Divide_float(_Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2, _Property_18142e5433da4239ab181ca6ea2d946e_Out_0, _Divide_2249a86b76794140bfae1af272018ca8_Out_2);
            float _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            Unity_Saturate_float(_Divide_2249a86b76794140bfae1af272018ca8_Out_2, _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1);
            surface.BaseColor = (_Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3.xyz);
            surface.Alpha = _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        #define _RECEIVE_SHADOWS_OFF 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 fogFactorAndVertexLight : INTERP5;
             float3 positionWS : INTERP6;
             float3 normalWS : INTERP7;
             float3 viewDirectionWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            output.viewDirectionWS.xyz = input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            output.viewDirectionWS = input.viewDirectionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Vector4;
        float _Noise_Scale;
        float _Noise_Speed;
        float _Wave_Power;
        float4 _Noise_remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float3 _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxx), _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2);
            float _Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0 = _Wave_Power;
            float3 _Multiply_44326421fae14295b263bd0e303abac4_Out_2;
            Unity_Multiply_float3_float3(_Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2, (_Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0.xxx), _Multiply_44326421fae14295b263bd0e303abac4_Out_2);
            float3 _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_44326421fae14295b263bd0e303abac4_Out_2, _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2);
            description.Position = _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba583cc797d840689c683c09e8849329_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Peak) : _Color_Peak;
            float4 _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Valley) : _Color_Valley;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float4 _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3;
            Unity_Lerp_float4(_Property_ba583cc797d840689c683c09e8849329_Out_0, _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxxx), _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3);
            float _Property_bab22ee5e7804a31adb4e31adbaa740e_Out_0 = _Emission_Strength;
            float4 _Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2;
            Unity_Multiply_float4_float4(_Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3, (_Property_bab22ee5e7804a31adb4e31adbaa740e_Out_0.xxxx), _Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2);
            float _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1);
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_R_1 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_G_2 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_B_3 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4 = 0;
            float _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2;
            Unity_Subtract_float(_Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4, 1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2);
            float _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2;
            Unity_Subtract_float(_SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2, _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2);
            float _Property_18142e5433da4239ab181ca6ea2d946e_Out_0 = _Fade_Depth;
            float _Divide_2249a86b76794140bfae1af272018ca8_Out_2;
            Unity_Divide_float(_Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2, _Property_18142e5433da4239ab181ca6ea2d946e_Out_0, _Divide_2249a86b76794140bfae1af272018ca8_Out_2);
            float _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            Unity_Saturate_float(_Divide_2249a86b76794140bfae1af272018ca8_Out_2, _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1);
            surface.BaseColor = (_Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 1;
            surface.Alpha = _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Off
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float3 positionWS : INTERP1;
             float3 normalWS : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Vector4;
        float _Noise_Scale;
        float _Noise_Speed;
        float _Wave_Power;
        float4 _Noise_remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float3 _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxx), _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2);
            float _Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0 = _Wave_Power;
            float3 _Multiply_44326421fae14295b263bd0e303abac4_Out_2;
            Unity_Multiply_float3_float3(_Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2, (_Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0.xxx), _Multiply_44326421fae14295b263bd0e303abac4_Out_2);
            float3 _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_44326421fae14295b263bd0e303abac4_Out_2, _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2);
            description.Position = _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1);
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_R_1 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_G_2 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_B_3 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4 = 0;
            float _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2;
            Unity_Subtract_float(_Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4, 1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2);
            float _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2;
            Unity_Subtract_float(_SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2, _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2);
            float _Property_18142e5433da4239ab181ca6ea2d946e_Out_0 = _Fade_Depth;
            float _Divide_2249a86b76794140bfae1af272018ca8_Out_2;
            Unity_Divide_float(_Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2, _Property_18142e5433da4239ab181ca6ea2d946e_Out_0, _Divide_2249a86b76794140bfae1af272018ca8_Out_2);
            float _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            Unity_Saturate_float(_Divide_2249a86b76794140bfae1af272018ca8_Out_2, _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float3 positionWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Vector4;
        float _Noise_Scale;
        float _Noise_Speed;
        float _Wave_Power;
        float4 _Noise_remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float3 _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxx), _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2);
            float _Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0 = _Wave_Power;
            float3 _Multiply_44326421fae14295b263bd0e303abac4_Out_2;
            Unity_Multiply_float3_float3(_Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2, (_Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0.xxx), _Multiply_44326421fae14295b263bd0e303abac4_Out_2);
            float3 _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_44326421fae14295b263bd0e303abac4_Out_2, _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2);
            description.Position = _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba583cc797d840689c683c09e8849329_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Peak) : _Color_Peak;
            float4 _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Valley) : _Color_Valley;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float4 _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3;
            Unity_Lerp_float4(_Property_ba583cc797d840689c683c09e8849329_Out_0, _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxxx), _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3);
            float _Property_bab22ee5e7804a31adb4e31adbaa740e_Out_0 = _Emission_Strength;
            float4 _Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2;
            Unity_Multiply_float4_float4(_Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3, (_Property_bab22ee5e7804a31adb4e31adbaa740e_Out_0.xxxx), _Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2);
            float _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1);
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_R_1 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_G_2 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_B_3 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4 = 0;
            float _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2;
            Unity_Subtract_float(_Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4, 1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2);
            float _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2;
            Unity_Subtract_float(_SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2, _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2);
            float _Property_18142e5433da4239ab181ca6ea2d946e_Out_0 = _Fade_Depth;
            float _Divide_2249a86b76794140bfae1af272018ca8_Out_2;
            Unity_Divide_float(_Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2, _Property_18142e5433da4239ab181ca6ea2d946e_Out_0, _Divide_2249a86b76794140bfae1af272018ca8_Out_2);
            float _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            Unity_Saturate_float(_Divide_2249a86b76794140bfae1af272018ca8_Out_2, _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1);
            surface.BaseColor = (_Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3.xyz);
            surface.Emission = (_Multiply_ace2292dcaae47c98d3263dfdd2fed97_Out_2.xyz);
            surface.Alpha = _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Vector4;
        float _Noise_Scale;
        float _Noise_Speed;
        float _Wave_Power;
        float4 _Noise_remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float3 _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxx), _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2);
            float _Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0 = _Wave_Power;
            float3 _Multiply_44326421fae14295b263bd0e303abac4_Out_2;
            Unity_Multiply_float3_float3(_Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2, (_Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0.xxx), _Multiply_44326421fae14295b263bd0e303abac4_Out_2);
            float3 _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_44326421fae14295b263bd0e303abac4_Out_2, _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2);
            description.Position = _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1);
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_R_1 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_G_2 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_B_3 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4 = 0;
            float _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2;
            Unity_Subtract_float(_Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4, 1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2);
            float _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2;
            Unity_Subtract_float(_SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2, _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2);
            float _Property_18142e5433da4239ab181ca6ea2d946e_Out_0 = _Fade_Depth;
            float _Divide_2249a86b76794140bfae1af272018ca8_Out_2;
            Unity_Divide_float(_Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2, _Property_18142e5433da4239ab181ca6ea2d946e_Out_0, _Divide_2249a86b76794140bfae1af272018ca8_Out_2);
            float _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            Unity_Saturate_float(_Divide_2249a86b76794140bfae1af272018ca8_Out_2, _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1);
            surface.Alpha = _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Vector4;
        float _Noise_Scale;
        float _Noise_Speed;
        float _Wave_Power;
        float4 _Noise_remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float3 _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxx), _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2);
            float _Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0 = _Wave_Power;
            float3 _Multiply_44326421fae14295b263bd0e303abac4_Out_2;
            Unity_Multiply_float3_float3(_Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2, (_Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0.xxx), _Multiply_44326421fae14295b263bd0e303abac4_Out_2);
            float3 _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_44326421fae14295b263bd0e303abac4_Out_2, _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2);
            description.Position = _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1);
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_R_1 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_G_2 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_B_3 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4 = 0;
            float _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2;
            Unity_Subtract_float(_Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4, 1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2);
            float _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2;
            Unity_Subtract_float(_SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2, _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2);
            float _Property_18142e5433da4239ab181ca6ea2d946e_Out_0 = _Fade_Depth;
            float _Divide_2249a86b76794140bfae1af272018ca8_Out_2;
            Unity_Divide_float(_Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2, _Property_18142e5433da4239ab181ca6ea2d946e_Out_0, _Divide_2249a86b76794140bfae1af272018ca8_Out_2);
            float _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            Unity_Saturate_float(_Divide_2249a86b76794140bfae1af272018ca8_Out_2, _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1);
            surface.Alpha = _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        #define REQUIRE_DEPTH_TEXTURE
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 ObjectSpacePosition;
             float3 WorldSpacePosition;
             float4 ScreenPosition;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Vector4;
        float _Noise_Scale;
        float _Noise_Speed;
        float _Wave_Power;
        float4 _Noise_remap;
        float4 _Color_Peak;
        float4 _Color_Valley;
        float _Noise_Edge_1;
        float _Noise_Edge_2;
        float _Noise_Power;
        float _Base_Scale;
        float _Base_Speed;
        float _Base_Strength;
        float _Emission_Strength;
        float _Fade_Depth;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            Rotation = radians(Rotation);
        
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
        
            float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };
        
            Out = mul(rot_mat,  In);
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        
        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }
        
        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        {
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            if (unity_OrthoParams.w == 1.0)
            {
                Out = LinearEyeDepth(ComputeWorldSpacePosition(UV.xy, SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), UNITY_MATRIX_I_VP), UNITY_MATRIX_V);
            }
            else
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float3 _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxx), _Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2);
            float _Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0 = _Wave_Power;
            float3 _Multiply_44326421fae14295b263bd0e303abac4_Out_2;
            Unity_Multiply_float3_float3(_Multiply_ee405634aaa84cd0a962c3ac8a7d5895_Out_2, (_Property_3aa1ad4fc2b84fe58043ae43485e31d2_Out_0.xxx), _Multiply_44326421fae14295b263bd0e303abac4_Out_2);
            float3 _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_44326421fae14295b263bd0e303abac4_Out_2, _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2);
            description.Position = _Add_7a564685cd284d4cbfe5f845ca4869d3_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_ba583cc797d840689c683c09e8849329_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Peak) : _Color_Peak;
            float4 _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color_Valley) : _Color_Valley;
            float _Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0 = _Noise_Edge_1;
            float _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0 = _Noise_Edge_2;
            float4 _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0 = _Vector4;
            float _Split_a90e98acd0a045388f237adace80a5d0_R_1 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[0];
            float _Split_a90e98acd0a045388f237adace80a5d0_G_2 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[1];
            float _Split_a90e98acd0a045388f237adace80a5d0_B_3 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[2];
            float _Split_a90e98acd0a045388f237adace80a5d0_A_4 = _Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0[3];
            float3 _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3;
            Unity_Rotate_About_Axis_Degrees_float(IN.ObjectSpacePosition, (_Property_8cd57dee6bf24acf9b67c651ed52149f_Out_0.xyz), _Split_a90e98acd0a045388f237adace80a5d0_A_4, _RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3);
            float _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0 = _Noise_Speed;
            float _Multiply_8473280d70684b83865d494386ef8643_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_f4082d2abc2f4d898cee881d2dbbf80b_Out_0, _Multiply_8473280d70684b83865d494386ef8643_Out_2);
            float2 _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_8473280d70684b83865d494386ef8643_Out_2.xx), _TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3);
            float _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0 = _Noise_Scale;
            float _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_8ae9dfada965414581546ee992dbfbc5_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2);
            float2 _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3);
            float _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d0d0ad20c1124716850860973d422060_Out_3, _Property_76f1c97bdd234aa2971255aec5e593ee_Out_0, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2);
            float _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2;
            Unity_Add_float(_GradientNoise_c59944bdf54b4015aaef64ffe489a1e7_Out_2, _GradientNoise_7cfa4c205d62417382c4c59eacf25151_Out_2, _Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2);
            float _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2;
            Unity_Divide_float(_Add_e0ed042916034c4a8f6b2d5c33a30c63_Out_2, 2, _Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2);
            float _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1;
            Unity_Saturate_float(_Divide_aca89bdde6eb4742ab65be66d8525f7f_Out_2, _Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1);
            float _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0 = _Noise_Power;
            float _Power_5524a531023342ee9dc0f3883c2d8334_Out_2;
            Unity_Power_float(_Saturate_d8da0f1ceba04d0e958c5ad9b0d2a350_Out_1, _Property_bc5ebff4b29e460f81ee6cd7dc968433_Out_0, _Power_5524a531023342ee9dc0f3883c2d8334_Out_2);
            float4 _Property_b3ed38057ce64692af01f118cff65022_Out_0 = _Noise_remap;
            float _Split_825e1e790ceb4719bfe50be57946def5_R_1 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[0];
            float _Split_825e1e790ceb4719bfe50be57946def5_G_2 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[1];
            float _Split_825e1e790ceb4719bfe50be57946def5_B_3 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[2];
            float _Split_825e1e790ceb4719bfe50be57946def5_A_4 = _Property_b3ed38057ce64692af01f118cff65022_Out_0[3];
            float4 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4;
            float3 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5;
            float2 _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_R_1, _Split_825e1e790ceb4719bfe50be57946def5_G_2, 0, 0, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGBA_4, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RGB_5, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6);
            float4 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4;
            float3 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5;
            float2 _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6;
            Unity_Combine_float(_Split_825e1e790ceb4719bfe50be57946def5_B_3, _Split_825e1e790ceb4719bfe50be57946def5_A_4, 0, 0, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGBA_4, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RGB_5, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6);
            float _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3;
            Unity_Remap_float(_Power_5524a531023342ee9dc0f3883c2d8334_Out_2, _Combine_a7c42ff0cfd8476c9104a253d8d2325b_RG_6, _Combine_263e0669c8cb4ca18bd684f75fdb8b8d_RG_6, _Remap_2883d507ce17415f906e9bf28a548ee5_Out_3);
            float _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1;
            Unity_Absolute_float(_Remap_2883d507ce17415f906e9bf28a548ee5_Out_3, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1);
            float _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3;
            Unity_Smoothstep_float(_Property_cd7daeb9099344ca8ea0b5573c4e4266_Out_0, _Property_ac28ae7bf23e4c7f90d4076f933ebeca_Out_0, _Absolute_dc313973b7fc4018803099c98094dd6a_Out_1, _Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3);
            float _Property_17ccf8fee75049e192448eae3739ec88_Out_0 = _Base_Speed;
            float _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2;
            Unity_Multiply_float_float(IN.TimeParameters.x, _Property_17ccf8fee75049e192448eae3739ec88_Out_0, _Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2);
            float2 _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_2e3032cfbf8648da917d543684e6df08_Out_3.xy), float2 (1, 1), (_Multiply_1fc1262e5427499f8ad63954fa11bd87_Out_2.xx), _TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3);
            float _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0 = _Base_Scale;
            float _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_d6ed643469264cb2bcdc32e358f931ba_Out_3, _Property_0dd484a2bbb34cc7b19a07022dba708b_Out_0, _GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2);
            float _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0 = _Base_Strength;
            float _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2;
            Unity_Multiply_float_float(_GradientNoise_12088b0e45ac479a98b3ad293b2bbb9b_Out_2, _Property_e783a75ab17a495dbe61154f8e9b7703_Out_0, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2);
            float _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2;
            Unity_Add_float(_Smoothstep_370391e2bf74454895af5c06f45309cb_Out_3, _Multiply_619ed7d3fb524c3bad84f21418404dbc_Out_2, _Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2);
            float4 _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3;
            Unity_Lerp_float4(_Property_ba583cc797d840689c683c09e8849329_Out_0, _Property_ee36b1ce4d5041e4808612252a3f652e_Out_0, (_Add_87cdf3fa2ad0496ab8161cbd29cad6aa_Out_2.xxxx), _Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3);
            float _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1);
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_R_1 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_G_2 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_B_3 = 0;
            float _Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4 = 0;
            float _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2;
            Unity_Subtract_float(_Split_33f6f0f6ba284d8ba7af5c1eb29c310d_A_4, 1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2);
            float _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2;
            Unity_Subtract_float(_SceneDepth_96ae1e2f44bc4c639342e833f7b52c30_Out_1, _Subtract_7a6cea38d3d2487c9ddc025ad841c1b0_Out_2, _Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2);
            float _Property_18142e5433da4239ab181ca6ea2d946e_Out_0 = _Fade_Depth;
            float _Divide_2249a86b76794140bfae1af272018ca8_Out_2;
            Unity_Divide_float(_Subtract_ad7df5b72500498bb3ba78241fafaa3c_Out_2, _Property_18142e5433da4239ab181ca6ea2d946e_Out_0, _Divide_2249a86b76794140bfae1af272018ca8_Out_2);
            float _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            Unity_Saturate_float(_Divide_2249a86b76794140bfae1af272018ca8_Out_2, _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1);
            surface.BaseColor = (_Lerp_a9fd2ddc333c419ebdf05ce06bf28344_Out_3.xyz);
            surface.Alpha = _Saturate_55b2b991b2904ec1949f51ab16515169_Out_1;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
            output.TimeParameters =                             _TimeParameters.xyz;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
            output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}