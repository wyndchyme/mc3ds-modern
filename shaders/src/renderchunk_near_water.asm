// Minecraft - New Nintendo 3DS Edition 
// renderchunk_near_water.shbin

// Handcoded by ENDERMANYK
// Modified by wyndchyme for Modernization MegaPack

// Uniforms
#pragma bind_symbol ( WORLDVIEWPROJ , c0 , c3 )
#pragma bind_symbol ( WORLDVIEW , c4 , c7 )
#pragma bind_symbol ( PROJ , c8 , c11 )
#pragma bind_symbol ( FOG_COLOR , c12 )
#pragma bind_symbol ( FOG_CONTROL , c13 )
#pragma bind_symbol ( RENDER_DISTANCE , c14 )
#pragma bind_symbol ( VIEWPORT_DIMENSION , c15 )
#pragma bind_symbol ( CURRENT_COLOR , c16 )
#pragma bind_symbol ( CHUNK_ORIGIN_AND_SCALE , c17 )
#pragma bind_symbol ( VIEW_POS , c18 )
#pragma bind_symbol ( FAR_CHUNKS_DISTANCE , c19 )

// Inputs, attribute
#pragma bind_symbol ( aPosition.xyz , v0 )
#pragma bind_symbol ( aColor.xyzw , v1 )
#pragma bind_symbol ( aTexCoord.xy , v2 )
#pragma bind_symbol ( bTexCoord.xy , v3 )

// Outputs, varing
#pragma output_map ( position , o0 )
#pragma output_map ( color , o1 )
#pragma output_map ( texture0 , o2 )
#pragma output_map ( texture1 , o3 )

def c40, 1.000000, -1.000000, 1.000000, 1.000000
def c41, 1.0, 1.0, 1.0, 0.1
def c42, 4.000000, 0.219606, 0.500000, 0.449997
def c43, 0.799995, 0.000000, 0.000000, 0.000000
def c50, 0.1, 0.1, 0.1, 0.1
def c51, 0.00001525, 0.00001525, 0.00001525, 0.00001525
def c52, 0.000000, 0.000000, 0.000000, 0.000000
def c56, 0.000000, 0.000000, 0.025000, 0.022346

normalizedepth:
mul r0.z, r0.zzzz, r0.wwww
add r0.z, -c56.zzzz, r0.zzzz
mul r0.z, c56.wwww, r0.zzzz
ret
endnormalizedepth:

length:
mul r15.x, r14.xxxx, r14.xxxx
mad r15.x, v15.yyyy, r14.yyyy, r15.xxxx
mad r15.x, v15.zzzz, r14.zzzz, r15.xxxx
rsq r15.y, r15.xxxx
mul r15.x, r15.xxxx, r15.yyyy
ret
endlength:

main:
mul r0.xyz, c17.wwww, v0.xyzz
add r1.xyz, c17.xyzz, r0.xyzz
mov r1.w, c40.xxxx
mov r3.xyzw, r1.xyzw
dp4 r2.x, c4.xyzw, r1.xyzw
dp4 r2.y, c5.xyzw, r1.xyzw
dp4 r2.z, c6.xyzw, r1.xyzw
dp4 r2.w, c7.xyzw, r1.xyzw
dp4 r0.x, c8.xyzw, r2.xyzw
dp4 r0.y, c9.xyzw, r2.xyzw
dp4 r0.z, c10.xyzw, r2.xyzw
dp4 r0.w, c11.xyzw, r2.xyzw
mov r0.xyz, r0.yxzz
mul o0.xyzw, c40.xyzw, r0.xyzw
mul r0.xyzw, c51.xyzw, v2.xyzw
slt r1.xyzw, r0.xyzw, c52.xyzw
add r2.xyzw, r0.xyzw, r1.xyzw
mov o2.xyzw, r2.xyzw
mul r0.xyzw, c51.xyzw, v3.xyzw
slt r1.xyzw, r0.xyzw, c52.xyzw
add r2.xyzw, r0.xyzw, r1.xyzw
mov o3.xyzw, r2.xyzw
mul r0.xyzw, c50.xyzw, v1.xyzw
mov r1.xyz, -r3.xyzz
mov r14.xyzw, r1.xyzw
call length
mov r4.y, r15.xxxx
rcp r5.x, c19.xxxx
mul r6.x, r4.yyyy, r5.xxxx
dp4 r7.x, r1.xyzw, r1.xyzw
rsq r7.x, r7.xxxx
mul r7.xyzw, r1.xyzw, r7.xxxx
dp3 r8.xyzw, c41.xyzw, r7.xyzw
max r9.x, c41.wwww, r8.xxxx
add r8.x, c40.xxxx, -r9.xxxx
min r9.x, c40.xxxx, r6.xxxx
log r10.x, r8.xxxx
mul r10.x, c42.xxxx, r10.xxxx
exp r10.x, r10.xxxx
add r14.xyzw, c40.xxxx, -r10.xxxx
mad r14.xyzw, v12.xyzw, r9.xxxx, r10.xxxx
add r8.x, c40.xxxx, -r14.xxxx
mul r9.xy, c42.yyyy, r8.xxxx
add r0.xy, r0.xyyy, -r9.xyyy
mul r10.xyz, c42.zzzz, r0.xyzz
mov r10.w, c40.xxxx
mul r11.xyz, c42.wwww, r0.xyzz
mov r11.w, c43.xxxx
mov r12.xyz, r0.xyzz
mov r12.w, c40.xxxx
add r13.xyzw, r10.xyzw, -r11.xyzw
mad r13.xyzw, v8.xyzw, r0.wwww, r11.xyzw
add r14.xyzw, r13.xyzw, -r12.xyzw
mad r14.xyzw, v12.xyzw, r8.xxxx, r12.xyzw
mov o1.xyzw, r14.xyzw
end
endmain: