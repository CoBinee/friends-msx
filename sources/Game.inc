; Game.inc : ゲーム
;


; マクロの定義
;

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_START                =   0x10
GAME_STATE_PLAY                 =   0x20
GAME_STATE_MISS                 =   0x30
GAME_STATE_OVER                 =   0x40
GAME_STATE_CLEAR                =   0x50
GAME_STATE_END                  =   0x60

; スプライト
GAME_SPRITE_BOMB                =   0x00
GAME_SPRITE_BUS_FRONT           =   0x10
GAME_SPRITE_BUS_BACK            =   0x14
GAME_SPRITE_TIRE_FRONT          =   0x78
GAME_SPRITE_TIRE_BACK           =   0x7c
GAME_SPRITE_BOSS                =   0x74
GAME_SPRITE_ENEMY               =   0x20
GAME_SPRITE_FACE                =   0x00

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate

; 外部変数宣言
;

    .globl  _gameCamera
    .globl  _gameDebug
    