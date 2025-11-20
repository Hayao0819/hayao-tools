    LD      IX,             1
ROUTINE_LOOP:
    ST      IX,             (150H)
    LD      ACC,            (IX+170H)
    ST      ACC,            (180H)
    BA      (080H)
    *       ルーチンから復帰
ROUTINE_RETURN:
    LD      IX,             (150H) # ここのアドレスが0A
    ST      ACC,            (IX+190H)
    SUB     IX,             1
    BZP     ROUTINE_LOOP
    HLT

    # 6a 01 7d 50 67 70 75 80 30 80 6d 50 77 90 aa 01 32 02 0f

# 入力
# - 170:(D) 02H 0FH (データ)
# - 181:(K) 05H (公開鍵)
# - 182:(N) 5BH (共通鍵)
# 出力
# - 190:(EN) 20H 47H (暗号化データ)