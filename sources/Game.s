; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Road.inc"
    .include    "Bus.inc"
    .include    "Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; パターンネームのクリア
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0001)
    ld      bc, #0x02ff
    ld      (hl), #0xd0
    ldir

    ; サウンドの停止
    call    _SystemStopSound
    
    ; 道の初期化
    call    _RoadInitialize

    ; バスの初期化
    call    _BusInitialize

    ; エネミーの初期化
    call    _EnemyInitialize

    ; フレームの初期化
    xor     a
    ld      (gameFrame), a

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
    
    ; スコアの設定
    ld      hl, #gameScoreDefault
    ld      de, #gameScore
    ld      bc, #APP_SCORE_SIZE
    ldir

    ; 状態の設定
    ld      a, #GAME_STATE_START
    ld      (gameState), a
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; 乱数の更新
    call    _SystemGetRandom
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (gameState)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; デバッグの表示
;;  call    GamePrintDebug

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret
    
; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0x60
    ld      (gameFrame), a

    ; 開始画面の表示
    call    GamePrintStart

    ; パターンネームの転送
    call    _AppTransferPatternName

    ; サウンドの再生
    ld      hl, #gameSoundStart_0
    ld      (_soundRequest + 0x0000), hl
    ld      hl, #gameSoundStart_1
    ld      (_soundRequest + 0x0002), hl
    ld      hl, #gameSoundStart_2
    ld      (_soundRequest + 0x0004), hl

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #gameFrame
    dec     (hl)
    jr      nz, 19$

    ; プレイ画面の表示
    call    GamePrintPlay

    ; ステータスの表示
    call    GamePrintStatus

    ; パターンネームの転送
    call    _AppTransferPatternName

    ; 状態の更新
    ld      a, #GAME_STATE_PLAY
    ld      (gameState), a
19$:

    ; レジスタの復帰

    ; 終了
    ret
    
; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; バスの待機
    call    _BusSetStay

    ; エネミーの待機
    call    _EnemySetStay

    ; フレームの設定
    ld      a, #0x30
    ld      (gameFrame), a

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #gameFrame
    ld      a, (hl)
    or      a
    jr      z, 19$
    dec     (hl)
    jr      nz, 19$

    ; バスのプレイ
    call    _BusSetPlay

    ; エネミーの移動
    call    _EnemySetMove

    ; フレームの更新の完了
19$:

    ; 道の更新
    call    _RoadUpdate

    ; バスの更新
    call    _BusUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; カメラの更新
    call    GameUpdateCamera

    ; スコアの更新
    ld      a, (gameFrame)
    or      a
    call    z, GameUpdateScore

    ; 道の描画
    call    _RoadRender

    ; バスの描画
    call    _BusRender

    ;  エネミーの描画
    call    _EnemyRender

    ; ステータスの表示
    call    GamePrintStatus

    ; 判定の開始

    ; クリアの判定
    call    _RoadIsPass
    jr      nc, 30$
    ld      a, #GAME_STATE_CLEAR
    ld      (gameState), a
    jr      39$
30$:

    ; ヒットの判定
    call    GameIsHit
    ld      a, h
    or      l
    jr      z, 31$
    call   _BusSetMiss
    ld      a, #GAME_STATE_MISS
    ld      (gameState), a
    jr      39$
31$:

    ; 時間切れの判定
    call    GameIsTimeUp
    jr      nc, 32$
    ld      a, #GAME_STATE_OVER
    ld      (gameState), a
    jr      39$
32$:

    ; 判定の完了
39$:
    
    ; サウンドの監視
    ld      hl, (_soundPlay + 0x0000)
    ld      a, h
    or      l
    jr      nz, 49$
    ld      hl, #gameSoundPlay_0
    ld      (_soundRequest + 0x0000), hl
    ld      hl, #gameSoundPlay_1
    ld      (_soundRequest + 0x0002), hl
    ld      hl, #gameSoundPlay_2
    ld      (_soundRequest + 0x0004), hl
49$:

    ; レジスタの復帰

    ; 終了
    ret
    
