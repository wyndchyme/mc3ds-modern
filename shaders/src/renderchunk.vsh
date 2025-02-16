; Minecraft - New Nintendo 3DS Edition 
; renderchunk.shbin

; Handcoded by ENDERMANYK

; Uniforms
.fvec WORLDVIEWPROJ[4], WORLDVIEW[4], PROJ[4]  ;uniform MAT4 WORLDVIEWPROJ, uniform MAT4 WORLDVIEW, uniform MAT4 PROJ
.fvec FOG_COLOR                                ;uniform vec4 FOG_COLOR;
.fvec FOG_CONTROL                              ;uniform vec2 FOG_CONTROL;
.fvec RENDER_DISTANCE                          ;uniform float RENDER_DISTANCE;
.fvec VIEWPORT_DIMENSION                       ;uniform vec2 VIEWPORT_DIMENSION;
.fvec CURRENT_COLOR                            ;uniform vec4 CURRENT_COLOR;
.fvec CHUNK_ORIGIN_AND_SCALE                   ;uniform POS4 CHUNK_ORIGIN_AND_SCALE;
.fvec VIEW_POS                                 ;uniform POS3 VIEW_POS;
.fvec FAR_CHUNKS_DISTANCE                      ;uniform float FAR_CHUNKS_DISTANCE;

; Inputs, attribute
.in aPosition  v0                              ;attribute POS4 POSITION;
.in aColor     v1                              ;attribute vec4 COLOR;
.in aTexCoord  v2                              ;attribute vec2 TEXCOORD_0;
.in bTexCoord  v3                              ;attribute vec2 TEXCOORD_1;

; Outputs, varing
.out outPos position.xyzw                      ;gl_Position
.out outColor color.rgba                       ;varing vec4 color;
.out outCoord0 texcoord0.xy                    ;varing vec2 uv0;
.out outCoord1 texcoord1.xy                    ;varing vec2 uv1;

; Booleans
.bool ENABLE_FOG
.bool ALLOW_FADE

; Constants
.constf const0(1.000000, -1.000000, 1.000000, 1.000000)
.constf const1(0.003922, 0.003922, 0.003922, 0.003922)
.constf const2(0.00001525, 0.00001525, 0.00001525, 0.00001525)
.constf const3(0.000000, 0.000000, 0.000000, 0.000000)
.constf const4(0.000000, 1.000000, 0.025000, 0.022346)

; normalizedepth
.proc normalizedepth
    mul r0.z, r0.zzzz, r0.wwww
    add r0.z, -const4.zzzz, r0.zzzz
    mul r0.z, const4.wwww, r0.zzzz
.end

; main
.proc main
    mul r0.xyz, CHUNK_ORIGIN_AND_SCALE.wwww, aPosition.xyzz    ;worldPos.xyz = (POSITION.xyz * CHUNK_ORIGIN_AND_SCALE.w) + CHUNK_ORIGIN_AND_SCALE.xyz
    add r1.xyz, CHUNK_ORIGIN_AND_SCALE.xyzz, r0.xyzz           ;r1 = worldPos
    mov r1.w, const0.xxxx                                      ;worldPos.w = 1.0
    mov r3, r1
    add r1.xyz, CHUNK_ORIGIN_AND_SCALE.xyzz, r0.xyzz
    mov r1.w, const0.xxxx
    dp4 r2.x, WORLDVIEW[0], r1                                 ;POS4 pos = WORLDVIEW * worldPos
    dp4 r2.y, WORLDVIEW[1], r1
    dp4 r2.z, WORLDVIEW[2], r1
    dp4 r2.w, WORLDVIEW[3], r1
    dp4 r0.x, PROJ[0], r2                                      ;pos = PROJ * pos
    dp4 r0.y, PROJ[1], r2
    dp4 r0.z, PROJ[2], r2
    dp4 r0.w, PROJ[3], r2
    mov r0.xyz, r0.yxzz
    mul outPos, const0, r0                                     ;gl_Position = pos
    mul outColor, const1, aColor                               ;color = COLOR
    mul r0, const2, aTexCoord
    slti r1, r0, const3
    add r2, r0, r1
    mov outCoord0, r2                                          ;uv0 = TEXCOORD_0
    mul r0, const2, bTexCoord
    slti r1, r0, const3
    add r2, r0, r1
    mov outCoord1, r2                                          ;uv1 = TEXCOORD_1
    end
.end
