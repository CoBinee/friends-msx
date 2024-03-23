; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Road.inc"
    .include	"Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存

    ; エネミーの種類の取得
    ld      hl, #enemyTypeDefault
    ld      de, #enemyType
    ld      bc, #ENEMY_N
    ldir
    ld      hl, #enemyType
    ld      b, #ENEMY_N
10$:
    push    hl
    call    _SystemGetRandom
    and     #(ENEMY_N - 0x01)
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyType
    add     hl, de
    ex      de, hl
    pop     hl
    ld      c, (hl)
    ld      a, (de)
    ld      (hl), a
    ld      a, c
    ld      (de), a
    inc     hl
    djnz    10$

    ; エネミーの走査
    ld      ix, #enemy
    ld      iy, #enemyType
    ld      bc, #((ENEMY_N << 8) | 0x00)
20$:

    ; 種類の設定
    ld      a, 0x00(iy)
    ld      ENEMY_TYPE(ix), a

    ; 位置の設定
    ld      a, c
    xor     #0x02
    rra
    add     a, c
    add     a, c
    and     #0x03
    ld      ENEMY_POSITION_X_H(ix), a
    call    _SystemGetRandom
    ld      ENEMY_POSITION_X_L(ix), a
    ld      a, c
    and     #0xfe
    add     a, a
    add     a, a
    ld      h, a
    add     a, a
    add     a, a
    add     a, h
    add     a, #(ROAD_STEP_UPPER - 0x01)
    ld      ENEMY_POSITION_Y(ix), a

    ; 振幅の設定
    xor     a
    ld      ENEMY_AMPLITUDE(ix), a

    ; 向きの設定
    call    _SystemGetRandom
    and     #0x01
    ld      ENEMY_DIRECTION(ix), a

    ; 速度の設定
    ld      a, ENEMY_TYPE(ix)
    inc     a
    ld      ENEMY_SPEED(ix), a

    ; アニメーションの設定
    call    _SystemGetRandom
    ld      ENEMY_ANIMATION(ix), a

    ; 状態の設定
    ld      a, #ENEMY_STATE_STAY
    ld      ENEMY_STATE(ix), a

    ; 次のエネミーへ
    ld      de, #ENEMY_SIZE
    add     ix, de
    inc     iy
    inc     c
    djnz    20$
    
    ; スプライトローテーションの初期化
    xor     a
    ld      (enemySpriteRotation), a

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存
    
    ; エネミーの走査
    ld      ix, #enemy
    ld      b, #ENEMY_N
10$:

    ; 状態別の処理
    push    bc
    ld      hl, #11$
    push    hl
    ld      a, ENEMY_STATE(ix)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
11$:
    pop     bc

    ; 次のエネミーへ
    ld      de, #ENEMY_SIZE
    add     ix, de
    djnz    10$

    ; スプライトローテーションの更新
    ld      hl, #enemySpriteRotation
    ld      a, (hl)
    add     a, #0x04
    and     #(ENEMY_N * 0x04 - 0x01)
    ld      (hl), a

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::
    
    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #enemy
    ld      a, (enemySpriteRotation)
    ld      c, a
    ld      b, #ENEMY_N
10$:
    push    bc

    ; スプライトの取得
    ld      b, #0x00
    ld      hl, #(_sprite + GAME_SPRITE_ENEMY)
    add     hl, bc
    ex      de, hl

    ; 位置の取得
    ld      l, ENEMY_POSITION_X_L(ix)
    ld      h, ENEMY_POSITION_X_H(ix)
    ld      bc, (_gameCamera)
    or      a
    sbc     hl, bc
    ld      c, l
    ld      b, #0x00
    ld      a, h
    and     #ROAD_SCROLL_MASK_H
    jr      nz, 11$
    ld      a, l
    cp      #0x08
    jr      nc, 14$
    jr      13$
11$:
    cp      #0x01
    jr      nz, 12$
    ld      a, l
    cp      #0x08
    jr      nc, 19$
    jr      14$
12$:
    cp      #ROAD_SCROLL_MASK_H
    jr      nz, 19$
    ld      a, l
    cp      #0xf8
    jr      c, 19$
13$:
    ld      a, c
    add     a, #0x20
    ld      c, a
    ld      b, #0x80