; ゲームでミスする
;
GameMiss:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; エネミーの待機
    call    _EnemySetStay

    ; フレームの設定
    ld      a, #0x60
    ld      (gameFrame), a

    ; サウンドの再生
    ld      hl, #gameSoundMiss_0
    ld      (_soundRequest + 0x0000), hl
    ld      hl, #gameSoundMiss_1
    ld      (_soundRequest + 0x0002), hl
    ld      hl, #gameSoundMiss_2
    ld      (_soundRequest + 0x0004), hl

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; 道の更新
    call    _RoadUpdate

    ; バスの更新
    call    _BusUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; カメラの更新
    call    GameUpdateCamera

    ; 道の描画
    call    _RoadRender

    ; バスの描画
    call    _BusRender

    ;  エネミーの描画
    call    _EnemyRender

    ; ステータスの表示
    call    GamePrintStatus

    ; フレームの更新
    ld      hl, #gameFrame
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_OVER
    ld      (gameState), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0xa0
    ld      (gameFrame), a

    ; ゲームオーバー画面の表示
    call    GamePrintOver

    ; パターンネームの転送
    call    _AppTransferPatternName

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #gameFrame
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
19$:

    ; スプライトの表示
    ld      hl, #gameSpriteOver
    ld      de, #(_sprite + GAME_SPRITE_FACE)
    ld      bc, #0x30
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをクリアする
;
GameClear:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; バスの待機
    call    _BusSetStay

    ; エネミーの待機
    call    _EnemySetStay

    ; フレームの設定
    ld      a, #0x30
    ld      (gameFrame), a

    ; サウンドの再生
    ld      hl, #gameSoundClear_0
    ld      (_soundRequest + 0x0000), hl
    ld      hl, #gameSoundClear_1
    ld      (_soundRequest + 0x0002), hl
    ld      hl, #gameSoundClear_2
    ld      (_soundRequest + 0x0004), hl

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; 道の更新
    call    _RoadUpdate

    ; バスの更新
    call    _BusUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; カメラの更新
    call    GameUpdateCamera

    ; 道の描画
    call    _RoadRender

    ; バスの描画
    call    _BusRender

    ;  エネミーの描画
    call    _EnemyRender

    ; ステータスの表示
    call    GamePrintStatus

    ; フレームの更新
    ld      hl, #gameFrame
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_END
    ld      (gameState), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを終了する
;
GameEnd:

    ; レジスタの保存

    ; 初期化処理
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; ハイスコアの更新
    ld      hl, #gameScore
    ld      de, #_appScore
    ld      b, #APP_SCORE_SIZE
00$:
    ld      a, (de)
    cp      (hl)
    jr      c, 01$
    jr      nz, 02$
    inc     hl
    inc     de
    djnz    00$
    jr      02$
01$:
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    djnz    01$
02$:

    ; フレームの設定
    ld      a, #0xa0
    ld      (gameFrame), a

    ; ゲーム終了画面の表示
    call    GamePrintEnd

    ; パターンネームの転送
    call    _AppTransferPatternName

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #gameFrame
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
19$:

    ; スプライトの表示
    ld      hl, #gameSpriteEnd
    ld      de, #(_sprite + GAME_SPRITE_FACE)
    ld      bc, #0x30
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; ヒット判定を行う
;
GameIsHit:

    ; レジスタの保存

    ; バスの車体（前）との判定
    call    _BusGetFrontPosition
    ld      de, (_gameCamera)
    or      a
    sbc     hl, de
    ld      h, l
    ld      l, a
    call    _EnemyIsHit
    jr      c, 19$

    ; バスの車体（後ろ）との判定
    call    _BusGetBackPosition
    ld      de, (_gameCamera)
    or      a
    sbc     hl, de
    ld      h, l
    ld      l, a
    call    _EnemyIsHit
    jr      c, 19$
    ld      hl, #0x0000

    ; 判定の完了
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 時間切れの判定を行う
;
GameIsTimeUp:

    ; レジスタの保存

    ; スコア = タイム
    ld      hl, #gameScore
    xor     a
    ld      b, #APP_SCORE_SIZE
10$:
    add     a, (hl)
    inc     hl
    djnz    10$
    or      a
    jr      nz, 19$
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

; カメラを更新する
;
GameUpdateCamera:

    ; レジスタの保存

    ; バスの位置の取得
    call    _BusGetFrontPosition

    ; バスの位置を中心にカメラの位置を設定
    ld      de, #-0x0080
    add     hl, de
    ld      a, h
    and     #0x03
    ld      h, a
    ld      (_gameCamera), hl

    ; レジスタの復帰

    ; 終了
    ret
    
; スコアを更新する
;
GameUpdateScore:

    ; レジスタの保存

    ; スコアの減少
    ld      hl, #gameScore
    xor     a
    ld      b, #APP_SCORE_SIZE
