// MAYA TOON OUTLINE SHADER
// Version: 1.2
// Author: kamone
// Usage: https://github.com/kamone416/MayaToonOutlineShader

#define NumberOfMipMaps 0
#define PI 3.1415926

//------------------------------------
// Samplers
//------------------------------------
SamplerState _SamplerAnisoWrap
{
    Filter = ANISOTROPIC;
    AddressU = Wrap;
    AddressV = Wrap;
};

SamplerState _SamplerShadowDepth
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Border;
    AddressV = Border;
    BorderColor = float4(1.0f, 1.0f, 1.0f, 1.0f);
};

SamplerState SamplerShadowDepth
{
	Filter = MIN_MAG_MIP_POINT;
	AddressU = Border;
	AddressV = Border;
	BorderColor = float4(1.0f, 1.0f, 1.0f, 1.0f);
};


//-------------
// Textures
//-------------
Texture2D _OpacityMap<
    string UIGroup = "Transparent";
    string ResourceName = "";
    string UIWidget = "FilePicker";
    string UIName = "Opacity Map";
    string ResourceType = "2D";
    int mipmaplevels = NumberOfMipMaps;
    int UIOrder = 102;
>;

Texture2D _BaseColorMap<
    string UIGroup = "Color";
    string ResourceName = "";
    string UIWidget = "FilePicker";
    string UIName = "Base Color Map";
    string ResourceType = "2D";
    int mipmaplevels = NumberOfMipMaps;
    int UIOrder = 203;
>;

Texture2D _DetailColorMap<
    string UIGroup = "Color";
    string ResourceName = "";
    string UIWidget = "FilePicker";
    string UIName = "Detail Color Map";
    string ResourceType = "2D";
    int mipmaplevels = NumberOfMipMaps;
    int UIOrder = 205;
>;

Texture2D _GradeMap<
    string UIGroup = "Color";
    string ResourceName = "";
    string UIWidget = "FilePicker";
    string UIName = "Grade Map";
    string ResourceType = "2D";
    int mipmaplevels = NumberOfMipMaps;
    int UIOrder = 207;
>;

Texture2D _ShadowColorMap<
    string UIGroup = "Color";
    string ResourceName = "";
    string UIWidget = "FilePicker";
    string UIName = "Shadow Color Map";
    string ResourceType = "2D";
    int mipmaplevels = NumberOfMipMaps;
    int UIOrder = 211;
>;

Texture2D _SpeclarMap<
    string UIGroup = "Speclar";
    string ResourceName = "";
    string UIWidget = "FilePicker";
    string UIName = "Speclar Map";
    string ResourceType = "2D";
    int mipmaplevels = NumberOfMipMaps;
    int UIOrder = 302;
>;

Texture2D _OutlineColorMap<
    string UIGroup = "Outline";
    string ResourceName = "";
    string UIWidget = "FilePicker";
    string UIName = "Outline Color Map";
    string ResourceType = "2D";
    int mipmaplevels = NumberOfMipMaps;
    int UIOrder = 503;
>;

Texture2D _TranspDepthTexture : transpdepthtexture<
    string UIWidget = "None";
>;

Texture2D _OpaqueDepthTexture : opaquedepthtexture<
    string UIWidget = "None";
>;


//------------------------------------
// Shadow Maps
//------------------------------------
TextureCube _Pointlight0ShadowMap : SHADOWMAP
<
    string Object = "Light 0";  // UI Group for lights, auto-closed
    string UIWidget = "None";
    int UIOrder = 1000;
>;

Texture2D _Light0ShadowMap : SHADOWMAP
<
    string Object = "Light 0";  // UI Group for lights, auto-closed
    string UIWidget = "None";
    int UIOrder = 1000;
>;

//------------------------------------
// Per Frame parameters
//------------------------------------
cbuffer UpdatePerFrame : register(b0)
{
    float4x4 _View       : View<string UIWidget = "None";>;
    float4x4 _ViewInv    : ViewInverse<string UIWidget = "None";>;
    float4x4 _Prj        : Projection<string UIWidget = "None";>;
    float4x4 _ViewPrj    : ViewProjection<string UIWidget = "None";>;
    float3 _WorldViewPos : ViewPosition<string UIWidget = "None";>;
    float3 _WorldViewDir : ViewDirection<string UIWidget = "None";>;
}

