    # -------------------------入力---
    # データ領域
.data
        .globl  num1
num1:   .word   0
        .globl  num2
num2:   .word   0
        .globl  num3
num3:   .word   0
        .globl  num4
num4:   .word   0
        .globl  value
value:  .word   0
_s1:    .asciiz "num1 = "
_s2:    .asciiz "num2 = "
_s3:    .asciiz "num3 = "
_s4:    .asciiz "num4 = "
_s5:    .asciiz "-num1 + num2 * (num3 - num4) = "

    # ------------------------------
    # テキスト領域
.text
        .globl  main
main:
    #num1
    li      $v0,    4                                   # print_string
    la      $a0,    _s1
    syscall                                             # _s1 の文字列を表示する
    li      $v0,    5                                   # read_int
    syscall                                             # 整数を入力して \$v0 へ入れる
    la      $t0,    num1
    sw      $v0,    0($t0)                              # num1 = v0（入力）
    #num2
    li      $v0,    4                                   # print_string
    la      $a0,    _s2
    syscall                                             # _s2 の文字列を表示する
    li      $v0,    5                                   # read_int
    syscall                                             # 整数を入力して \$v0 へ入れる
    la      $t0,    num2
    sw      $v0,    0($t0)                              # num2 = v0（入力）
    #num3
    li      $v0,    4                                   # print_string
    la      $a0,    _s3
    syscall                                             # _s3 の文字列を表示する
    li      $v0,    5                                   # read_int
    syscall                                             # 整数を入力して \$v0 へ入れる
    la      $t0,    num3
    sw      $v0,    0($t0)                              # num3 = v0（入力）
    #num4
    li      $v0,    4                                   # print_string
    la      $a0,    _s4
    syscall                                             # _s4 の文字列を表示する
    li      $v0,    5                                   # read_int
    syscall                                             # 整数を入力して \$v0 へ入れる
    la      $t0,    num4
    sw      $v0,    0($t0)                              # num4 = v0（入力）
    # ロード
    la      $t0,    num1
    lw      $s1,    0($t0)                              # num1 の値を $s1 にロード
    la      $t0,    num2
    lw      $s2,    0($t0)                              # num2 の値を $s2 にロード
    la      $t0,    num3
    lw      $s3,    0($t0)                              # num3 の値を $s3 にロード
    la      $t0,    num4
    lw      $s4,    0($t0)                              # num4 の値を $s4 にロード


    # 計算
    sub     $t1,    $s3,            $s4                 # $t1 = $s3 - $s4
    mul     $t1,    $t1     $s2                         # $t1 = $t1 * $s2
    sub     $t1,    $t1,            $s1                 # $t1 = $t1 - $s1

    la      $t0,    value                               # $t0 = &value
    sw      $t1,    0($t0)                              # value = $t1
    # 表示
    li      $v0,    4                                   # print_string
    la      $a0,    _s5
    syscall                                             # _s5 を表示する

    la      $t0,    value                               # $t0 = &value
    lw      $a0,    0($t0)                              # \$a0 に value の値を入れる
    li      $v0,    1                                   # print_int
    syscall                                             # \$a0 の値を表示する
    li      $v0,    0
    jr      $ra                                         # プログラムの終了
