; App.s : アプリケーション
;


; モジュール宣言
;
    .module App

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Title.inc"
    .include    "Game.inc"

; 外部変数宣言
;
    .globl  _patternTable


; CODE 領域
;
    .area   _CODE

; アプリケーションを初期化する
;
_AppInitialize::
    
    ; レジスタの保存
    
    ; アプリケーションの初期化
    
    ; 画面表示の停止
    call    DISSCR
    
    ; ビデオの設定
    ld      hl, #videoScreen1
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)
    
    ; 割り込みの禁止
    di
    
    ; VDP ポートの取得
    ld      a, (_videoPort + 1)
    ld      c, a
    
    ; スプライトジェネレータの転送
    inc     c
    ld      a, #<APP_SPRITE_GENERATOR_TABLE
    out     (c), a
    ld      a, #(>APP_SPRITE_GENERATOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(_patternTable + 0x0000)
    ld      d, #0x08
10$:
    ld      e, #0x10
11$:
    push    de
    ld      b, #0x08
    otir
    ld      de, #0x78
    add     hl, de
    ld      b, #0x08
    otir
    ld      de, #0x80
    or      a
    sbc     hl, de
    pop     de
    dec     e
    jr      nz, 11$
    ld      a, #0x80
    add     a, l
    ld      l, a
    ld      a, h
    adc     a, #0x00
    ld      h, a
    dec     d
    jr      nz, 10$
    
    ; パターンジェネレータの転送
    ld      hl, #(_patternTable + 0x0800)
    ld      de, #APP_PATTERN_GENERATOR_TABLE
    ld      bc, #0x0800
    call    LDIRVM
    
    ; カラーテーブルの転送
    ld      hl, #appColorTable
    ld      de, #APP_COLOR_TABLE
    ld      bc, #0x0020
    call    LDIRVM

    ; パターンネームの初期化
    ld      hl, #APP_PATTERN_NAME_TABLE
    ld      a, #0x00
    ld      bc, #0x0300
    call    FILVRM

    ; パターンネームのクリア
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0001)
    ld      bc, #0x02ff
    ld      (hl), #0x00
    ldir

    ; 割り込み禁止の解除
    ei
    
    ; スコアの初期化
    ld      hl, #appScoreDefault
    ld      de, #_appScore
    ld      bc, #APP_SCORE_SIZE
    ldir
    
    ; 状態の初期化
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; アプリケーションを更新する
;
_AppUpdate::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_appState)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #appProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:
    
    ; 更新の終了
99$:

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; 処理なし
;
_AppNull::

    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; パターンネームを転送する
;
_AppTransferPatternName:

    ; レジスタの保存
    
    ; パターンネームの転送
    xor     a
    ld      hl, #(_appPatternName + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_0_BYTES), a
    ld      hl, #(_appPatternName + 0x0100)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0100)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_1_BYTES), a
    ld      hl, #(_appPatternName + 0x0200)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0200)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_DST), hl
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_2_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; VDP レジスタ値（スクリーン１）
;
videoScreen1:

    .db     0b00000000
    .db     0b10100010
    .db     APP_PATTERN_NAME_TABLE >> 10
    .db     APP_COLOR_TABLE >> 6
    .db     APP_PATTERN_GENERATOR_TABLE >> 11
    .db     APP_SPRITE_ATTRIBUTE_TABLE >> 7
    .db     APP_SPRITE_GENERATOR_TABLE >> 11
    .db     0b00000111

; カラーテーブル
;
appColorTable:

    .db     0xf4, 0xf4
    .db     0xf4, 0x64
    .db     0xf4, 0xf4
    .db     0xf4, 0x64
    .db     0xf4, 0xf4
    .db     0xf4, 0x69
    .db     0xfc, 0xfc
    .db     0xfc, 0xc3
    .db     0xfc, 0xfc
    .db     0xfc, 0xf4
    .db     0xfc, 0xfc
    .db     0xfc, 0xf1
    .db     0xf4, 0xf4
    .db     0xf1, 0xf1
    .db     0xf1, 0xf1
    .db     0xf1, 0xf1

; 状態別の処理
;
appProc:
    
    .dw     _AppNull
    .dw     _TitleInitialize
    .dw     _TitleUpdate
    .dw     _GameInitialize
    .dw     _GameUpdate

; スコア
;
appScoreDefault:

    .db     0x01, 0x00, 0x00, 0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
_appState::

    .ds     0x01

; スコア
;
_appScore::

    .ds     APP_SCORE_SIZE

; パターンネーム
;
_appPatternName::

    .ds     0x0300

