    # ------------------------------
    # データ領域
.data
    .globl  s                           # int s = 0;
s:  .word   0
    .globl  i                           # int i;
i:  .word   0
    # ------------------------------
    # テキスト領域
.text
    .globl  main
main:
    la      $t0,        s               # $t0 = s のアドレス
    sw      $zero,      0($t0)          # (t0)* = 0; s = 0;
    li      $s0,        1               # s0 = 1;
    la      $t0,        i               # $t0 = i のアドレス
    sw      $s0,        0($t0)          # (t0)* = s0; i = 1;
    # ここまでで初期化完了 s = 0, i = 1
sumLoop:
    la      $t0,        i               # while (i <= 100) { # t0 = i のアドレス
    lw      $s0,        0($t0)          # s0 = (t0)*; s0 = i
    li      $t1,        100             # t1 = 100
    sle     $t0,        $s0,        $t1 # $t0 = 1 if $s0 <= 100
    beqz    $t0,        sumExit         # $t0 == 0 ならば sumExit へ
    la      $t0,        s               # t0 = s のアドレス
    lw      $s0,        0($t0)          # s0 = (t0)*; s0 = s
    la      $t0,        i               # t0 = i のアドレス
    lw      $s1,        0($t0)          # s1 = (t0)*; s1 = i
    add     $s0,        $s0,        $s1 # s0 = s0 + s1; s0 = s + i
    la      $t0,        s               # t0 = s のアドレス
    sw      $s0,        0($t0)          # (t0)* = s0; s = s + i
    la      $t0,        i               # i = i + 1
    lw      $s0,        0($t0)          # s0 = (t0)*; s0 = i
    addi    $s0,        $s0,        1   # s0 = s0 + 1; s0 = i + 1
    sw      $s0,        0($t0)          # (t0)* = s0; i = i + 1
    b       sumLoop                     # end of while-loop
sumExit:
    li      $v0,        0
    jr      $ra                         # jump to $ra
    # end