//------------------------------------
// Per Object parameters
//------------------------------------
cbuffer UpdatePerObject : register(b1)
{
    float4x4 _World        : World<string UIWidget = "None";>;
    float4x4 _WorldInv     : WorldInverse<string UIWidget = "None";>;
    float4x4 _WorldInvT    : WorldInverseTranspose<string UIWidget = "None";>;
    float4x4 _WorldView    : WorldView<string UIWidget = "None";>;
    float4x4 _WorldViewPrj : WorldViewProjection<string UIWidget = "None";>;

    // ---------------
    // Lighting GROUP
    // ---------------
    bool _LinearSpaceLighting<
        string UIGroup = "Lighting";
        string UIName = "Linear Space Lighting";
        int UIOrder = 0;
    > = true;

    bool _UseShadows
    <
        string UIGroup = "Lighting";
        string UIName = "Shadows";
        int UIOrder = 1;
    > = false;

    float _ShadowMultiplier
    <
        string UIGroup = "Lighting";
        string UIWidget = "Slider";
        float UIMin = 0.000;
        float UIMax = 1.000;
        float UIStep = 0.001;
        string UIName = "Shadow Strength";
        int UIOrder = 2;
    > = {1.0f};

    // This offset allows you to fix any in-correct self shadowing caused by limited precision.
    // This tends to get affected by scene scale and polygon count of the objects involved.
    float _ShadowDepthBias : ShadowMapBias
    <
        string UIGroup = "Lighting";
        string UIWidget = "Slider";
        float UIMin = 0.000;
        float UISoftMax = 10.000;
        float UIStep = 0.001;
        string UIName = "Shadow Bias";
        int UIOrder = 3;
    > = {0.01f};

    float _ShadowFilterWidth
    <
        string UIGroup = "Lighting";
        string UIWidget = "Slider";
        float UIMin = 0.00000001f;
        float UISoftMax = 0.002f;
        float UIStep = 0.00000001f;
        string UIName = "Shadow Filter Width";
        int UIOrder = 4;
    > = {0.0002f};

    int _ShadowFilterCount
    <
        string UIGroup = "Lighting";
        string UIWidget = "Slider";
        float UIMin = 0;
        float UISoftMax = 20;
        float UIStep = 1;
        string UIName = "Shadow Filter Count";
        int UIOrder = 5;
    > = {10};

    // ---------------
    // Transparent GROUP
    // ---------------
    int _OpacityMapUv<
        string UIGroup = "Transparent";
        string UIName = "Opacity Map UV";
        string UIFieldNames ="None:UV1 Red:UV1 Green:UV1 Blue:UV1 Alpha:UV2 Red:UV2 Green:UV2 Blue:UV2 Alpha";
        float UIMin = 0;
        float UIMax = 8;
        float UIStep = 1;
        int UIOrder = 101;
    > = 0;

    float _Opacity : OPACITY <
        string UIGroup = "Transparent";
        string UIWidget = "Slider";
        string UIName = "Opacity";
        float UIMin = 0.0;
        float UIMax = 1.0;
        float UIStep = 0.001;
        int UIOrder = 103;
    > = 1.0;

    // ---------------
    // Color GROUP
    // ---------------
    float3 _BaseColor : DIFFUSE <
        string UIGroup = "Color";
        string UIName =  "Base Color";
        string UIWidget = "Color";
        int UIOrder = 201;
    > = {0.7f, 0.7f, 0.7f};

    int _BaseColorMapUv<
        string UIGroup = "Color";
        string UIName = "Base Color Map UV";
        string UIFieldNames ="None:UV1:UV2";
        float UIMin = 0;
        float UIMax = 2;
        float UIStep = 1;
        int UIOrder = 202;
    > = 0;

    int _DetailColorMapUv<
        string UIGroup = "Color";
        string UIName = "Detail Color Map UV";
        string UIFieldNames ="None:UV1:UV2";
        float UIMin = 0;
        float UIMax = 2;
        float UIStep = 1;
        int UIOrder = 204;
    > = 0;

    int _GradeMapUv<
        string UIGroup = "Color";
        string UIName = "Grade Map UV";
        string UIFieldNames ="None:UV1 Red:UV1 Green:UV1 Blue:UV1 Alpha:UV2 Red:UV2 Green:UV2 Blue:UV2 Alpha";
        float UIMin = 0;
        float UIMax = 8;
        float UIStep = 1;
        int UIOrder = 206;
    > = 0;

    int _UseGradeMapVertexColor<
        string UIGroup = "Color";
        string UIName = "Grade Map Vertex Color";
        string UIFieldNames ="None:VertexColor1 Red:VertexColor1 Green:VertexColor1 Blue:VertexColor1 Alpha:VertexColor2 Red:VertexColor2 Green:VertexColor2 Blue:VertexColor2 Alpha";
        float UIMin = 0;
        float UIMax = 8;
        float UIStep = 1;
        int UIOrder = 208;
    > = 0;

    float _GradeMapLevel<
        string UIGroup = "Color";
        string UIName =  "Grade Map Level";
        string UIWidget = "Slider";
        float UIMin = -0.5;
        float UIMax = 0.5;
        int UIOrder = 209;
    > = {0.0f};

    int _ShadowColorMapUv<
        string UIGroup = "Color";
        string UIName = "Shadow Color Map UV";
        string UIFieldNames ="None:UV1:UV2";
        float UIMin = 0;
        float UIMax = 2;
        float UIStep = 1;
        int UIOrder = 210;
    > = 0;

    float3 _Shadow1Color<
        string UIGroup = "Color";
        string UIName =  "Shadow 1 Color";
        string UIWidget = "Color";
        int UIOrder = 212;
    > = {0.5f, 0.5f, 0.5f};

    float _Shadow1Step<
        string UIGroup = "Color";
        string UIName =  "Shadow 1 Step";
        float UIMin = 0.0;
        float UIMax = 1.0;
        string UIWidget = "Slider";
        int UIOrder = 213;
    > = {0.5f};

    float _Shadow1Feather<
        string UIGroup = "Color";
        string UIName =  "Shadow 1 Feather";
        float UIMin = 0.0;
        float UIMax = 1.0;
        string UIWidget = "Slider";
        int UIOrder = 214;
    > = {0.0f};

    float3 _Shadow2Color <
        string UIGroup = "Color";
        string UIName =  "Shadow 2 Color";
        string UIWidget = "Color";
        int UIOrder = 215;
    > = {0.1f, 0.1f, 0.1f};

    float _Shadow2Step<
        string UIGroup = "Color";
        string UIName =  "Shadow 2 Step";
        float UIMin = 0.0;
        float UIMax = 1.0;
        string UIWidget = "Slider";
        int UIOrder = 216;
    > = {0.2f};

    float _Shadow2Feather<
        string UIGroup = "Color";
        string UIName =  "Shadow 2 Feather";
        float UIMin = 0.0;
        float UIMax = 1.0;
        string UIWidget = "Slider";
        int UIOrder = 217;
    > = {0.0f};

    // ---------------
    // Speclar GROUP
    // ---------------
    float3 _SpeclarColor<
        string UIGroup = "Speclar";
        string UIName =  "Speclar Color";
        string UIWidget = "Color";
        int UIOrder = 300;
    > = {0.5f, 0.5f, 0.5f};

    int _SpeclarMapUv<
        string UIGroup = "Speclar";
        string UIName = "Speclar Map UV";
        string UIFieldNames ="None:UV1 Red:UV1 Green:UV1 Blue:UV1 Alpha:UV2 Red:UV2 Green:UV2 Blue:UV2 Alpha";
        float UIMin = 0;
        float UIMax = 8;
        float UIStep = 1;
        int UIOrder = 301;
    > = 0;

    float _SpeclarStep<
        string UIGroup = "Speclar";
        string UIName =  "Speclar Step";
        string UIWidget = "Slider";
        float UIMin = 0.0;
        float UIMax = 1.0;
        int UIOrder = 303;
    > = {0.0f};

    float _SpeclarFeather<
        string UIGroup = "Speclar";
        string UIName =  "Speclar Feather";
        string UIWidget = "Slider";
        float UIMin = 0.0;
        float UIMax = 1.0;
        int UIOrder = 304;
    > = {0.0f};

    // ---------------
    // RimLight GROUP
    // ---------------
    float3 _RimColor<
        string UIGroup = "RimLight";
        string UIName =  "Rim Light Color";
        string UIWidget = "Color";
        int UIOrder = 400;
    > = {0.5f, 0.5f, 0.5f};

    float _RimStep<
        string UIGroup = "RimLight";
        string UIName =  "Rim Light Step";
        string UIWidget = "Slider";
        float UIMin = 0.0;
        float UIMax = 1.0;
        int UIOrder = 401;
    > = {0.0f};

    float _RimFeather<
        string UIGroup = "RimLight";
        string UIName =  "Rim Light Feather";
        string UIWidget = "Slider";
        float UIMin = 0.0;
        float UIMax = 1.0;
        int UIOrder = 402;
    > = {0.0f};

    float _LightDirEffect<
        string UIGroup = "RimLight";
        string UIName =  "Light Direction Effect";
        string UIWidget = "Slider";
        float UIMin = 0.0;
        float UIMax = 0.5;
        int UIOrder = 403;
    > = {0.0f};

    bool _InvertLightDir<
        string UIGroup = "RimLight";
        string UIName =  "Invert Light Direction";
        int UIOrder = 404;
    > = false;

    // ---------------
    // Outline GROUP
    // ---------------
    float _OutlineWidth<
        string UIGroup = "Outline";
        string UIName =  "Outline Width";
        string UIWidget = "Slider";
        float UIMin = 0.0f;
        float UISoftMax = 10.0f;
        int UIOrder = 500;
    > = 1.0f;

    int _OutlineWidthMap<
        string UIGroup = "Outline";
        string UIName = "Outline Width Map";
        string UIFieldNames ="None:VertexColor1 Red:VertexColor1 Green:VertexColor1 Blue:VertexColor1 Alpha:VertexColor2 Red:VertexColor2 Green:VertexColor2 Blue:VertexColor2 Alpha";
        float UIMin = 0;
        float UIMax = 8;
        float UIStep = 1;
        int UIOrder = 501;
    > = 0;

    int _OutlineColorMapUv<
        string UIGroup = "Outline";
        string UIName = "Outline Color Map UV";
        string UIFieldNames ="None:UV1:UV2";
        float UIMin = 0;
        float UIMax = 2;
        float UIStep = 1;
        int UIOrder = 502;
    > = 0;

    float3 _OutlineColor<
        string UIGroup = "Outline";
        string UIName =  "Outline Color";
        string UIWidget = "Color";
        int UIOrder = 504;
    > = {0.0f,0.0f,0.0f};

    float _ZOffset<
        string UIGroup = "Outline";
        string UIName =  "Z Offset";
        string UIWidget = "Slider";
        float UIMin = 0.0f;
        float UISoftMax = 10.0f;
        int UIOrder = 505;
    > = 0;

    int _ZOffsetMap<
        string UIGroup = "Outline";
        string UIName = "Z Offset Map";
        string UIFieldNames ="None:VertexColor1 Red:VertexColor1 Green:VertexColor1 Blue:VertexColor1 Alpha:VertexColor2 Red:VertexColor2 Green:VertexColor2 Blue:VertexColor2 Alpha";        float UIMin = 0;
        float UIMax = 8;
        float UIStep = 1;
        int UIOrder = 506;
    > = 0;

    // ---------------
    // Debug GROUP
    // ---------------
    int _DebugColor
    <
        string UIGroup = "Debug";
        string UIName = "Debug";
        string UIFieldNames ="None:HalfLambert:GradeMap:HalfLambert * GradeMap:Normal XYZ:Normal X:Normal Y:Normal Z:VertexColor1 RGB:VertexColor1 Red:VertexColor1 Green:VertexColor1 Blue:VertexColor1 Alpha:VertexColor2 RGB:VertexColor2 Red:VertexColor2 Green:VertexColor2 Blue:VertexColor2 Alpha";
        float UIMin = 0;
        float UIMax = 17;
        float UIStep = 1;
        int UIOrder = 600;
    > = 0;
}