10$:
    or      (hl)
    inc     hl
    djnz    10$
    or      a
    jr      z, 19$
11$:
    dec     hl
    ld      a, (hl)
    or      a
    jr      nz, 12$
    ld      a, #0x09
    ld      (hl), a
    jr      11$
12$:
    dec     (hl)
19$:

    ; レジスタの復帰

    ; 終了
    ret
    
; ステータスを表示する
;
GamePrintStatus:

    ; レジスタの保存

    ; スコアの表示
    ld      hl, #gameScore
    ld      de, #(_appPatternName + 0x0002)
    ld      b, #APP_SCORE_SIZE
10$:
    ld      a, (hl)
    add     a, #0xc0
    ld      (de), a
    inc     hl
    inc     de
    djnz    10$

    ; ハイスコアの表示
    ld      hl, #_appScore
    ld      de, #(_appPatternName + 0x0010)
    ld      b, #APP_SCORE_SIZE
20$:
    ld      a, (hl)
    add     a, #0xc0
    ld      (de), a
    inc     hl
    inc     de
    djnz    20$

    ; 距離の表示
    ld      hl, #_roadDistancePass
    ld      de, #(_appPatternName + 0x0019)
    ld      b, #ROAD_DISTANCE_SIZE
30$:
    ld      a, (hl)
    add     a, #0xc0
    ld      (de), a
    inc     hl
    inc     de
    djnz    30$
    ld      hl, #_roadDistanceTotal
    inc     de
    ld      b, #ROAD_DISTANCE_SIZE
31$:
    ld      a, (hl)
    add     a, #0xc0
    ld      (de), a
    inc     hl
    inc     de
    djnz    31$

    ; パターンネームの転送
    ld      hl, #(_appPatternName + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_4_SRC), hl
    ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0000)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_4_DST), hl
    ld      a, #(0x40)
    ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_4_BYTES), a
    ld      hl, #(_request)
    set     #REQUEST_VRAM, (hl)

    ; レジスタの復帰

    ; 終了
    ret

; 開始画面を表示する
;
GamePrintStart:

    ; レジスタの保存

    ; パターンネームの設定
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0001)
    ld      bc, #0x02ff
    ld      (hl), #0xd0
    ldir
    ld      hl, #(gamePatternNameStart + 0x0000)
    ld      de, #(_appPatternName + 0x014a)
    ld      bc, #0x000c
    ldir
    ld      hl, #(gamePatternNameStart + 0x000c)
    ld      de, #(_appPatternName + 0x016a)
    ld      bc, #0x000c
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; プレイ画面を表示する
;
GamePrintPlay:

    ; レジスタの保存

    ; パターンネームの設定
    ld      hl, #gamePatternNamePlay
    ld      de, #_appPatternName
    ld      bc, #0x0300
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバー画面を表示する
;
GamePrintOver:

    ; レジスタの保存

    ; パターンネームの設定
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0001)
    ld      bc, #0x02ff
    ld      (hl), #0xd0
    ldir
    ld      hl, #(gamePatternNameOver + 0x0000)
    ld      de, #(_appPatternName + 0x018b)
    ld      bc, #0x000a
    ldir
    ld      hl, #(gamePatternNameOver + 0x000a)
    ld      de, #(_appPatternName + 0x01ab)
    ld      bc, #0x000a
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; ゲーム終了画面を表示する
;
GamePrintEnd:

    ; レジスタの保存

    ; パターンネームの設定
    ld      hl, #(_appPatternName + 0x0000)
    ld      de, #(_appPatternName + 0x0001)
    ld      bc, #0x02ff
    ld      (hl), #0xd0
    ldir
    ld      de, #(_appPatternName + 0x020d)
    ld      a, #0xe5
    ld      (de), a
    inc     de
    inc     de
    ld      hl, #gameScore
    ld      b, #APP_SCORE_SIZE
10$:
    ld      a, (hl)
    add     a, #0xf0
    ld      (de), a
    inc     hl
    inc     de
    djnz    10$
    ld      hl, #_appScore
    ld      de, #gameScore
    ld      b, #APP_SCORE_SIZE
11$:
    ld      a, (de)
    cp      (hl)
    jr      nz, 12$
    inc     hl
    inc     de
    djnz    11$
    ld      hl, #(gamePatternNameEnd + 0x0008)
    ld      de, #(_appPatternName + 0x018e)
    ld      bc, #0x0004
    ldir
    ld      hl, #(gamePatternNameEnd + 0x000c)
    ld      de, #(_appPatternName + 0x01ae)
    ld      bc, #0x0004
    ldir
    jr      19$