14$:
    
    ; スプライトの表示
    push    bc
    ld      a, ENEMY_TYPE(ix)
    add     a, a
    add     a, ENEMY_DIRECTION(ix)
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #enemySprite
    add     hl, bc
    pop     bc
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, ENEMY_AMPLITUDE(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, b
    add     a, (hl)
    ld      (de), a
;   inc     hl
;   inc     de

    ; 次のエネミーへ
19$:
    ld      de, #ENEMY_SIZE
    add     ix, de
    pop     bc
    ld      a, c
    add     a, #0x04
    and     #(ENEMY_N * 0x04 - 0x01)
    ld      c, a
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
EnemyNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret
    
; エネミーが待機する
;
EnemyStay:

    ; レジスタの保存

    ; 初期化処理
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 振幅の更新
    call    EnemyAmplitude

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

_EnemySetStay::

    ; レジスタの保存

    ; 状態の設定
    ld      a, #ENEMY_STATE_STAY
    call    EnemySetState

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが直進する
;
EnemyMove:

    ; レジスタの保存

    ; 初期化処理
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 段の設定
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #ROAD_STEP_UPPER
    jr      nc, 00$
    ld      a, #ENEMY_STEP_DOWN
    jr      02$
00$:
    cp      #(ROAD_STEP_LOWER - ROAD_STEP_HEIGHT)
    jr      c, 01$
    ld      a, #ENEMY_STEP_UP
    jr      02$
01$:
    call    _SystemGetRandom
    and     #0x01
02$:
    ld      ENEMY_STEP(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; コリジョンの取得
    ld      l, ENEMY_POSITION_X_L(ix)
    ld      h, ENEMY_POSITION_X_H(ix)
    ld      c, ENEMY_POSITION_Y(ix)
    inc     c
    ld      a, ENEMY_STEP(ix)
    cp      #ENEMY_STEP_UP
    ld      a, c
    jr      nz, 10$
    sub     #ROAD_STEP_HEIGHT
10$:
    call    _RoadIsCollision
    ld      a, #0x00
    adc     a, a
    ld      c, a

    ; 段を変えられる位置まで移動
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    dec     a
    jr      nz, 20$
    ld      a, c
    or      a
    jr      z, 29$
    inc     ENEMY_STATE(ix)
20$:
    ld      a, c
    or      a
    jr      nz, 29$
    ld      a, #ENEMY_STATE_STEP
    ld      ENEMY_STATE(ix), a
29$:

    ; X 方向の移動
    call    EnemyMoveX

    ; 振幅の更新
    call    EnemyAmplitude

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

_EnemySetMove::

    ; レジスタの保存

    ; 状態の設定
    ld      a, #ENEMY_STATE_MOVE
    call    EnemySetState

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが段を移動する
;
EnemyStep:

    ; レジスタの保存

    ; 初期化処理
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 段の設定
    ld      a, #ROAD_STEP_HEIGHT
    ld      ENEMY_STEP_Y(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; Y 方向の移動
    ld      a, ENEMY_STEP(ix)
    cp      #ENEMY_STEP_UP
    ld      a, ENEMY_POSITION_Y(ix)
    jr      nz, 10$
    sub     ENEMY_SPEED(ix)
    jr      11$
10$:
    add     a, ENEMY_SPEED(ix)
11$:
    ld      ENEMY_POSITION_Y(ix), a
    ld      a, ENEMY_STEP_Y(ix)
    sub     ENEMY_SPEED(ix)
    ld      ENEMY_STEP_Y(ix), a
    jr      nz, 19$
    ld      a, #ENEMY_STATE_MOVE
    ld      ENEMY_STATE(ix), a
19$:

    ; X 方向の移動
    call    EnemyMoveX

    ; 振幅の更新
    call    EnemyAmplitude

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; エネミーの状態をまとめて設定する
;
EnemySetState:

    ; レジスタの保存

    ; 状態の設定
    ld      hl, #(enemy + ENEMY_STATE)
    ld      de, #ENEMY_SIZE
    ld      b, #ENEMY_N
10$:
    ld      (hl), a
    add     hl, de
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; エネミーの X 位置を移動する
;
EnemyMoveX:

    ; レジスタの保存

    ; X 方向の移動
    ld      l, ENEMY_POSITION_X_L(ix)
    ld      h, ENEMY_POSITION_X_H(ix)
    ld      e, ENEMY_SPEED(ix)
    ld      d, #0x00
    ld      a, ENEMY_DIRECTION(ix)
    or      a
    jr      nz, 10$
    sbc     hl, de
    jr      11$
10$:
    add     hl, de
11$:
    ld      a, h
    and     #ROAD_SCROLL_MASK_H
    ld      ENEMY_POSITION_X_L(ix), l
    ld      ENEMY_POSITION_X_H(ix), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを振幅させる
;
EnemyAmplitude:

    ; レジスタの保存

    ; 振幅の更新
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x1c
    rra
    rra
    sub     #0x04
    jp      m, 10$
    neg
10$:
    ld      ENEMY_AMPLITUDE(ix), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーとのヒット判定を行う
;
_EnemyIsHit::

    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #enemy
    ld      b, #ENEMY_N
10$:
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, ENEMY_AMPLITUDE(ix)
    sub     l
    cp      #ENEMY_HIT_HEIGHT
    jr      c, 11$
    cp      #-ENEMY_HIT_HEIGHT
    jr      c, 18$
11$:
    push    hl
    ld      l, ENEMY_POSITION_X_L(ix)
    ld      h, ENEMY_POSITION_X_H(ix)
    ld      de, (_gameCamera)
    or      a
    sbc     hl, de
    ld      a, h
    ld      c, l
    pop     hl
    and     #0x03
    jr      nz, 18$
    ld      a, c
    sub     h
    cp      #ENEMY_HIT_WIDTH
    jr      c, 17$
    cp      #-ENEMY_HIT_WIDTH
    jr      c, 18$
17$:
    sra     a
    add     a, h
    ld      h, a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     l
    sra     a
    add     a, l
    ld      l, a
    scf
    jr      19$
18$:
    ld      de, #ENEMY_SIZE
    add     ix, de
    djnz    10$
    or      a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
enemyProc:
    
    .dw     EnemyNull
    .dw     EnemyStay
    .dw     EnemyMove
    .dw     EnemyStep

; スプライト
;
enemySprite:

    .db     0xf0, 0xf8, 0x38, 0x07, 0xf0, 0xf8, 0x3c, 0x07
    .db     0xf0, 0xf8, 0x38, 0x0d, 0xf0, 0xf8, 0x3c, 0x0d

; 種類のデフォルトテーブル
;
enemyTypeDefault:

    .db     ENEMY_TYPE_FAST, ENEMY_TYPE_SLOW, ENEMY_TYPE_SLOW, ENEMY_TYPE_SLOW
    .db     ENEMY_TYPE_FAST, ENEMY_TYPE_SLOW, ENEMY_TYPE_SLOW, ENEMY_TYPE_SLOW


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
enemy:

    .ds     ENEMY_SIZE * ENEMY_N

; スプライトローテーション
;
enemySpriteRotation:

    .ds     0x01

; 種類
;
enemyType:

    .ds     ENEMY_N

