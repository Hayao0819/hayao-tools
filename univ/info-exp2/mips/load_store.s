.data
        .globl  src         # 大域変数 src の宣言
src:    .word   2025
        .globl  dst         # 大域変数 dst の宣言
dst:    .word   0
.text
        .globl  main
main:                       # main ラベル（ここから実行が開始される）
    la      $t0,    src     # $t0 = 変数 src のアドレス
    lw      $s0,    0($t0)  # $s0 に変数 src の値をロード
    la      $t1,    dst     # $t1 に変数 dst の値をロード
    sw      $s0,    0($t1)  # $s0 の値を変数 dst へストア
    li      $v0,    0
    jr      $ra             # プログラムの終了