12$:
    ld      hl, #(gamePatternNameEnd + 0x0000)
    ld      de, #(_appPatternName + 0x018e)
    ld      bc, #0x0004
    ldir
    ld      hl, #(gamePatternNameEnd + 0x0004)
    ld      de, #(_appPatternName + 0x01ae)
    ld      bc, #0x0004
    ldir
19$:

    ; レジスタの復帰

    ; 終了
    ret

; デバッグを表示する
;
GamePrintDebug:

    ; レジスタの保存

    ; SP の設定
    ld      hl, #0x0000
    add     hl, sp
    ld      de, #(_gameDebug + 0x000e)
    ex      de, hl
    ld      (hl), d
    inc     hl
    ld      (hl), e
;   inc     hl

    ; デバッグの表示
    ld      hl, #_gameDebug
    ld      de, #_appPatternName
    ld      b, #(0x10 + 0x03)
10$:
    ld      a, (hl)
    rrca
    rrca
    rrca
    rrca
    and     #0x0f
    add     a, #0xf0
    ld      (de), a
    inc     de
    ld      a, (hl)
    and     #0x0f
    add     a, #0xf0
    ld      (de), a
    inc     de
    inc     hl
    djnz    10$

;   ; パターンネームの転送
;   ld      hl, #(_appPatternName + 0x0000)
;   ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_4_SRC), hl
;   ld      hl, #(APP_PATTERN_NAME_TABLE + 0x0000)
;   ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_4_DST), hl
;   ld      a, #(0x20 + 0x06)
;   ld      (_videoTransfer + VIDEO_TRANSFER_VRAM_4_BYTES), a
;   ld      hl, #(_request)
;   set     #REQUEST_VRAM, (hl)

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameStart
    .dw     GamePlay
    .dw     GameMiss
    .dw     GameOver
    .dw     GameClear
    .dw     GameEnd

; スコア
;
gameScoreDefault:

    .db     0x05, 0x00, 0x00, 0x00

; スプライト
;
gameSpriteOver:

    .db     0x28, 0x60, 0xd0, 0x05, 0x28, 0x70, 0xd4, 0x05, 0x28, 0x80, 0xd8, 0x05, 0x28, 0x90, 0xdc, 0x05
    .db     0x38, 0x60, 0xf0, 0x05, 0x38, 0x70, 0xf4, 0x05, 0x38, 0x80, 0xf8, 0x05, 0x38, 0x90, 0xfc, 0x05
    .db     0x48, 0x60, 0x60, 0x05, 0x48, 0x70, 0x64, 0x05, 0x48, 0x80, 0x68, 0x05, 0x48, 0x90, 0x6c, 0x05

gameSpriteEnd:

    .db     0x28, 0x60, 0x70, 0x0b, 0x28, 0x70, 0x74, 0x0b, 0x28, 0x80, 0x78, 0x0b, 0x28, 0x90, 0x7c, 0x0b
    .db     0x38, 0x60, 0x90, 0x0b, 0x38, 0x70, 0x94, 0x0b, 0x38, 0x80, 0x98, 0x0b, 0x38, 0x90, 0x9c, 0x0b
    .db     0x48, 0x60, 0xb0, 0x0b, 0x48, 0x70, 0xb4, 0x0b, 0x48, 0x80, 0xb8, 0x0b, 0x48, 0x90, 0xbc, 0x0b

; パターンネーム
;
gamePatternNameStart:

    .db     0xd0, 0xd0, 0xd0, 0xd0, 0xe6, 0xd0, 0xe7, 0xd0, 0xe7, 0xd0, 0xd0, 0xd0
    .db     0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd7, 0xd9, 0xda, 0xdb

