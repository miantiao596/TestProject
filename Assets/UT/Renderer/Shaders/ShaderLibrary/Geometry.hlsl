
#pragma require geometry
#pragma geometry LitPassGeometry

#pragma shader_feature_local _GEOMETRY
#pragma shader_feature_local _ _GEOM_INSTANCING
#pragma exclude_renderers gles
#pragma target 4.6 _GEOM_INSTANCING

float _TotalShellStep;
half4 _BaseMove;
float _BentType;


#ifdef _FUR
#define _GEOMETRY
#endif

void LitPassVertexGeom(Attributes input,
#ifdef _GEOMETRY
out Attributes output
#else
out Varyings output
#endif
)
{
    #ifdef _GEOMETRY
    output = input;
    #else
    output = LitPassVertex(input);
    #endif
}

void AppendShellVertex(inout TriangleStream<Varyings> stream, Attributes input,int index)
{
    #ifdef _FUR
    
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    
    // Low precision should be enough here as we have at most 13 shells.
    #ifdef _GEOM_INSTANCING
    half clampedShellAmount = _ShellAmount;
    #else
    half clampedShellAmount = clamp(_ShellAmount, 1, 13);
    #endif
    half shellStep = _TotalShellStep / clampedShellAmount;

    half layer = (half)index / clampedShellAmount;

    half moveFactor = pow(abs(layer), _BaseMove.w);
    half3 move = moveFactor * _BaseMove.xyz;
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Fur Direction
    half bent = _BentType * layer + (1 - _BentType);

     half3 groomWS = lerp(normalInput.normalWS, normalInput.normalWS,bent);
    half3 shellDir = SafeNormalize(groomWS+ move);
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    input.positionOS.xyz =TransformWorldToObject( vertexInput.positionWS + shellDir * (shellStep * index *  _FurLength));

    Varyings output=LitPassVertex(input);
    output.FurLayer=layer;
   
    stream.Append(output);
    #endif
}

#if defined(_GEOM_INSTANCING)
//几何着色器
[instance(3)]
[maxvertexcount(29)]
void LitPassGeometry(
#ifdef _GEOMETRY
triangle Attributes input[3],
#else
triangle Varyings input[3],
#endif
    inout TriangleStream<Varyings> stream, uint instanceID : SV_GSInstanceID)
{    
    #ifdef _GEOMETRY
    [loop] for (float i = 0 + (instanceID * 13); i < _ShellAmount; ++i)
    {
        [unroll] for (float j = 0; j < 3; ++j)
        {
            AppendShellVertex(stream, input[j], i);
        }
        stream.RestartStrip();
    }
    #else
    [unroll] for (float j = 0; j < 3; ++j)
    {
        stream.Append(input[j]);
    }
    #endif
}
#else
//几何着色器
[maxvertexcount(29)]
void LitPassGeometry(
#ifdef _GEOMETRY
triangle Attributes input[3],
#else
triangle Varyings input[3],
#endif
    inout TriangleStream<Varyings> stream)
{    
    #ifdef _GEOMETRY
    [loop] for (float i = 0; i < clamp(_ShellAmount, 1, 13); ++i)
    {
        [unroll] for (float j = 0; j < 3; ++j)
        {
            AppendShellVertex(stream, input[j], i);
        }
        stream.RestartStrip();
    }
    #else
    [unroll] for (float j = 0; j < 3; ++j)
    {
        stream.Append(input[j]);
    }
    #endif
}
#endif
