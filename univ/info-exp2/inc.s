    # ------------------------------
    # データ領域
.data
    .globl  x                   # int x;
x:  .word   10
    .globl  y                   # int y;
y:  .word   20
    .globl  p                   # int *p;
p:  .word   0
    # ------------------------------
    # テキスト領域
.text
    .globl  main
main:
    la      $t0,    p
    la      $t1,    x
    sw      $t1,    0($t0)      # p = &x p は x のアドレス
    la      $t0,    p
    lw      $t1,    0($t0)      # $t1 = x のアドレス
    lw      $t2,    0($t1)      # $t2 = x の値
    addi    $t2,    $t2,    1   # $t2 = $t2 + 1
    sw      $t2,    0($t1)      # *p = $t2
    la      $t0,    p
    la      $t1,    y
    sw      $t1,    0($t0)      # p = &y;
    lw      $t1,    0($t0)      # $t1 = y のアドレス
    lw      $t2,    0($t1)      # $t2 = y の値
    addi    $t2,    $t2,    -1  # $t2 = $t2 + 1
    sw      $t2,    0($t1)      # *p = $t2
    li      $v0,    0
    jr      $ra
    # end