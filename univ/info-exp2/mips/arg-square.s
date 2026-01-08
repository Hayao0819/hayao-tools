# ------------------------------
# データ領域
        .data
        .globl  v
v:      .word   0
_s1:    .asciiz "\n"

# ------------------------------
# テキスト領域
        .text
        .globl  main
main:
        # 関数main のプロローグ
        # 20($fp) : 被呼び出し側保存 $ra
        # 16($fp) : 被呼び出し側保存 $fp
        # 12($fp) : 引数 $a3
        # 8($fp) : 引数 $a2
        # 4($fp) : 引数 $a1
        # 0($fp) : 引数 $a0
        addiu   $sp, $sp, -24       # スタックフレーム確保
        sw      $ra, 20($sp)        # $ra を保存
        sw      $fp, 16($sp)        # $fp を保存
        move    $fp, $sp            # $fp = $sp

        # v = square(99);
        li      $a0, 99             # 引数レジスタ $a0 へ引数をロード
        jal     square              # square にジャンプ
        la      $t0, v              # 関数値 $v0 をv に代入
        sw      $v0, 0($t0)

        # print_int(v);
        la      $t0, v
        lw      $a0, 0($t0)
        li      $v0, 1              # print_int
        syscall

        # print_string("\n");
        la      $a0, _s1
        li      $v0, 4              # print_string
        syscall

        # return 0;
        li      $v0, 0
        move    $sp, $fp
        lw      $ra, 20($sp)
        lw      $fp, 16($sp)
        addiu   $sp, $sp, 24
        jr      $ra                 # jump to $ra

        .globl  square
square:
        # 関数square のプロローグ
        addiu   $sp, $sp, -12       # スタックフレーム確保
        sw      $ra, 8($sp)         # $ra を保存
        sw      $fp, 4($sp)         # $fp を保存
        sw      $s0, 0($sp)         # $s0 を保存
        move    $fp, $sp            # $fp = $sp

        # return n * n;
        mul     $s0, $a0, $a0       # $s0 = n*n
        move    $v0, $s0            # 関数値の設定

        # 関数square のエピローグ
        move    $sp, $fp
        lw      $ra, 8($sp)         # $ra を復元
        lw      $fp, 4($sp)         # $fp を復元
        lw      $s0, 0($sp)         # $sp を復元
        addiu   $sp, $sp, 12        # スタックフレームを開放
        jr      $ra                 # 呼び出し元へジャンプ
