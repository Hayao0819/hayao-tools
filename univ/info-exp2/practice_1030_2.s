.data
array:      .word   5, 12, 8, 10, 15
            .word   3, 9, 20, 7, 11
            .word   1, 13, 2, 25, 6
            .word   4                   # int[16]
msg:        .asciiz "Count = "
newline:    .asciiz "\n"

.text
            .globl  main


    # レジスタ用途一覧
    # $t0 : 配列の現在の要素のアドレス
    # $t1 : 要素数(16)
    # $t2 : インデックス(i)
    # $t3 : カウント用（10以下の要素数）
    # $t4 : 比較対象(10)
    # $t5 : 配列の現在の要素の値

main:
    la      $t0,    array               # $t0 = 配列の先頭アドレス
    li      $t1,    16                  # $t1 = 要素数
    li      $t2,    0                   # $t2 = インデックス
    li      $t3,    0                   # $t3 = カウント用（10以下の要素数）
    li      $t4,    10                  # $t4 = 比較対象(10)

loop:
    beq     $t2,    $t1,        done    # i == 16 ならループ終了
    lw      $t5,    0($t0)              # 配列の現在の要素をロード
    blt     $t5,    $t4,        inc     # 要素 <= 10 ならカウント増加
    j       next

inc:
    addi    $t3,    $t3,        1       # count++

next:
    addi    $t0,    $t0,        4       # 次の要素へ（4バイト進む）
    addi    $t2,    $t2,        1       # i++
    j       loop

done:
    # "Count = " を表示
    la      $a0,    msg
    li      $v0,    4
    syscall

    # countを表示
    move    $a0,    $t3
    li      $v0,    1
    syscall

    # 改行
    la      $a0,    newline
    li      $v0,    4
    syscall

    # 終了
    li      $v0,    10
    syscall