//------------------------------------
// Light parameters
//------------------------------------
cbuffer UpdateLights : register(b2)
{
    int _Light0Type : LIGHTTYPE
    <
        string Object = "Light 0";
        string UIName = "Light 0 Type";
        string UIWidget = "None";
        int UIOrder = 1000;
    > = 0;

    float3 _Light0Pos : POSITION
    <
        string Object = "Light 0";
        string UIName = "Light 0 Position";
        string Space = "World";
        string UIWidget = "None";
        int UIOrder = 1000;
    > = {1000.0f, 1000.0f, 1000.0f};

    float3 _Light0Color : LIGHTCOLOR
    <
        string Object = "Light 0";
        string UIName = "Light 0 Color";
        string UIWidget = "None";
        int UIOrder = 1000;
    > = { 1.0f, 1.0f, 1.0f};

    float3 _Light0Dir : DIRECTION
    <
        string Object = "Light 0";
        string UIName = "Light 0 Direction";
        string Space = "World";
        string UIWidget = "None";
        int UIOrder = 1000;
    > = {0.0f, -1.0f, 0.0f};

    float4x4 _Light0Matrix : SHADOWMAPMATRIX
    <
        string Object = "Light 0";
        string UIWidget = "None";
        int UIOrder = 1000;
    >;
}

