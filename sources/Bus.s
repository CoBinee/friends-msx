; Bus.s : バス
;


; モジュール宣言
;
    .module Bus

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Road.inc"
    .include	"Bus.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; バスを初期化する
;
_BusInitialize::
    
    ; レジスタの保存
    
    ; 速度の設定
    xor     a
    ld      (bus + BUS_SPEED), a

    ; 加速度の設定
    ld      a, #BUS_ACCEL_MAX
    ld      (bus + BUS_ACCEL), a

    ; ジャンプの設定
    xor     a
    ld      (bus + BUS_JUMP_RISE), a
    ld      (bus + BUS_JUMP_STAY), a

    ; 落下の設定
    xor     a
    ld      (bus + BUS_FALL), a

    ; 位置と向きの設定
    ld      hl, #(bus + BUS_POSITION)
    ld      de, #0x0060
    ld      a, #(ROAD_STEP_UPPER - 0x01)
    ld      bc, #(((BUS_PATH_N + 0x01) << 8) | BUS_DIRECTION_RIGHT)
10$:
    ld      (hl), e
    inc     hl
    ld      (hl), d
    inc     hl
    ld      (hl), a
    inc     hl
    ld      (hl), c
    inc     hl
    dec     de
    dec     de
    djnz    10$

    ; アニメーションの設定
    xor     a
    ld      (bus + BUS_ANIMATION), a

    ; 爆発の設定
    xor     a
    ld      (bus + BUS_BOMB_X), a
    ld      (bus + BUS_BOMB_Y), a

    ; 状態の設定
    ld      a, #BUS_STATE_STAY
    ld      (bus + BUS_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; バスを更新する
;
_BusUpdate::
    
    ; レジスタの保存
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (bus + BUS_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #busProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; バスを描画する
;
_BusRender::
    
    ; レジスタの保存

    ; 爆発の表示
    ld      a, (bus + BUS_BOMB_X)
    ld      h, a
    ld      a, (bus + BUS_BOMB_Y)
    ld      l, a
    or      h
    jr      z, 19$
    ld      a, (bus + BUS_ANIMATION)
    and     #0x04
    jr      z, 19$
    ld      de, #0x0000
    ld      a, h
    cp      #0x80
    jr      nc, 10$
    ld      de, #0x2080
10$:
    ld      ix, #busSpriteBomb
    ld      iy, #(_sprite + GAME_SPRITE_BOMB)
    ld      b, #0x04
11$:
    ld      a, l
    add     a, 0x00(ix)
    ld      0x00(iy), a
    ld      a, h
    add     a, d
    add     a, 0x01(ix)
    ld      0x01(iy), a
    ld      a, 0x02(ix)
    ld      0x02(iy), a
    ld      a, 0x03(ix)
    or      e
    ld      0x03(iy), a
    push    de
    ld      de, #0x0004
    add     ix, de
    add     iy, de
    pop     de
    djnz    11$
19$:

    ; 車体の表示

    ; アニメーションの取得
    ld      a, (bus + BUS_ANIMATION)
    and     #0x02
    add     a, a
    ld      c, a

    ; 位置（前）の取得
    ld      de, (_gameCamera)
    ld      hl, (bus + BUS_POSITION_X)
    or      a
    sbc     hl, de
    ld      b, l

    ; スプライト（前）の表示
    ld      a, (bus + BUS_DIRECTION)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #(busSprite + 0x0000)
    add     hl, de

    ; 車体（前）の表示
    ld      de, #(_sprite + GAME_SPRITE_BUS_FRONT)
    ld      a, (bus + BUS_POSITION_Y)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
;   inc     de

    ; 車輪（前）の表示
    ld      de, #(_sprite + GAME_SPRITE_TIRE_FRONT)
    ld      a, (bus + BUS_POSITION_Y)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
;   inc     de

    ; ボス（前）の表示
    ld      de, #(_sprite + GAME_SPRITE_BOSS)
    ld      a, (bus + BUS_POSITION_Y)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
;   inc     de

    ; 位置（後）の取得
    ld      de, (_gameCamera)
    ld      hl, (bus + BUS_PATH_POSITION_X)
    or      a
    sbc     hl, de
    ld      b, l

    ; スプライト（後）の表示
    ld      a, (bus + BUS_PATH_DIRECTION)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #(busSprite + 0x0010)
    add     hl, de

    ; 車体（後）の表示
    ld      de, #(_sprite + GAME_SPRITE_BUS_BACK)
    ld      a, (bus + BUS_PATH_POSITION_Y)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
;   inc     de

    ; 車輪（後）の表示
    ld      de, #(_sprite + GAME_SPRITE_TIRE_BACK)
    ld      a, (bus + BUS_PATH_POSITION_Y)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
;   inc     de

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
BusNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret
    
; バスが待機する
;
BusStay:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (bus + BUS_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(bus + BUS_STATE)
    inc     (hl)
09$:

    ; レジスタの復帰

    ; 終了
    ret

_BusSetStay::

    ; レジスタの保存

    ; 状態の設定
    ld      a, #BUS_STATE_STAY
    ld      (bus + BUS_STATE), a

    ; レジスタの復帰

    ; 終了
    ret
    
; バスをプレイする
;
BusPlay:

    ; レジスタの保存

    ; 0x00: 初期化処理
    ld      a, (bus + BUS_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(bus + BUS_STATE)
    inc     (hl)
09$:

    ; 経路の更新
    ld      hl, #(bus + BUS_PATH_6 + BUS_PATH_SIZE - 0x01)
    ld      de, #(bus + BUS_PATH_7 + BUS_PATH_SIZE - 0x01)
    ld      bc, #(BUS_PATH_N * BUS_PATH_SIZE)
    lddr

    ; 向きの更新
    ld      hl, #(bus + BUS_DIRECTION)
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 10$
    ld      a, (hl)
    cp      #BUS_DIRECTION_RIGHT
    jr      nz, 19$
    ld      a, (bus + BUS_PATH_DIRECTION)
    cp      #BUS_DIRECTION_RIGHT
    jr      nz, 19$
    ld      a, #BUS_DIRECTION_RIGHT_FRONT
    ld      (hl), a
    jr      19$
10$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 19$
    ld      a, (hl)
    cp      #BUS_DIRECTION_LEFT
    jr      nz, 19$
    ld      a, (bus + BUS_PATH_DIRECTION)
    cp      #BUS_DIRECTION_LEFT
    jr      nz, 19$
    ld      a, #BUS_DIRECTION_LEFT_FRONT
    ld      (hl), a
;   jr      19$
19$:

    ; 加速度の更新
    ld      hl, #(bus + BUS_ACCEL)
    ld      de, #(bus + BUS_DIRECTION)
    ld      a, (de)
    and     #BUS_DIRECTION_FRONT
    jr      z, 20$
    dec     (hl)
    jr      nz, 29$
    ld      a, (de)
    xor     #BUS_DIRECTION_LR
    and     #~BUS_DIRECTION_FRONT
    ld      (de), a
    jr      29$
20$:
    ld      a, (hl)
    cp      #BUS_ACCEL_MAX
    jr      nc, 29$
    inc     (hl)
;   jr      29$
29$:

    ; X 位置の更新
    ld      hl, #(bus + BUS_SPEED)
    ld      a, (bus + BUS_ACCEL)
    add     a, (hl)
    ld      de, #0x0000
30$:
    sub     #BUS_SPEED_ONE
    jr      c, 31$
    inc     e
    jr      30$
31$:
    add     a, #BUS_SPEED_ONE
    ld      (hl), a
    ld      hl, (bus + BUS_POSITION_X)
    ld      a, (bus + BUS_DIRECTION)
    and     #BUS_DIRECTION_LR
    jr      nz, 32$
    or      a
    sbc     hl, de
    jr      33$
32$:
    add     hl, de
33$:
    ld      a, h
    and     #ROAD_SCROLL_MASK_H
    ld      h, a
    ld      (bus + BUS_POSITION_X), hl

    ; Y 位置の更新

    ; ジャンプ（上昇）の更新
    ld      hl,# (bus + BUS_JUMP_RISE)
    ld      a, (hl)
    or      a
    jr      z, 41$
    dec     (hl)
    ld      hl, (bus + BUS_POSITION_X)
    ld      a, (bus + BUS_POSITION_Y)
    sub     #(BUS_HEIGHT + 0x01)
    call    _RoadIsCollision
    ld      hl, #(bus + BUS_POSITION_Y)
    jr      c, 40$
    dec     (hl)
    dec     (hl)
    jp      49$
40$:
    ld      a, (hl)
    sub     #(BUS_HEIGHT + 0x01)
    and     #0xf8
    add     a, #(BUS_HEIGHT + 0x08)
    ld      (hl), a
    xor     a
    ld      (bus + BUS_JUMP_RISE), a
    jp      49$
41$:

    ; ジャンプ（滞空）の更新
    ld      hl,# (bus + BUS_JUMP_STAY)
    ld      a, (hl)
    or      a
    jr      z, 42$
    dec     (hl)
    ld      hl, (bus + BUS_POSITION_X)
    ld      a, (bus + BUS_POSITION_Y)
    sub     #BUS_HEIGHT
    call    _RoadIsCollision
    jp      nc, 49$
    ld      hl, #(bus + BUS_POSITION_Y)
    ld      a, (hl)
    sub     #BUS_HEIGHT
    and     #0xf8
    add     a, #(BUS_HEIGHT + 0x08)
    ld      (hl), a
    xor     a
    ld      (bus + BUS_JUMP_STAY), a
    jp      49$
42$:

    ; 落下の更新
    ld      a, (bus + BUS_DIRECTION)
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      ix, #busCollisionDown
    add     ix, de
    ld      e, 0x00(ix)
    ld      d, 0x01(ix)
    ld      hl, (bus + BUS_POSITION_X)
    add     hl, de
    ld      a, h
    and     #ROAD_SCROLL_MASK_H
    ld      h, a
    ld      a, (bus + BUS_POSITION_Y)
    inc     a
    call    _RoadIsCollision
    jr      c, 44$
    ld      e, 0x02(ix)
    ld      d, 0x03(ix)
    ld      hl, (bus + BUS_POSITION_X)
    add     hl, de
    ld      a, h
    and     #ROAD_SCROLL_MASK_H
    ld      h, a
    ld      a, (bus + BUS_POSITION_Y)
    inc     a
    call    _RoadIsCollision
    jr      c, 44$
    ld      a, (bus + BUS_FALL)
    or      a
    jr      nz, 43$
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    ld      a, #BUS_FALL_NORMAL
    jr      z, 43$
    ld      a, #BUS_FALL_FAST
43$:
    ld      (bus + BUS_FALL), a
    ld      hl, #(bus + BUS_POSITION_Y)
    add     a, (hl)
    ld      (hl), a
    jr      49$
44$:

    ; 走行の更新
    ld      hl, #(bus + BUS_POSITION_Y)
    ld      a, (hl)
    inc     a
    and     #0xf8
    dec     a
    ld      (hl), a
    ld      hl, (bus + BUS_POSITION_X)
    inc     a
    call    _RoadPass
    xor     a
    ld      (bus + BUS_FALL), a
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 49$
    ld      hl, #((BUS_JUMP_STAY_NORMAL << 8) | (BUS_JUMP_RISE_NORMAL))
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 45$
    ld      hl, #((BUS_JUMP_STAY_HIGH << 8) | (BUS_JUMP_RISE_HIGH))
45$:
    ld      (bus + BUS_JUMP_RISE), hl
    ld      a, #BUS_FALL_NORMAL
    ld      (bus + BUS_FALL), a
;   jr      49$

    ; Y 位置更新の完了
49$:

    ; プレイの完了
90$:

    ; アニメーションの更新
    ld      hl, #(bus + BUS_ANIMATION)
    inc     (hl)

    ; レジスタの復帰

    ; 終了
    ret
    
_BusSetPlay::

    ; レジスタの保存

    ; 状態の設定
    ld      a, #BUS_STATE_PLAY
    ld      (bus + BUS_STATE), a

    ; レジスタの復帰

    ; 終了
    ret
    
; バスがミスする
;
BusMiss:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (bus + BUS_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(bus + BUS_STATE)
    inc     (hl)
09$:

    ; アニメーションの更新
    ld      hl, #(bus + BUS_ANIMATION)
    inc     (hl)

    ; レジスタの復帰

    ; 終了
    ret

_BusSetMiss::

    ; レジスタの保存

    ; 爆発の位置の設定
    ld      a, h
    ld      (bus + BUS_BOMB_X), a
    ld      a, l
    ld      (bus + BUS_BOMB_Y), a

    ; 状態の設定
    ld      a, #BUS_STATE_MISS
    ld      (bus + BUS_STATE), a

    ; レジスタの復帰

    ; 終了
    ret
    
; バスの位置を取得する
;
_BusGetFrontPosition::

    ; レジスタの保存

    ; バスの位置の取得
    ld      hl, (bus + BUS_POSITION_X)
    ld      a, (bus + BUS_POSITION_Y)

    ; レジスタの復帰

    ; 終了
    ret
    
_BusGetBackPosition::

    ; レジスタの保存

    ; バスの位置の取得
    ld      hl, (bus + BUS_PATH_POSITION_X)
    ld      a, (bus + BUS_PATH_POSITION_Y)

    ; レジスタの復帰

    ; 終了
    ret
    
; 定数の定義
;

; 状態別の処理
;
busProc:
    
    .dw     BusNull
    .dw     BusStay
    .dw     BusPlay
    .dw     BusMiss

; コリジョン
;
busCollisionDown:

    .dw     0xfffe, 0x0005
    .dw     0xfff9, 0x0006
    .dw     0xfffa, 0x0001
    .dw     0xfff9, 0x0006

; スプライト
;
busSprite:

    .db     0xee, 0xf8, 0x20, 0x0a, 0xfb, 0xfa, 0x40, 0x01, 0xea, 0xf8, 0x04, 0x07, 0x00, 0x00, 0x00, 0x00
    .db     0xee, 0xf8, 0x24, 0x0a, 0xfb, 0xf8, 0x48, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0xee, 0xf8, 0x30, 0x0a, 0xfb, 0xf8, 0x50, 0x01, 0xea, 0xf8, 0x0c, 0x07, 0x00, 0x00, 0x00, 0x00 
    .db     0xee, 0xf8, 0x34, 0x0a, 0xfb, 0xf8, 0x58, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0xee, 0xf8, 0x2c, 0x0a, 0xfb, 0xf6, 0x40, 0x01, 0xea, 0xf8, 0x08, 0x07, 0x00, 0x00, 0x00, 0x00
    .db     0xee, 0xf8, 0x28, 0x0a, 0xfb, 0xf7, 0x48, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0xee, 0xf8, 0x30, 0x0a, 0xfb, 0xf8, 0x50, 0x01, 0xea, 0xf8, 0x0c, 0x07, 0x00, 0x00, 0x00, 0x00
    .db     0xee, 0xf8, 0x34, 0x0a, 0xfb, 0xf8, 0x58, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

busSpriteBomb:

    .db     0xe8, 0xf0, 0x10, 0x08, 0xe8, 0x00, 0x14, 0x08, 0xf8, 0xf0, 0x18, 0x08, 0xf8, 0x00, 0x1c, 0x08


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; バス
;
bus:

    .ds     BUS_SIZE
