    # ------------------------------
    # データ領域
.data
        .globl  n1
n1:     .word   0
_s1:    .asciiz "Please input one number.\n"
_s2:    .asciiz "Number = "
_s3:    .asciiz "The number you entered is "
_s4:    .asciiz "\nEnd.\n"
    # ------------------------------
    # テキスト領域
.text
        .globl  main
main:
    li      $v0,    4                           # print_string
    la      $a0,    _s1
    syscall                                     # _s1 の文字列を表示する
    li      $v0,    4                           # print_string
    la      $a0,    _s2
    syscall                                     # _s2 の文字列を表示する
    li      $v0,    5                           # read_int
    syscall                                     # 整数を入力して \$v0 へ入れる
    la      $t0,    n1
    sw      $v0,    0($t0)                      # $ n1 = 入力した数値
    li      $v0,    4                           # print_string
    la      $a0,    _s3
    syscall                                     # _s3 を表示する
    la      $t0,    n1
    lw      $a0,    0($t0)                      # \$a0 に n1 の値を入れる
    li      $v0,    1                           # print_int
    syscall                                     # \$a0 の値を表示する
    li      $v0,    4                           # print_string
    la      $a0,    _s4
    syscall                                     # _s4 を表示する
    li      $v0,    0                           # return 0
    jr      $ra
