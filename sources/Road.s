; Road.s : 道
;


; モジュール宣言
;
    .module Road

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Road.inc"

; 外部変数宣言
;
    .globl  _patternTable

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 道を初期化する
;
_RoadInitialize::
    
    ; レジスタの保存
    
    ; 道の設定
    ld      hl, #(road + 0x0000)
    ld      de, #(road + 0x0001)
    ld      bc, #(ROAD_WIDTH * ROAD_HEIGHT - 0x0001)
    ld      (hl), #0x01
    ldir
    ld      de, #0x0018
    ld      hl, #(road + 0x00 * ROAD_WIDTH)
    call    10$
    call    _SystemGetRandom
    and     #0x18
    ld      e, a
    ld      d, #0x00
    ld      hl, #(road + 0x01 * ROAD_WIDTH)
    call    10$
    call    _SystemGetRandom
    and     #0x18
    ld      e, a
    ld      d, #0x00
    ld      hl, #(road + 0x02 * ROAD_WIDTH)
    call    10$
    jr      19$
10$:
    ld      c, #0x04
11$:
    add     hl, de
    xor     a
    ld      b, #0x08
12$:
    ld      (hl), a
    inc     hl
    djnz    12$
    ld      e, #0x18
    dec     c
    jr      nz, 11$
    ret
19$:

    ; 距離の設定
    xor     a
    ld      (_roadDistancePass + 0x0000), a
    ld      (_roadDistancePass + 0x0001), a
    ld      (_roadDistancePass + 0x0002), a
    ld      a, #((24 * 4 * 3 + 32 * 4) / 100)
    ld      (_roadDistanceTotal + 0x0000), a
    ld      a, #(((24 * 4 * 3 + 32 * 4) / 10) % 10)
    ld      (_roadDistanceTotal + 0x0001), a
    ld      a, #((24 * 4 * 3 + 32 * 4) % 10)
    ld      (_roadDistanceTotal + 0x0002), a

    ; 状態の設定
    ld      a, #ROAD_STATE_PLAY
    ld      (roadState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 道を更新する
;
_RoadUpdate::
    
    ; レジスタの保存
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (roadState)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #roadProc
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

; 道を描画する
;
_RoadRender::
    
    ; レジスタの保存

    ; 道の描画
    ld      de, (_gameCamera)
    ld      a, e
    srl     d
    rr      e
    srl     d
    rr      e
    srl     d
    rr      e
    ld      ix, #road
    add     ix, de
    and     #0x07
    ld      d, a
    ld      hl, #(_appPatternName + 0x00e0)
    ld      b, #ROAD_HEIGHT
10$:
    push    bc
    push    ix
    ld      c, e
    ld      b, #0x20
11$:
    ld      a, 0x00(ix)
    inc     ix
    inc     c
    push    af
    ld      a, c
    and     #(ROAD_WIDTH - 0x01)
    jr      nz, 12$
    ld      c, a
    push    bc
    ld      bc, #-ROAD_WIDTH
    add     ix, bc
    pop     bc
12$:
    pop     af
    add     a, a
    add     a, a
    add     a, 0x00(ix)
    add     a, a
    add     a, a
    add     a, a
    add     a, d
    ld      (hl), a
    inc     hl
    djnz    11$
    pop     ix
    ld      bc, #ROAD_WIDTH
    add     ix, bc
    ld      bc, #0x0080
    add     hl, bc
    pop     bc
    ld      a, b
    cp      #(ROAD_HEIGHT / 2 + 1)
    jr      nz, 13$
    ld      a, #0x60
    add     a, d
    ld      d, a
13$:
    djnz    10$

    ; パターンネームの転送
    ld      a, #(0x20)
    ld      hl, #(_appPatternName + 0x00e0)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x00e0)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    ld      hl, #(_appPatternName + 0x0180)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0180)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    ld      hl, #(_appPatternName + 0x0220)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0220)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_BYTES), a
    ld      hl, #(_appPatternName + 0x02c0)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x02c0)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_3_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
RoadNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret
    
; 道をプレイする
;
RoadPlay:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (roadState)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #roadState
    inc     (hl)
09$:

    ; レジスタの復帰

    ; 終了
    ret

; 道の参照を計算する
;
RoadCalc:

    ; レジスタの保存

    ; 参照の取得
    and     #0xf8
    rra
    rra
    rra
    ld      c, #0x00
    cp      #0x07
    jr      z, 10$
    inc     c
    cp      #0x0c
    jr      z, 10$
    inc     c
    cp      #0x11
    jr      z, 10$
    inc     c
    cp      #0x16
    jr      z, 10$
    ld      hl, #0x0000
    jr      19$
10$:
    ld      a, l
    srl     h
    rra
    srl     h
    rra
    srl     h
    rra
    ld      h, c
    ld      l, #0x00
    srl     h
    rr      l
    ld      c, a
    ld      b, #0x00
    add     hl, bc
    ld      bc, #road
    add     hl, bc
19$:
    
    ; レジスタの復帰

    ; 終了
    ret

; コリジョンを判定する
;
_RoadIsCollision::

    ; レジスタの保存

    ; 参照の取得
    call    RoadCalc
    ld      a, h
    or      l
    jr      z, 19$
    ld      a, (hl)
    or      a
    jr      z, 19$
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 道を通る
;
_RoadPass::

    ; レジスタの保存

    ; 参照の取得
    call    RoadCalc
    ld      a, h
    or      l
    jr      z, 19$
    ld      a, (hl)
    cp      #ROAD_NORMAL
    jr      nz, 19$
    ld      a, #ROAD_PASS
    ld      (hl), a
    ld      hl, #(_roadDistancePass + ROAD_DISTANCE_SIZE - 0x01)
10$:
    inc     (hl)
    ld      a, (hl)
    cp      #0x0a
    jr      c, 19$
    xor     a
    ld      (hl), a
    dec     hl
    jr      10$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; すべての道を通ったかを判定する
;
_RoadIsPass::

    ; レジスタの保存

    ; 道の判定
    ld      hl, #_roadDistancePass
    ld      de, #_roadDistanceTotal
    ld      b, #ROAD_DISTANCE_SIZE
10$:
    ld      a, (de)
    cp      (hl)
    jr      nz, 11$
    inc     hl
    inc     de
    djnz    10$
    scf
    jr      19$
11$:
    or      a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
roadProc:
    
    .dw     RoadNull
    .dw     RoadPlay


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
roadState:
    
    .ds     0x01

; 道
;
road:

    .ds     ROAD_WIDTH * ROAD_HEIGHT

; 距離
;
_roadDistancePass::

    .ds     ROAD_DISTANCE_SIZE

_roadDistanceTotal::

    .ds     ROAD_DISTANCE_SIZE
