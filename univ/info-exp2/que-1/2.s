    LD      ACC,        (180H)  # ACCに「底（基数）」をセット (初期値: A)
    LD      IX,         1       # べき乗のカウンタを1で初期化
MAIN_LOOP:
    ST      IX,         (1C0H)  # 外側ループのカウンタ(IX)をメモリ(1C0H)に退避
    ST      ACC,        (1B0H)  # 現在の計算結果(ACC)をメモリ(1B0H)に退避 (被乗数になる)
    LD      ACC,        0       # 積の計算用にACCを0クリア
    LD      IX,         0       # 積の計算用にIXを0クリア

MOD_LOOP:                       # 【内側ループ開始】 (1B0H) * (180H) % (182H) を計算
    ADD     ACC,        (1B0H)  # ACCに「前回の結果」を足す
SUB_LOOP:
    SUB     ACC,        (182H)  # ACCから「法（Modulus）」を引く
    BZP     SUB_LOOP            # 0以上なら引き算を継続（剰余計算）
    ADD     ACC,        (182H)  # 引きすぎた分を戻して正しい余りにする
    ADD     IX,         1       # 掛け算カウンタを+1
    CMP     IX,         (180H)  # 「底(180H)」回足したかチェック
    BN      MOD_LOOP            # まだなら足し算を継続

    LD      IX,         (1C0H)  # 退避していた外側ループのカウンタを復帰
    ADD     IX,         1       # べき乗カウンタを+1
    CMP     IX,         (181H)  # 「指数(181H)」に達したかチェック
    BN      MAIN_LOOP           # まだなら次の乗算へ (MAIN_LOOPへ)
    HLT                         # 計算終了。ACCに A^B mod N の結果が入る

# 入力
# - 180H: 02H = 2
# - 181H: 05H = 5
# - 182H: 5BH = 91
# 出力
# - ACC: 20H  = 32 (2^5 mod 91 = 32)