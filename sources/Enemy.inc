; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_TYPE                      =   0x00
ENEMY_STATE                     =   0x01
ENEMY_POSITION                  =   0x02
ENEMY_POSITION_X                =   0x02
ENEMY_POSITION_X_L              =   0x02
ENEMY_POSITION_X_H              =   0x03
ENEMY_POSITION_Y                =   0x04
ENEMY_AMPLITUDE                 =   0x05
ENEMY_DIRECTION                 =   0x06
ENEMY_SPEED                     =   0x07
ENEMY_STEP                      =   0x08
ENEMY_STEP_Y                    =   0x09
ENEMY_ANIMATION                 =   0x0f
ENEMY_SIZE                      =   0x10
ENEMY_N                         =   0x08

; 種類
ENEMY_TYPE_SLOW                 =   0x00
ENEMY_TYPE_FAST                 =   0x01

; 状態
ENEMY_STATE_NULL                =   0x00
ENEMY_STATE_STAY                =   0x10
ENEMY_STATE_MOVE                =   0x20
ENEMY_STATE_STEP                =   0x30

; 向き
ENEMY_DIRECTION_LEFT            =   0x00
ENEMY_DIRECTION_RIGHT           =   0x02

; 段
ENEMY_STEP_UP                   =   0x00
ENEMY_STEP_DOWN                 =   0x01

; ヒット
ENEMY_HIT_WIDTH                 =   0x0a
ENEMY_HIT_HEIGHT                =   0x0a

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemySetStay
    .globl  _EnemySetMove
    .globl  _EnemyIsHit

; 外部変数宣言
;