// -----------
// Structs
// -----------
struct appdata {
    float3 position     : POSITION;
    float2 texCoord0    : TEXCOORD0;
    float2 texCoord1    : TEXCOORD1;
    float4 vertexColor0 : Color0;
    float4 vertexColor1 : Color1;
    float3 normal       : NORMAL;
    float3 tangent      : TANGENT;
    float3 binormal     : BINORMAL;
};

struct vertexOutput {
    float4 position         : SV_POSITION;
    float2 texCoord0        : TEXCOORD0;
    float2 texCoord1        : TEXCOORD1;
    float4 vertexColor0     : TEXCOORD2;
    float4 vertexColor1     : TEXCOORD3;
    float3 worldPosition    : TEXCOORD4;
    float3 worldNormal      : NORMAL;
    float3 worldTangent     : TANGENT;
    float3 worldBinormal    : BINORMAL;
};

// ---------------
// Toon Lighting Pass
// ---------------

// shadow from AutodeskUberShader.fx
// Percentage-Closer Filtering
float lightShadow(float4x4 LightViewPrj, uniform Texture2D ShadowMapTexture, float3 VertexWorldPosition)
{
    float shadow = 1.0f;

    float4 Pndc = mul( float4(VertexWorldPosition.xyz,1.0) ,  LightViewPrj);
    Pndc.xyz /= Pndc.w;
    if ( Pndc.x > -1.0f && Pndc.x < 1.0f && Pndc.y  > -1.0f
        && Pndc.y <  1.0f && Pndc.z >  0.0f && Pndc.z <  1.0f )
    {
        float2 uv = 0.5f * Pndc.xy + 0.5f;
        uv = float2(uv.x,(1.0-uv.y));	// maya flip Y
        float z = Pndc.z - _ShadowDepthBias / Pndc.w;

        shadow = 0.0f;
        if (_ShadowFilterCount > 0) {
            int filterCount = _ShadowFilterCount + 1;
            float offsetUnit = 1.0 / filterCount;
            for(int x = 0; x <= filterCount; x++) {
                float offsetX = lerp(1.0, -1.0, offsetUnit * x);
                for(int y = 0; y <= filterCount; y++) {
                    float offsetY = lerp(1.0, -1.0,  offsetUnit * y);
                    float2 suv = uv + float2(offsetX, offsetY) * _ShadowFilterWidth;  
                    float val = z - ShadowMapTexture.SampleLevel(_SamplerShadowDepth, suv, 0 ).x;
                    shadow += (val >= 0.0f) ? 0.0f : (1.0f / (filterCount * filterCount));
                }    
            }
        } else {
            shadow = 1.0f;
            float val = z - ShadowMapTexture.SampleLevel(SamplerShadowDepth, uv, 0 ).x;
            shadow = (val >= 0.0f)? 0.0f : 1.0f;
        }

        shadow = lerp(1.0f, shadow, _ShadowMultiplier);
    }

    return shadow;
}

vertexOutput toonVS(appdata IN) {
    vertexOutput OUT = (vertexOutput)0;

    float3 normal = normalize(IN.normal);
    float3 tangent = normalize(IN.tangent);
    float3 binormal = normalize(IN.binormal);

    OUT.position = mul(float4(IN.position.xyz, 1.0), _WorldViewPrj);
    OUT.worldPosition = mul(float4(IN.position.xyz, 1.0), _World);
    OUT.vertexColor0 = IN.vertexColor0;
    OUT.vertexColor1 = IN.vertexColor1;
    OUT.worldNormal = mul(float4(normal, 1.0), _WorldInvT).xyz;
    OUT.worldTangent = mul(float4(tangent, 1.0), _WorldInvT).xyz;
    OUT.worldBinormal = mul(float4(binormal, 1.0), _WorldInvT).xyz;

    OUT.texCoord0 = float2(IN.texCoord0.x, (1.0 - IN.texCoord0.y));
    OUT.texCoord1 = float2(IN.texCoord1.x, (1.0 - IN.texCoord1.y));

    return OUT;
}

