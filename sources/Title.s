; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Title.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; パターンネームのクリア
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0001)
    ld      bc, #0x02ff
    ld      (hl), #0xd0
    ldir
    ld      hl, #titlePatternNameScore
    ld      de, #(_appPatternName + 0x028c)
    ld      bc, #0x0004
    ldir
    ld      hl, #_appScore
    ld      b, #APP_SCORE_SIZE
10$:
    ld      a, (hl)
    add     a, #0xf0
    ld      (de), a
    inc     hl
    inc     de
    djnz    10$

    ; パターンネームの転送
    ld      hl, #_appPatternName
    ld      de, #APP_PATTERN_NAME_TABLE
    ld      bc, #0x0300
    call    LDIRVM

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; ビデオレジスタの転送
    ld      hl, #_request
    set     #REQUEST_VIDEO_REGISTER, (hl)

    ; サウンドの停止
    call    _SystemStopSound
    
    ; 状態の設定
    ld      a, #TITLE_STATE_NULL
    ld      (titleState), a
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存

    ; 0x00: 初期化処理
    ld      a, (titleState)
    cp      #(TITLE_STATE_NULL + 0x00)
    jr      nz, 09$

    ; フレームの設定
    xor     a
    ld      (titleFrame), a

    ; サウンドの再生
    ld      hl, #titleSoundClear
    ld      (_soundRequest + 0x0000), hl
    ld      (_soundRequest + 0x0002), hl
    ld      (_soundRequest + 0x0004), hl

    ; 初期化の完了
    ld      hl, #titleState
    inc     (hl)
09$:

    ; 0x01: 待機処理
    ld      a, (titleState)
    cp      #(TITLE_STATE_NULL + 0x01)
    jr      nz, 19$

    ; フレームの更新
    ld      hl, #titleFrame
    inc     (hl)

    ; キー入力の監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; サウンドの再生
    ld      hl, #titleSoundStart
    ld      (_soundRequest + 0x0000), hl

    ; 待機の完了
    ld      hl, #titleState
    inc     (hl)
19$:

    ; 0x02: 点滅処理
    ld      a, (titleState)
    cp      #(TITLE_STATE_NULL + 0x02)
    jr      nz, 29$

    ; フレームの更新
    ld      hl, #titleFrame
    ld      a, (hl)
    add     a, #0x04
    ld      (hl), a

    ; サウンドの監視
    ld      hl, (_soundRequest + 0x0000)
    ld      a, h
    or      l
    jr      nz, 29$
    ld      hl, (_soundPlay + 0x0000)
    ld      a, h
    or      l
    jr      nz, 29$

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_appState), a
29$:    

    ; 乱数の更新
    call    _SystemGetRandom
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; スプライトの表示
    ld      hl, #titleSprite
    ld      de, #(_sprite + TITLE_SPRITE_LOGO)
    ld      bc, #0x40
    ldir

    ; パターンネームの設定
    ld      a, (titleFrame)
    and     #0x10
    ld      e, a
    ld      d, #0x00
    ld      hl, #titlePatternNamePress
    add     hl, de
    ld      de, #(_appPatternName + 0x0228)
    ld      bc, #0x0010
    ldir

    ; パターンネームの転送
    ld      hl, #(_appPatternName + 0x0228)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_4_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0228)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_4_DST), hl
    ld      a, #(0x10)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_4_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)

    ; レジスタの復帰
    
    ; 終了
    ret

; 定数の定義
;

; スプライト
;
titleSprite:

    .db     0x30, 0x60, 0x80, 0x0a, 0x30, 0x70, 0x84, 0x0a, 0x30, 0x80, 0x88, 0x0a, 0x30, 0x90, 0x8c, 0x0a
    .db     0x40, 0x60, 0xa0, 0x0a, 0x40, 0x70, 0xa4, 0x0a, 0x40, 0x80, 0xa8, 0x0a, 0x40, 0x90, 0xac, 0x0a
    .db     0x50, 0x60, 0xc0, 0x0a, 0x50, 0x70, 0xc4, 0x0a, 0x50, 0x80, 0xc8, 0x0a, 0x50, 0x90, 0xcc, 0x0a
    .db     0x60, 0x60, 0xe0, 0x0a, 0x60, 0x70, 0xe4, 0x0a, 0x60, 0x80, 0xe8, 0x0a, 0x60, 0x90, 0xec, 0x0a

; パターンネーム
;
titlePatternNameScore:

    .db     0xe8, 0xe9, 0xea, 0xd0

titlePatternNamePress:

    .db     0xea, 0xeb, 0xfe, 0xec, 0xec, 0xd0, 0xec, 0xea, 0xfa, 0xfc, 0xfe, 0xd0, 0xfb, 0xfa, 0xeb, 0xd0
    .db     0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0

; サウンド
;
titleSoundClear:

    .ascii  "T1V0R9"
    .db     0x00

titleSoundStart:

    .ascii  "T2V15-2"
    .ascii  "L3O4AF5CO5CO4A7R"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
titleState:
    
    .ds     0x01

; フレーム
;
titleFrame:

    .ds     0x01