gamePatternNamePlay:

    .db     0xca, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0xcd, 0xce, 0xcf, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0xcb, 0x18, 0x18, 0x18, 0x18, 0xcc, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x98, 0x99, 0x9a, 0x99, 0x9b, 0x18, 0x18, 0x18
    .db     0x18, 0x98, 0x99, 0x9a, 0x99, 0x9b, 0x18, 0x18, 0x18, 0x18, 0x98, 0x18, 0x18, 0x98, 0x99, 0x9a
    .db     0x9b, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x9c, 0x9d, 0x9e, 0x9d, 0x9f, 0x18, 0x18
    .db     0x18, 0x9c, 0x9d, 0x9e, 0x9d, 0x9f, 0x18, 0x98, 0x9b, 0x18, 0x9c, 0x9f, 0x18, 0x9c, 0x9d, 0x9e
    .db     0x9f, 0x18, 0x18, 0x18, 0x98, 0x9b, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x9c, 0x9e, 0x9f, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x9c, 0x9f, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18
    .db     0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x19, 0x1a
    .db     0x1c, 0x19, 0x1a, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x19, 0x1a, 0x19
    .db     0x1a, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x19, 0x1a, 0x1b, 0x58, 0x59
    .db     0x59, 0x5b, 0x58, 0x1c, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x18, 0x39, 0x3a, 0x1b, 0x58, 0x5a, 0x58
    .db     0x59, 0x1c, 0x39, 0x3a, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x18, 0x1b, 0x58, 0x5a, 0x58, 0x58, 0x59
    .db     0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78
    .db     0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78
    .db     0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79
    .db     0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79
;   .db     0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a
;   .db     0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a, 0x7a
;   .db     0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b
;   .db     0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b, 0x7b
;   .db     0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c
;   .db     0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c, 0x7c
;   .db     0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d
;   .db     0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d, 0x7d
    .db     0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79
    .db     0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79
    .db     0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79
    .db     0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79
    .db     0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79
    .db     0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79
    .db     0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79
    .db     0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79, 0x79
    .db     0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e
    .db     0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e, 0x7e
    .db     0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f
    .db     0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f

gamePatternNameOver:

    .db     0xd0, 0xe6, 0xd0, 0xd0, 0xe6, 0xd0, 0xe6, 0xd0, 0xd0, 0xd0
    .db     0xdc, 0xdb, 0xe1, 0xe0, 0xe2, 0xe3, 0xdc, 0xe4, 0xd9, 0xe0

gamePatternNameEnd:

    .db     0xd0, 0xd0, 0xd0, 0xd0
    .db     0xdc, 0xdd, 0xde, 0xd9
    .db     0xd0, 0xe6, 0xd0, 0xd0
    .db     0xdf, 0xd3, 0xd9, 0xe0

; サウンド
;
gameSoundStart_0:

    .ascii  "T1V15-2"
    .ascii  "L3O5FEFG5FGA5B-BO6C5O5AGFL5FO6DCO5FDB-AG"
    .db     0x00

gameSoundStart_1:

    .ascii  "T1V15-2"
    .ascii  "L3O4FRRERRRDRDD-C5RF5O3B-B-O4B-O4B-ARARO3GAB-O4C5DD+E"
    .db     0x00

gameSoundStart_2:

    .ascii  "T1V15-2"
    .ascii  "L3O3FRRERRRDRDD-C5CF5O2B-RO4FO2B-AARAO2GAB-O3C5DD+E"
    .db     0x00

gameSoundPlay_0:

    .ascii  "T1V15-2"
    .ascii  "L9FR"
    .ascii  "L0R9O3FGABO4C+D+FGABO5C+D+FGABO6C5R5"
    .ascii  "L3O4CFA-FA-4F1RA-5B-B-A-B-4B4B-A-FE-F6R5R9"
    .ascii  "L3O4CFA-FA-4F1RA-5B-B-A-B-4B4B-A-FE-F6R5O3B-5B5O4C7"
    .ascii  "L3O4AAAAAO5DO4A5A-A-GGFFG5GGGGO5C5O4GG"
    .ascii  "L3O4RF+RGRARB-7DD5R5A6CC5RCD-5E-F5O5C5O4A5B-AAG7L5RO5GCO6C"
    .ascii  "L3O5FEFG5FGA5B-BO6C5O5AGFL5FO6DCO5FB-3A3G3F3GR"
    .ascii  "L3O5FEFG5FGA5B-BO6C5O5AGFL5FO6DCO5FDB-AG"
    .ascii  "L3O5F7RFFGA-5G5F5D5C4A4AA4G+4AB-6O6C1O5B-1A5RA"
    .ascii  "L3O5B-5AF5D5F8R5AB-5AF5D5DC5R5G7"
    .db     0xff