float4 toonPS(vertexOutput IN) : COLOR {
    float3 worldNormal = normalize(IN.worldNormal);
    float3 viewDir = normalize(_ViewInv[3].xyz - IN.worldPosition.xyz);
    float3 lightDir = normalize(_Light0Type == 4 ? -_Light0Dir : _Light0Pos - IN.worldPosition.xyz);

    float nDotL = dot(worldNormal, lightDir);
    float halfLambert = saturate(nDotL * 0.5 + 0.5);
    float3 halfDirection = normalize(viewDir + lightDir);

    // shadow
    float shadow = _UseShadows ? saturate(lightShadow(_Light0Matrix, _Light0ShadowMap, IN.worldPosition)) : 1.0;

    // diffuse map
    float gammaCorrection = lerp(1.0, 2.2, _LinearSpaceLighting);
    float3 baseColor = float3(1.0, 1.0, 1.0);
    float4 uv1DiffuseMap = _BaseColorMap.Sample(_SamplerAnisoWrap, IN.texCoord0);
    float4 uv2DiffuseMap = _BaseColorMap.Sample(_SamplerAnisoWrap, IN.texCoord1);
    baseColor = _BaseColorMapUv == 1 ? pow(uv1DiffuseMap.rgb, gammaCorrection) : baseColor;
    baseColor = _BaseColorMapUv == 2 ? pow(uv2DiffuseMap.rgb, gammaCorrection) : baseColor;

    // detail color map
    float4 uv1DetailColorMap = _DetailColorMap.Sample(_SamplerAnisoWrap, IN.texCoord0);
    float4 uv2DetailColorMap = _DetailColorMap.Sample(_SamplerAnisoWrap, IN.texCoord1);
    baseColor = _DetailColorMapUv == 1 ? lerp(baseColor, pow(uv1DetailColorMap.rgb, gammaCorrection), uv1DetailColorMap.a) : baseColor;
    baseColor = _DetailColorMapUv == 2 ? lerp(baseColor, pow(uv2DetailColorMap.rgb, gammaCorrection), uv2DetailColorMap.a) : baseColor;

    // alpha
    float alpha = 1.0;
    float4 uv1OpacityMap = _OpacityMap.Sample(_SamplerAnisoWrap, IN.texCoord0);
    float4 uv2OpacityMap = _OpacityMap.Sample(_SamplerAnisoWrap, IN.texCoord1);
    alpha = _OpacityMapUv == 1 ? uv1OpacityMap.r : alpha;
    alpha = _OpacityMapUv == 2 ? uv1OpacityMap.g : alpha;
    alpha = _OpacityMapUv == 3 ? uv1OpacityMap.b : alpha;
    alpha = _OpacityMapUv == 4 ? uv1OpacityMap.a : alpha;
    alpha = _OpacityMapUv == 5 ? uv2OpacityMap.r : alpha;
    alpha = _OpacityMapUv == 6 ? uv2OpacityMap.g : alpha;
    alpha = _OpacityMapUv == 7 ? uv2OpacityMap.b : alpha;
    alpha = _OpacityMapUv == 8 ? uv2OpacityMap.a : alpha;
    float opacity = _Opacity * alpha;

    // grade map
    float gradeMap = 1.0;
    float4 uv1GradeMap = _GradeMap.Sample(_SamplerAnisoWrap, IN.texCoord0);
    float4 uv2GradeMap = _GradeMap.Sample(_SamplerAnisoWrap, IN.texCoord1);
    gradeMap = _GradeMapUv == 1 ? uv1GradeMap.r : gradeMap;
    gradeMap = _GradeMapUv == 2 ? uv1GradeMap.g : gradeMap;
    gradeMap = _GradeMapUv == 3 ? uv1GradeMap.b : gradeMap;
    gradeMap = _GradeMapUv == 4 ? uv1GradeMap.a : gradeMap;
    gradeMap = _GradeMapUv == 5 ? uv2GradeMap.r : gradeMap;
    gradeMap = _GradeMapUv == 6 ? uv2GradeMap.g : gradeMap;
    gradeMap = _GradeMapUv == 7 ? uv2GradeMap.b : gradeMap;
    gradeMap = _GradeMapUv == 8 ? uv2GradeMap.a : gradeMap;

    // grade map by vertex color
    gradeMap = _UseGradeMapVertexColor == 1 ? gradeMap * IN.vertexColor0.r : gradeMap;
    gradeMap = _UseGradeMapVertexColor == 2 ? gradeMap * IN.vertexColor0.g : gradeMap;
    gradeMap = _UseGradeMapVertexColor == 3 ? gradeMap * IN.vertexColor0.b : gradeMap;
    gradeMap = _UseGradeMapVertexColor == 4 ? gradeMap * IN.vertexColor0.a : gradeMap;
    gradeMap = _UseGradeMapVertexColor == 5 ? gradeMap * IN.vertexColor1.r : gradeMap;
    gradeMap = _UseGradeMapVertexColor == 6 ? gradeMap * IN.vertexColor1.g : gradeMap;
    gradeMap = _UseGradeMapVertexColor == 7 ? gradeMap * IN.vertexColor1.b : gradeMap;
    gradeMap = _UseGradeMapVertexColor == 8 ? gradeMap * IN.vertexColor1.a : gradeMap;
    gradeMap = saturate(gradeMap + _GradeMapLevel);

    // shadow color map
    float3 shadowColorMap = float3(1.0, 1.0, 1.0);
    float3 uv1ShadowColorMap = _ShadowColorMap.Sample(_SamplerAnisoWrap, IN.texCoord0).rgb;
    float3 uv2ShadowColorMap = _ShadowColorMap.Sample(_SamplerAnisoWrap, IN.texCoord1).rgb;
    uv1ShadowColorMap = pow(uv1ShadowColorMap, gammaCorrection);
    uv2ShadowColorMap = pow(uv2ShadowColorMap, gammaCorrection);
    shadowColorMap = _ShadowColorMapUv == 1 ? uv1ShadowColorMap : shadowColorMap;
    shadowColorMap = _ShadowColorMapUv == 2 ? uv2ShadowColorMap : shadowColorMap;
    shadowColorMap = _DetailColorMapUv == 1 ? lerp(shadowColorMap, pow(uv1DetailColorMap.rgb, gammaCorrection), uv1DetailColorMap.a) : shadowColorMap;
    shadowColorMap = _DetailColorMapUv == 2 ? lerp(shadowColorMap, pow(uv2DetailColorMap.rgb, gammaCorrection), uv2DetailColorMap.a) : shadowColorMap;

    // speclar map
    float speclarMap = 1.0;
    float4 uv1SpeclarMap = _SpeclarMap.Sample(_SamplerAnisoWrap, IN.texCoord0);
    float4 uv2SpeclarMap = _SpeclarMap.Sample(_SamplerAnisoWrap, IN.texCoord1);
    speclarMap = _SpeclarMapUv == 1 ? uv1SpeclarMap.r : speclarMap;
    speclarMap = _SpeclarMapUv == 2 ? uv1SpeclarMap.g : speclarMap;
    speclarMap = _SpeclarMapUv == 3 ? uv1SpeclarMap.b : speclarMap;
    speclarMap = _SpeclarMapUv == 4 ? uv1SpeclarMap.a : speclarMap;
    speclarMap = _SpeclarMapUv == 5 ? uv2SpeclarMap.r : speclarMap;
    speclarMap = _SpeclarMapUv == 6 ? uv2SpeclarMap.g : speclarMap;
    speclarMap = _SpeclarMapUv == 7 ? uv2SpeclarMap.b : speclarMap;
    speclarMap = _SpeclarMapUv == 8 ? uv2SpeclarMap.a : speclarMap;

    float gradedHalfLambert = saturate(halfLambert * gradeMap);
    float shadow1Mask = saturate(1.0 - smoothstep(_Shadow1Step - _Shadow1Feather, _Shadow1Step + _Shadow1Feather, gradedHalfLambert));
    float shadow2Mask = saturate(1.0 - smoothstep(_Shadow2Step - _Shadow2Feather, _Shadow2Step + _Shadow2Feather, gradedHalfLambert));
    float3 color = baseColor * _BaseColor;
    float3 shadow1Color = _ShadowColorMapUv > 0 ? shadowColorMap * _Shadow1Color : color * _Shadow1Color;
    float3 shadow2Color = _ShadowColorMapUv > 0 ? shadowColorMap * _Shadow2Color : color * _Shadow2Color;

    color = lerp(shadow1Color, color,  (1.0 - shadow1Mask) * shadow);
    color = lerp(shadow2Color, color,  (1.0 - shadow2Mask * shadow1Mask) * shadow);

    // speclar
    float halfSpeclar = saturate(dot(halfDirection, worldNormal) * 0.5 + 0.5);
    float speclarMask = saturate(smoothstep(1.0 - _SpeclarStep - _SpeclarFeather, 1.0 - _SpeclarStep + _SpeclarFeather, halfSpeclar * (1.0 - shadow1Mask) * shadow));
    float3 speclarColor = saturate(color + _SpeclarColor);

    // rimlight
    float3 rimLightDir = _InvertLightDir ? -lightDir : lightDir;
    float3 rimLightViewDir = lerp(viewDir, viewDir + rimLightDir, _LightDirEffect);
    float nDotV = dot(worldNormal, rimLightViewDir);
    float rimLight = saturate((1.0 - nDotV) * 0.5 + 0.5);
    float rimLightMask = saturate(smoothstep(1.0 - _RimStep - _RimFeather, 1.0 - _RimStep + _RimFeather, rimLight));
    float3 rimColor = saturate(color + _RimColor);

    color = lerp(color, rimColor, rimLightMask);
    color = lerp(color, speclarColor,  speclarMask * speclarMap);

    // Debug
    float3 normalColor = (worldNormal + 1.0) * 0.5;
    color = _DebugColor == 1 ? halfLambert : color;             // HalfLambert: 1
    color = _DebugColor == 2 ? gradeMap : color;                // GradeMap: 2
    color = _DebugColor == 3 ? gradedHalfLambert : color;       // HalfLambert * GradeMap: 3
    color = _DebugColor == 4 ? normalColor.xyz : color;         // Normal XYZ: 4
    color = _DebugColor == 5 ? normalColor.x : color;           // Normal X: 5
    color = _DebugColor == 6 ? normalColor.y : color;           // Normal Y: 6
    color = _DebugColor == 7 ? normalColor.z : color;           // Normal Z: 7
    color = _DebugColor == 8 ? IN.vertexColor0.rgb : color;     // Vertex0 RGB: 8
    color = _DebugColor == 9 ? IN.vertexColor0.r : color;       // Vertex0 Red: 9
    color = _DebugColor == 10 ? IN.vertexColor0.g : color;      // Vertex0 Green: 10
    color = _DebugColor == 11 ? IN.vertexColor0.b : color;      // Vertex0 Blue: 11
    color = _DebugColor == 12 ? IN.vertexColor0.a : color;      // Vertex0 Alpha: 12
    color = _DebugColor == 13 ? IN.vertexColor1.rgb : color;    // Vertex1 RGB: 13
    color = _DebugColor == 14 ? IN.vertexColor1.r : color;      // Vertex1 Red: 14
    color = _DebugColor == 15 ? IN.vertexColor1.g : color;      // Vertex1 Green: 15
    color = _DebugColor == 16 ? IN.vertexColor1.b : color;      // Vertex1 Blue: 16
    color = _DebugColor == 17 ? IN.vertexColor1.a : color;      // Vertex1 Alpha: 17
    opacity = _DebugColor > 0 ? 1.0: opacity;

    return float4(color * opacity, opacity);
}

