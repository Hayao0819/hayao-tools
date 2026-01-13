# ------------------------------
# データ領域
        .data
_s1:    .asciiz "\n"

# ------------------------------
# テキスト領域
        .text
        .globl  main
main:
        # main 関数のプロローグ
        # 20($fp) : 被呼び出し保存 $ra
        # 16($fp) : 被呼び出し保存 $fp
        # 12($fp) : 引数 $a3
        # 8($fp) : 引数 $a2
        # 4($fp) : 引数 $a1
        # 0($fp) : 引数 $a0
        addiu   $sp, $sp, -24       # スタックフレーム確保
        sw      $ra, 20($sp)
        sw      $fp, 16($sp)
        move    $fp, $sp

        # 関数sum(10) の呼び出し
        li      $a0, 10             # 引数を10 に設定
        jal     sum                 # 関数sum を呼び出し
        move    $a0, $v0            # a0 = sum(10)
        li      $v0, 1              # print_int
        syscall

        la      $a0, _s1
        li      $v0, 4              # print_string
        syscall

        # 関数main のエピローグ
        li      $v0, 0              # 関数の返り値
        move    $sp, $fp            # スタックポインタ復元
        lw      $ra, 20($fp)        # $ra を復元
        lw      $fp, 16($sp)        # $fp を復元
        addiu   $sp, $sp, 24        # スタックフレーム開放
        jr      $ra
        # --- 関数main の記述終了

        # --- 関数sum の記述
        .globl  sum
sum:
        # 関数sum のプロローグ
        # 8($fp) : 被呼び出し保存 $ra
        # 4($fp) : 被呼び出し保存 $fp
        # 0($fp) : 局所変数 s
        addiu   $sp, $sp, -12       # スタックフレーム確保
        sw      $ra, 8($sp)         # $ra の保存
        sw      $fp, 4($sp)         # $fp の保存
        move    $fp, $sp            # フレームポインタ
        sw      $zero, 0($fp)       # 局所変数s を0 に

_sum_1:
        slt     $t0, $zero, $a0
        beq     $t0, $zero, _sum_2
        lw      $t1, 0($fp)         # 局所変数s を$t1 に
        add     $t1, $t1, $a0       # s = s + n
        sw      $t1, 0($fp)         # 局所変数s を更新
        addi    $a0, $a0, -1        # n = n - 1
        b       _sum_1

_sum_2:
        # 関数sum のエピローグ
        lw      $v0, 0($fp)         # s の値を$v0 へ
        move    $sp, $fp            # スタックポインタ復元
        lw      $ra, 8($sp)         # $ra を復元
        lw      $fp, 4($sp)         # $fp を復元
        addiu   $sp, $sp, 12        # スタックフレーム開放
        jr      $ra
# --- 関数sum の記述終了
# end
