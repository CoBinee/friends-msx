; Bus.inc : バス
;


; マクロの定義
;

; バス
BUS_STATE                       =   0x00
BUS_SPEED                       =   0x01
BUS_ACCEL                       =   0x02
BUS_JUMP_RISE                   =   0x03
BUS_JUMP_STAY                   =   0x04
BUS_FALL                        =   0x05
BUS_ANIMATION                   =   0x07
BUS_POSITION                    =   0x08
BUS_POSITION_X                  =   0x08
BUS_POSITION_X_L                =   0x08
BUS_POSITION_X_H                =   0x09
BUS_POSITION_Y                  =   0x0a
BUS_DIRECTION                   =   0x0b
BUS_PATH                        =   0x0c
BUS_PATH_0                      =   0x0c
BUS_PATH_1                      =   0x10
BUS_PATH_2                      =   0x14
BUS_PATH_3                      =   0x18
BUS_PATH_4                      =   0x1c
BUS_PATH_5                      =   0x20
BUS_PATH_6                      =   0x24
BUS_PATH_7                      =   0x28
BUS_PATH_POSITION_X             =   0x28
BUS_PATH_POSITION_X_L           =   0x28
BUS_PATH_POSITION_X_H           =   0x29
BUS_PATH_POSITION_Y             =   0x2a
BUS_PATH_DIRECTION              =   0x2b
BUS_PATH_N                      =   0x08
BUS_PATH_SIZE                   =   0x04
BUS_BOMB_X                      =   0x2c
BUS_BOMB_Y                      =   0x2d
BUS_SIZE                        =   0x2e

; 状態
BUS_STATE_NULL                  =   0x00
BUS_STATE_STAY                  =   0x10
BUS_STATE_PLAY                  =   0x20
BUS_STATE_MISS                  =   0x30

; 向き
BUS_DIRECTION_LEFT              =   0x00
BUS_DIRECTION_LEFT_FRONT        =   0x01
BUS_DIRECTION_RIGHT             =   0x02
BUS_DIRECTION_RIGHT_FRONT       =   0x03
BUS_DIRECTION_LR                =   0x02
BUS_DIRECTION_FRONT             =   0x01

; 速度
BUS_SPEED_MAX                   =   0x08
BUS_SPEED_ONE                   =   0x04

; 加速度
BUS_ACCEL_MAX                   =   0x08
BUS_ACCEL_ONE                   =   0x04

; ジャンプ
BUS_JUMP_RISE_NORMAL            =   0x0a
BUS_JUMP_RISE_HIGH              =   0x18
BUS_JUMP_STAY_NORMAL            =   0x10
BUS_JUMP_STAY_HIGH              =   0x04

; 落下
BUS_FALL_NORMAL                 =   0x02
BUS_FALL_FAST                   =   0x04

; 高さ
BUS_HEIGHT                      =   0x0f

; 外部関数宣言
;

    .globl  _BusInitialize
    .globl  _BusUpdate
    .globl  _BusRender
    .globl  _BusSetStay
    .globl  _BusSetPlay
    .globl  _BusSetMiss
    .globl  _BusGetFrontPosition
    .globl  _BusGetBackPosition

; 外部変数宣言
;

