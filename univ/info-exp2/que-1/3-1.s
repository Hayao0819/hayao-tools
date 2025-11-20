    LD      ACC,        (180H)  # 65 80
    LD      IX,         1       # 6a 01
MAIN_LOOP:
    ST      IX,         (1C0H)  # 7d c0
    ST      ACC,        (1B0H)  # 75 b0
    LD      ACC,        0       # 62 00
    LD      IX,         0       # 6a 00

MOD_LOOP:                       #
    ADD     ACC,        (1B0H)  # b5 b0
SUB_LOOP:
    SUB     ACC,        (182H)  # a5 82
    BZP     SUB_LOOP            # 32 0e -> 32 8e
    ADD     ACC,        (182H)  # b5 82
    ADD     IX,         1       # ba 01
    CMP     IX,         (180H)  # fd 80
    BN      MOD_LOOP            # 3a 0c -> 3a 8c

    LD      IX,         (1C0H)  # 6d c0
    ADD     IX,         1       # ba 01
    CMP     IX,         (181H)  # fd 81
    BN      MAIN_LOOP           # 3a 04 -> 3a 84
    HLT                         # 0f -> 30 0A

# 入力
# - 180H: 02H = 2
# - 181H: 05H = 5
# - 182H: 5BH = 91
# 出力
# - ACC: 20H  = 32 (2^5 mod 91 = 32)


# 65 80 6a 01 7d c0 75 b0 62 00 6a 00 b5 b0 a5 82 32 8e b5 82 ba 01 fd 80 3a 8c 6d c0 ba 01 fd 81 3a 84 0f