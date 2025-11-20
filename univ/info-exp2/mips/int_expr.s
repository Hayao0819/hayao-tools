.data
        .globl  num1            # int num1 = 123;
num1:   .word   123
        .globl  num2            # int num2 = 4;
num2:   .word   4
        .globl  num3            # int num3 = 10;
num3:   .word   10
        .globl  num4            # int num4 = 5;
num4:   .word   5
        .globl  value           # int value;
value:  .word   0

.text
        .globl  main
main:
    la      $t0,    num1        # $t2 = num1
    lw      $t2,    0($t0)
    la      $t0,    num2        # $t1 = num2
    lw      $t1,    0($t0)
    add     $t2,    $t2,    $t1 # $t2 = $t1 + $t2
    la      $t0,    num3
    lw      $t3,    0($t0)      # $t3 = num3
    la      $t0,    num4
    lw      $t1,    0($t0)      # $t1 = num4
    sub     $t3,    $t3,    $t1 # $t3 = $t3 - $t1
    mul     $t2,    $t2,    $t3 # $t2 = $t2 * $t3
    la      $t0,    value
    sw      $t2,    0($t0)      # value = $t2
    li      $v0,    0
    jr      $ra                 # プログラムの終了
    # end
