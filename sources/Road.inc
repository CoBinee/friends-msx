; Road.inc : 道
;


; マクロの定義
;

; 状態
ROAD_STATE_NULL                 =   0x00
ROAD_STATE_PLAY                 =   0x10

; 道
ROAD_WIDTH                      =   0x80
ROAD_HEIGHT                     =   0x04
ROAD_NULL                       =   0x00
ROAD_NORMAL                     =   0x01
ROAD_PASS                       =   0x02

; スクロール 
ROAD_SCROLL                     =   0x0400
ROAD_SCROLL_MASK_L              =   0xff
ROAD_SCROLL_MASK_H              =   0x03

; 段
ROAD_STEP_0                     =   0x38
ROAD_STEP_1                     =   0x60
ROAD_STEP_2                     =   0x88
ROAD_STEP_3                     =   0xb0
ROAD_STEP_UPPER                 =   0x38
ROAD_STEP_LOWER                 =   0xb0
ROAD_STEP_HEIGHT                =   0x28

; 距離
ROAD_DISTANCE_SIZE              =   0x03

; 外部関数宣言
;

    .globl  _RoadInitialize
    .globl  _RoadUpdate
    .globl  _RoadRender
    .globl  _RoadIsCollision
    .globl  _RoadPass
    .globl  _RoadIsPass

; 外部変数宣言
;

    .globl  _roadDistancePass
    .globl  _roadDistanceTotal