gameSoundPlay_1:

    .ascii  "T1V15-2"
    .ascii  "L1O3F3FO4FO3E3EO4EO3E-3E-O4E-O3D3DO4DO3D-3D-O4D-O3C3CO4CO2B3BO3BO3C3CO4C"
    .ascii  "L1O3F3FO4FO3E3EO4EO3E-3E-O4E-O3D3DO4DO3D-3D-O4D-O3C3CO4CO2B3BO3BO3C3CO4C"
    .ascii  "L3O4FRR5E-RRD-5RR5C7L1O3F3FO4FO3E3EO4EO3E-3E-O4E-O3D3DO4DO3D-3D-O4D-O3C3CO4CO2B3BO3BO3C3CO4C"
    .ascii  "L3O4F6RE-RE-D-5RD-RC7L1O3F3FO4FO3E3EO4EO3E-3E-O4E-O3D3DO4DL5O3FF+AR"
    .ascii  "L3O3B6BO4A6RO3B-6B-O4A-6RO3A6AO4G5O3AO4E-"
    .ascii  "L3O4RE-RE-RDRO3G5GO4GO3G5RGRAAO4AO3A5RARB-RB-B-5RB-O4C5CO3B-BO4CO3AB-BO4CRR5R7"
    .ascii  "L3O4FRAE5RED5DD-C5FO3FO4FO3B-B-O4B-O3B-ARARGAB-O4C5DE-E"
    .ascii  "L3O4FRAE5RED5DD-C5FO3FO4FO3B-B-O4B-O3B-ARARGAB-O4C5RCR"
    .ascii  "L3O4D-6D-O5D-6O4D-1O3D-1O4D-6O5D-5O3D-O4D-O3D-O4F6FO5F6O4F1O3F1O4F6O5F5O3FO4FO3F"
    .ascii  "L3O3GGO4GO3G5RGRGRGG5RGRO4CRCC5RCRC5R5R7"
    .db     0xff

gameSoundPlay_2:

    .ascii  "T1V15-2"
    .ascii  "L9RR"
    .ascii  "L9RR"
    .ascii  "L3O3FRR5E-RRD-5RR5C7R9O4A-FE-F6R5"
    .ascii  "L3O3F6FE-E-RD-5D-RD-C4C4CR9L5O2B-BO3CR"
    .ascii  "L3O2B6RO4F6RO2B6RO4F6RO2A6RO4E5RO3E-"
    .ascii  "L3O3RE-RE-RDRO2G5RO4DO2G5GRGARO4FO2A5ARAB-B-RB-5B-RO3C5CO2B-BO3CO2AB-BO3CRR5R7"
    .ascii  "L3O3FFRE5ERD5DD-C5RFRO2B-RO4FO2B-AARAGAB-O3C5DE-E"
    .ascii  "L3O3FFRE5ERD5DD-C5RFRO2B-RO4FO2B-AARAGAB-O3C5CRC"
    .ascii  "L3O3D-6RO4A-6RR6A-5R6O3F6RO5C6RR6C5R6"
    .ascii  "O2GRO4DO2G5GRGGGRG5GRGO3CCRC5CRCC5R5R7"
    .db     0xff

gameSoundMiss_0:

    .ascii  "T1V15-2"
    .ascii  "L5O5D+3C+3O4F+O5F+F+D+3C+3O4F+O5F+F+"
    .ascii  "L5D+3C+3O4F+O5F+O4D+O5F+O4C+O5E+E+R"
    .db     0x00
    
gameSoundMiss_1:

    .ascii  "T1V15-2"
    .ascii  "L5O4RRA+A+RRA+A+"
    .ascii  "L5O4RA+RA+RBBR"
    .db     0x00
    
gameSoundMiss_2:

    .ascii  "T1V15-2"
    .ascii  "L9O4R5RR"
    .ascii  "L9O4RR"
    .db     0x00
    
gameSoundClear_0:

    .ascii  "T1V15-2"
    .ascii  "L3O4B-RO4FRERFG5FGRF5R5"
    .db     0x00

gameSoundClear_1:

    .ascii  "T1V15-2"
    .ascii  "L3O3GRR5O4CRRO3F5FO4FRO3F5R5"
    .db     0x00

gameSoundClear_2:

    .ascii  "T1V15-2"
    .ascii  "L2O3GRR5O3CRRO2F5RO4CRO2F5R5"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
gameState:
    
    .ds     0x01

; フレーム
;
gameFrame:

    .ds     0x01

; カメラ
;
_gameCamera::

    .ds     0x02

; スコア
;
gameScore:

    .ds     APP_SCORE_SIZE

; デバッグ
;
_gameDebug::

    .ds     0x10 + 0x04