// ---------------
// Outline Pass
// ---------------
vertexOutput outlineVS(appdata IN) {
    vertexOutput OUT = (vertexOutput)0;

    float3 normal = normalize(IN.normal);
    float3 tangent = normalize(IN.tangent);
    float3 binormal = normalize(IN.binormal);

    float3 objectScale = float3(
        length(_World._m00_m10_m20),
        length(_World._m01_m11_m21),
        length(_World._m02_m12_m22)
    );

    OUT.vertexColor0 = IN.vertexColor0;
    OUT.vertexColor1 = IN.vertexColor1;
    OUT.worldNormal = mul(float4(normal, 1.0), _WorldInvT).xyz;
    OUT.worldTangent = mul(float4(tangent, 1.0), _WorldInvT).xyz;
    OUT.worldBinormal = mul(float4(binormal, 1.0), _WorldInvT).xyz;

    OUT.texCoord0 = float2(IN.texCoord0.x, (1.0 - IN.texCoord0.y));
    OUT.texCoord1 = float2(IN.texCoord1.x, (1.0 - IN.texCoord1.y));

    float4 viewPos = mul(float4(IN.position, 1.0), _WorldView);
    float3 objCameraPos = mul(float4(_ViewInv[3].xyz, 1.0), _WorldInv).xyz;
    float3 objCameraDir = normalize(IN.position - objCameraPos);

    float outlineScaler = 1.0;
    outlineScaler = _OutlineWidthMap == 1 ? IN.vertexColor0.r : outlineScaler;
    outlineScaler = _OutlineWidthMap == 2 ? IN.vertexColor0.g : outlineScaler;
    outlineScaler = _OutlineWidthMap == 3 ? IN.vertexColor0.b : outlineScaler;
    outlineScaler = _OutlineWidthMap == 4 ? IN.vertexColor0.a : outlineScaler;
    outlineScaler = _OutlineWidthMap == 5 ? IN.vertexColor1.r : outlineScaler;
    outlineScaler = _OutlineWidthMap == 6 ? IN.vertexColor1.g : outlineScaler;
    outlineScaler = _OutlineWidthMap == 7 ? IN.vertexColor1.b : outlineScaler;
    outlineScaler = _OutlineWidthMap == 8 ? IN.vertexColor1.a : outlineScaler;

    // scale by view distance
    outlineScaler = outlineScaler * saturate(abs(viewPos.z) * 0.01) * 0.1 / objectScale;

    float zOffsetScaler = 1.0;
    zOffsetScaler = _ZOffsetMap == 1 ? IN.vertexColor0.r : zOffsetScaler;
    zOffsetScaler = _ZOffsetMap == 2 ? IN.vertexColor0.g : zOffsetScaler;
    zOffsetScaler = _ZOffsetMap == 3 ? IN.vertexColor0.b : zOffsetScaler;
    zOffsetScaler = _ZOffsetMap == 4 ? IN.vertexColor0.a : zOffsetScaler;
    zOffsetScaler = _ZOffsetMap == 5 ? IN.vertexColor1.r : zOffsetScaler;
    zOffsetScaler = _ZOffsetMap == 6 ? IN.vertexColor1.g : zOffsetScaler;
    zOffsetScaler = _ZOffsetMap == 7 ? IN.vertexColor1.b : zOffsetScaler;
    zOffsetScaler = _ZOffsetMap == 8 ? IN.vertexColor1.a : zOffsetScaler;

    // offset vertex position
    float3 outlinePosition = IN.position + normal * _OutlineWidth * outlineScaler + objCameraDir * _ZOffset * zOffsetScaler;

    OUT.position = mul(float4(outlinePosition, 1.0), _WorldViewPrj);
    OUT.worldPosition = mul(float4(outlinePosition, 1.0), _World);

    return OUT;
}

