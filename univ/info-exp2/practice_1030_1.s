.data
prompt:     .asciiz "Please input an integer: "
result_msg: .asciiz "Result = "
newline:    .asciiz "\n"

n:          .word   0
lg:         .word   0
i:          .word   0

.text
            .globl  main

    # レジスタ用途一覧
    # $t0 : lg のアドレス / lg の値
    # $t1 : n の値
    # $t2 : i の値
    # $t3 : 定数 1
    # $t4 : 定数 2


main:
    # print_string("Please input an integer: ");
    la      $a0,        prompt
    li      $v0,        4
    syscall

    # n = read_int();
    li      $v0,        5
    syscall
    sw      $v0,        n

    # lg = 0;
    li      $t0,        0
    sw      $t0,        lg

    # i = n;
    lw      $t1,        n                       # $t1 = n
    move    $t2,        $t1                     # i のレジスタコピー
    sw      $t2,        i                       # t2 を i にストア

for_loop:
    # if (i <= 1) break;
    lw      $t2,        i                       # $t2 = i
    li      $t3,        1                       # $t3 = 1
    ble     $t2,        $t3,        end_loop    # if i <= 1 then goto end_loop

    # lg = lg + 1;
    lw      $t0,        lg                      # $t0 = lg
    addi    $t0,        $t0,        1           # $t0 = $t0 + 1
    sw      $t0,        lg                      # lg を更新

    # i = i / 2;
    lw      $t2,        i                       # $t2 = i
    li      $t4,        2                       # $t4 = 2
    div     $t2,        $t4                     # $t2 / $t4 (i / 2)
    mflo    $t5                                 # $t5 に商を取得
    move    $t2,        $t5                     # i のレジスタコピー
    sw      $t2,        i                       # i を更新

    j       for_loop                            # ループの先頭へ戻る

end_loop:
    # print_string("Result = ");
    la      $a0,        result_msg
    li      $v0,        4
    syscall

    # print_int(lg);
    lw      $a0,        lg
    li      $v0,        1
    syscall

    # print_string("\n");
    la      $a0,        newline
    li      $v0,        4
    syscall

    # return 0;
    li      $v0,        10
    syscall
