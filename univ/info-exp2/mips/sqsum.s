        .data
        .globl  n
n:      .word   0
        .globl  s
s:      .word   0
prompt: .asciiz "Please input an integer: "
br:     .asciiz "\n"

        .text
        .globl  main
main:
        addiu   $sp, $sp, -24
        sw      $ra, 20($sp)
        sw      $fp, 16($sp)
        move    $fp, $sp

        # Display prompt
        li      $v0, 4
        la      $a0, prompt
        syscall

        # Read and store the input into n
        li      $v0, 5
        syscall
        la      $t0, n
        sw      $v0, 0($t0)

        # Call sqsum
        move    $a0, $v0
        jal     sqsum
        la      $t0, s
        sw      $v0, 0($t0)

        # Display the result
        move    $a0, $v0
        li      $v0, 1
        syscall

        # Put brake line
        li      $v0, 4
        la      $a0, br
        syscall

        li      $v0, 0
        move    $sp, $fp
        lw      $ra, 20($sp)
        lw      $fp, 16($sp)
        addiu   $sp, $sp, 24
        jr      $ra

        .globl  sqsum
sqsum:
        addiu   $sp, $sp, -24
        sw      $ra, 20($sp)
        sw      $fp, 16($sp)
        sw      $s0, 12($sp)
        sw      $s1, 8($sp)
        move    $fp, $sp
        move    $s0, $a0
        li      $s1, 1              # as i
        sw      $zero, 4($sp)       # as sum

loop:
        sgt     $t0, $s1, $s0
        bne     $t0, $zero, end_loop # Exit if i > n

        lw      $t1, 4($sp)
        mul     $t2, $s1, $s1       # i * i
        add     $t1, $t1, $t2       # sum = sum + i * i
        sw      $t1, 4($sp)
        addiu   $s1, $s1, 1         # i = i + 1
        b       loop

end_loop:
        lw      $v0, 4($sp)         # set sum into $v0
        move    $sp, $fp
        lw      $ra, 20($sp)
        lw      $fp, 16($sp)
        lw      $s0, 12($sp)
        lw      $s1, 8($sp)
        addiu   $sp, $sp, 24
        jr      $ra