float4 outlinePS(vertexOutput IN) : COLOR {
    // diffuse map
    float gammaCorrection = lerp(1.0, 2.2, _LinearSpaceLighting);
    float3 baseColor = float3(1.0, 1.0, 1.0);
    float3 uv1DiffuseMap = _OutlineColorMap.Sample(_SamplerAnisoWrap, IN.texCoord0).rgb;
    float3 uv2DiffuseMap = _OutlineColorMap.Sample(_SamplerAnisoWrap, IN.texCoord1).rgb;
    uv1DiffuseMap = pow(uv1DiffuseMap, gammaCorrection);
    uv2DiffuseMap = pow(uv2DiffuseMap, gammaCorrection);
    baseColor = _OutlineColorMapUv == 1 ? uv1DiffuseMap : baseColor;
    baseColor = _OutlineColorMapUv == 2 ? uv2DiffuseMap : baseColor;

    return float4(_OutlineColor * baseColor, 1.0);
}

// ---------------
// Transparent Pass
// ---------------
void Peel(vertexOutput IN)
{
    float currZ = abs( mul( float4(IN.worldPosition, 1.0f), _View ).z );

    float4 Pndc  = mul( float4(IN.worldPosition, 1.0f), _ViewPrj );
    float2 UV = Pndc.xy / Pndc.w * float2(0.5f, -0.5f) + 0.5f;
    float prevZ = _TranspDepthTexture.Sample(SamplerShadowDepth, UV).r;
    float opaqZ = _OpaqueDepthTexture.Sample(SamplerShadowDepth, UV).r;
    float bias = 0.00002f;
    if (currZ < prevZ * (1.0f + bias) || currZ > opaqZ * (1.0f - bias))
    {
        discard;
    }
}

