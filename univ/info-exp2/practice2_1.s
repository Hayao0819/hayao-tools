.data
prompt: .asciiz "Enter an integer: "
nl:     .asciiz "\n"

.text
        .globl  main
main:
    # プロンプトを表示
    li      $v0,    4
    la      $a0,    prompt
    syscall

    # 整数入力
    li      $v0,    5
    syscall
    move    $t0,    $v0                         # $t0 = 入力値

    # 1の位と10の位を取得
    li      $t1,    10
    div     $t0,    $t1
    mflo    $t2                                 # $t2 = 商 (10の位)
    mfhi    $t3                                 # $t3 = 余り (1の位)

    # ここまでのレジスタの値
    # $t0: 入力値
    # $t1: --
    # $t2: 商 (10の位)
    # $t3: 余り (1の位)

    # 四捨五入処理開始
    # 0未満かどうかを判定し、ジャンプ
    bltz    $t0,    NEGATIVE

POSITIVE:
    # 正の数: 余り >= 5 → 繰り上げ
    li      $t4,    5                           # $t4 = 5
    blt     $t3,    $t4,        NO_ROUND_UP     # 余り < 5 なら繰り上げ不要
    addi    $t2,    $t2,        1               # 繰り上げ

NO_ROUND_UP:
    mul     $t5,    $t2,        10              # 戻す (×10)
    move    $a0,    $t5
    j       PRINT
    nop

NEGATIVE:
    # 負の数: 余り <= -5 → 繰り下げ
    # 負数の余りはMIPSでは符号付きになるため補正が必要
    # 例: -126 ÷ 10 → 商=-12, 余り=-6
    li      $t4,    -5
    bgt     $t3,    $t4,        NO_ROUND_DOWN
    addi    $t2,    $t2,        -1              # 繰り下げ

NO_ROUND_DOWN:
    mul     $t5,    $t2,        10
    move    $a0,    $t5
    j       PRINT
    nop

PRINT:
    # ここまでで$a0に結果が入っている
    # 結果を表示
    li      $v0,    1
    syscall

    # 改行
    li      $v0,    4
    la      $a0,    nl
    syscall

    # 終了
    li      $v0,    10
    syscall
