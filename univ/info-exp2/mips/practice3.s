    # ------------------------------
    # データ領域
.data
prompt_a:   .asciiz "a = "
prompt_b:   .asciiz "b = "
newline:    .asciiz "\n"

    # グローバル変数の領域確保
var_a:      .word   0
var_b:      .word   0
var_x:      .word   0
var_f:      .word   0

    # ------------------------------
    # テキスト領域
.text
            .globl  main

    # --- 関数 linear の記述
linear:
    # 関数 linear のプロローグ
    # 8($sp) : 被呼び出し保存 $fp
    # 4($sp) : 局所変数 v1
    # 0($sp) : 局所変数 f
    # 引数は $a0=a, $a1=b, $a2=x
    addiu   $sp,    $sp,        -24
    sw      $fp,    8($sp)
    move    $fp,    $sp

    # v1 = a * x
    mul     $t0,    $a0,        $a2         # t0 = a * x
    sw      $t0,    4($fp)                  # v1 に保存

    # f = v1 + b
    lw      $t0,    4($fp)                  # v1 ロード
    add     $t1,    $t0,        $a1         # t1 = v1 + b
    sw      $t1,    0($fp)                  # f に保存

    # 関数 linear のエピローグ
    lw      $v0,    0($fp)                  # 返り値 f を $v0 にセット
    move    $sp,    $fp
    lw      $fp,    8($sp)
    addiu   $sp,    $sp,        12
    jr      $ra
    # --- 関数 linear の記述終了

    # --- 関数 main の記述
main:
    # main 関数のプロローグ
    # 20($sp) : 被呼び出し保存 $ra
    # 16($sp) : 被呼び出し保存 $fp
    addiu   $sp,    $sp,        -24
    sw      $ra,    20($sp)
    sw      $fp,    16($sp)
    move    $fp,    $sp

    # print_string("a = ")
    la      $a0,    prompt_a
    li      $v0,    4
    syscall

    # a = read_int()
    li      $v0,    5
    syscall
    sw      $v0,    var_a                   # グローバル変数 a に保存

    # print_string("b = ")
    la      $a0,    prompt_b
    li      $v0,    4
    syscall

    # b = read_int()
    li      $v0,    5
    syscall
    sw      $v0,    var_b                   # グローバル変数 b に保存

    # for (x = 0; x < 10; x++)
    sw      $zero,  var_x                   # x = 0

_loop:
    lw      $t0,    var_x
    li      $t1,    10
    slt     $t2,    $t0,        $t1         # x < 10 ?
    beq     $t2,    $zero,      _end_loop   # false ならループ終了

    # linear(a, b, x) の呼び出し準備
    lw      $a0,    var_a
    lw      $a1,    var_b
    lw      $a2,    var_x
    jal     linear
    sw      $v0,    var_f                   # f = linear(...)

    # print_int(f)
    move    $a0,    $v0
    li      $v0,    1
    syscall

    # print_string("\n")
    la      $a0,    newline
    li      $v0,    4
    syscall

    # x++
    lw      $t0,    var_x
    addi    $t0,    $t0,        1
    sw      $t0,    var_x
    j       _loop

_end_loop:
    # 関数 main のエピローグ
    li      $v0,    0                       # return 0
    move    $sp,    $fp
    lw      $ra,    20($sp)
    lw      $fp,    16($sp)
    addiu   $sp,    $sp,        24
    jr      $ra
    # --- 関数 main の記述終了
