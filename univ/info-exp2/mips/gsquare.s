# ------------------------------
# データ領域
        .data
        .globl  s
s:      .word   0
        .globl  sq_s
sq_s:   .word   0

_s1:    .asciiz "\n"
# ------------------------------
# テキスト領域
        .text
        .globl  main
main:
        # 関数 main のプロローグ
        # 8($fp) : 被呼び出し保存 $ra
        # 4($fp) : 被呼び出し保存 $fp
        # 0($fp) : 被呼び出し保存 $s0
        addiu   $sp, $sp, -12       # スタックフレーム確保
        sw      $ra, 8($sp)         # $ra の保存
        sw      $fp, 4($sp)         # $fp の保存
        sw      $s0, 0($sp)         # $s0 の保存
        move    $fp, $sp            # フレームポインタ設定

        la      $t0, s              # s = 1
        li      $t1, 1
        sw      $t1, 0($t0)

whileLoop:
        la      $t0, s              # while (s <= 10) {
        lw      $s0, 0($t0)         # s0 = s の値
        li      $t1, 10
        sle     $t2, $s0, $t1       # s > 10 のときは _main_2 へ
        beqz    $t2, exitLoop

        jal     gsquare             # jump to gsquare and save position to $ra

        la      $t0, sq_s           # print_int(sq_s);
        lw      $a0, 0($t0)
        li      $v0, 1
        syscall                     # print_int

        la      $a0, _s1
        li      $v0, 4
        syscall                     # print_string

        la      $t0, s              # s = s + 1;
        lw      $s0, 0($t0)
        addi    $s0, 1
        sw      $s0, 0($t0)
        b       whileLoop           # loop back to whileLoop

exitLoop:
        # main 関数のエピローグ
        li      $v0, 0
        move    $sp, $fp            # スタックポインタ復元
        lw      $ra, 8($sp)         # $ra を復元
        lw      $fp, 4($sp)         # $fp を復元
        lw      $s0, 0($sp)         # $s0 を復元
        addiu   $sp, $sp, 12        # スタックフレーム開放
        jr      $ra                 # 終了

# --- 関数 gsquare に関する記述
        .globl  gsquare
gsquare:
        # 関数 gsquare のプロローグ
        # 8($fp) : 被呼び出し保存 $ra
        # 4($fp) : 被呼び出し保存 $fp
        # 0($fp) : 被呼び出し保存 $s0
        addiu   $sp, $sp, -12       # スタックフレーム確保
        sw      $ra, 8($sp)         # $ra の保存
        sw      $fp, 4($sp)         # $fp の保存
        sw      $s0, 0($sp)         # $s0 の保存
        move    $fp, $sp            # フレームポインタ設定

        la      $t0, s              # sq_s = s * s
        lw      $s1, 0($t0)         # $s1 = s
        mul     $s0, $s1, $s1       # $s0 = s * s
        la      $t0, sq_s
        sw      $s0, 0($t0)

        # gsquare 関数のエピローグ
        move    $sp, $fp
        lw      $ra, 8($sp)
        lw      $fp, 4($sp)
        lw      $s0, 0($sp)
        addiu   $sp, $sp, 12
        jr      $ra
