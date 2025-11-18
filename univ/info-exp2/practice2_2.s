.data
prompt: .asciiz "Enter an integer: "
nl:     .asciiz "\n"

.text
        .globl  main
main:
    # プロンプトを表示
    li      $v0,    4                   # print_string
    la      $a0,    prompt
    syscall

    # 整数入力
    li      $v0,    5
    syscall
    # move    $t0,    $v0                 # $t0 = 入力値
    move    $t1,    $v0                 # $t1 = 入力値

    # (x + 5)/10 の計算
    addi    $t1,    $t1,    5           # $t1 = $t1 + 5
    li      $t2,    10                  # $t2 = 10
    div     $t1,    $t2                 # $t1 / $t2 を計算
    mflo    $t1                         # $t1 = 商 (四捨五入後の値)
    mul     $a0,    $t1,    $t2         # $a0 = $t1 * 10 (戻す)

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