float4 LinearDepth(vertexOutput IN)
{
    return abs(mul(float4(IN.worldPosition, 1.0f), _View ).z);
}

float4 DepthComplexity(float opacity)
{
    return opacity > 0.001f ? 1.0f : 0.0f;
}

struct MultiOut2
{
    float4 target0 : SV_Target0;
    float4 target1 : SV_Target1;
};

MultiOut2 fTransparentPeel(vertexOutput IN, bool FrontFace : SV_IsFrontFace)
{
    Peel(IN);

    MultiOut2 OUT;
    OUT.target0 = toonPS(IN);
    OUT.target1 = LinearDepth(IN);
    return OUT;
}

MultiOut2 fTransparentPeelAndAvg(vertexOutput IN, bool FrontFace : SV_IsFrontFace)
{
    Peel(IN);

    MultiOut2 OUT;
    OUT.target0 = toonPS(IN);
    OUT.target1 = DepthComplexity(OUT.target0.w);
    return OUT;
}

MultiOut2 fTransparentWeightedAvg(vertexOutput IN, bool FrontFace : SV_IsFrontFace)
{
    MultiOut2 OUT;
    OUT.target0 = toonPS(IN);
    OUT.target1 = DepthComplexity(OUT.target0.w);
    return OUT;
}

// -----------
// State
// -----------
RasterizerState FrontCulling { CullMode = Back; };
RasterizerState NoneCulling { CullMode = None; };

// ---------------------------
// Toon Lighting and Outline
// ---------------------------
technique11 ToonOutline<
    int isTransparent = 0;
>  {
    pass ToonPass {
        SetRasterizerState(NoneCulling);
        SetVertexShader(CompileShader(vs_5_0,toonVS()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, toonPS()));
    }
    pass OutlinePass {
        SetRasterizerState(FrontCulling);
        SetVertexShader(CompileShader(vs_5_0, outlineVS()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, outlinePS()));
    }
}

// --------------
// Toon Lighting
// --------------
technique11 Toon<
    bool overridesDrawState = true;
    int isTransparent = 3;
    string transparencyTest = "_Opacity < 1.0 || _OpacityMapUv > 0";
    bool supportsAdvancedTransparency = true;
> {
    pass ToonPass<
        string drawContext = "colorPass";
    > {
        SetRasterizerState(NoneCulling);
        SetVertexShader(CompileShader(vs_5_0, toonVS()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, toonPS()));
    }

    pass pTransparentPeel<
        // Depth-peeling pass for depth-peeling transparency algorithm.
        string drawContext = "transparentPeel";
    > {
        SetRasterizerState(NoneCulling);
        SetVertexShader(CompileShader(vs_5_0, toonVS()));
        SetHullShader(NULL);
        SetDomainShader(NULL);
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, fTransparentPeel()));
    }

    pass pTransparentPeelAndAvg<
        // Weighted-average pass for depth-peeling transparency algorithm.
        string drawContext = "transparentPeelAndAvg";
    > {
        SetRasterizerState(NoneCulling);
        SetVertexShader(CompileShader(vs_5_0, toonVS()));
        SetHullShader(NULL);
        SetDomainShader(NULL);
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, fTransparentPeelAndAvg()));
    }

    pass pTransparentWeightedAvg<
        // Weighted-average algorithm. No peeling.
        string drawContext = "transparentWeightedAvg";
    > {
        SetRasterizerState(NoneCulling);
        SetVertexShader(CompileShader(vs_5_0, toonVS()));
        SetHullShader(NULL);
        SetDomainShader(NULL);
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, fTransparentWeightedAvg()));
    }
}

// --------------
// Outline
// --------------
technique11 Outline<
    int isTransparent = 0;
>   {
    pass OutlinePass {
        SetRasterizerState(FrontCulling);
        SetVertexShader(CompileShader(vs_5_0, outlineVS()));
        SetGeometryShader(NULL);
        SetPixelShader(CompileShader(ps_5_0, outlinePS()));
    }
}