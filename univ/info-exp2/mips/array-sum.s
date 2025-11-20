    # ------------------------------
    # データ領域
.data
        .globl  sum
sum:    .word   0
        .globl  i
i:      .word   0
        .globl  a
a:      .word   9, 5, 1, 7, 10
        .word   12, 2
    # ------------------------------
    # テキスト領域
.text
        .globl  main
main:
    la      $t0,        i               # i = 0
    sw      $zero,      0($t0)
    la      $t0,        sum             # sum = 0
    sw      $zero,      0($t0)
L_while:
    la      $t0,        i
    lw      $s0,        0($t0)          # $s0 = i
    li      $s1,        7               # $s1 = 7
    slt     $t0,        $s0,        $s1 # if !(i < 7)
    beqz    $t0,        L_endwhile
    # sum = sum + a[i]
    la      $t0,        sum
    lw      $t7,        0($t0)          # t7 = sum
    la      $t0,        i
    lw      $t1,        0($t0)          # $t1 = i
    li      $t2,        4
    mul     $t1,        $t1,        4   # $t1 = 4 * i
    la      $t0,        a
    addu    $t0,        $t0,        $t1 # $t0 = a[i] のアドレス
    lw      $t6,        0($t0)          # $t6 = a[i]
    add     $t7,        $t7,        $t6 # $t7 = sum + a[i]
    la      $t0,        sum
    sw      $t7,        0($t0)          # sum = sum + a[i]
    # i = i + 1
    la      $t0,        i
    lw      $s0,        0($t0)          # $s0 = i
    addi    $s0,        $s0,        1   # $s0 = $s0 + 1
    sw      $s0,        0($t0)
    b       L_while
L_endwhile:
    li      $v0,        0
    jr      $ra
    # end