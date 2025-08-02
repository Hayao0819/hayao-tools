	.file	"3.c"
	.text
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"The sum of %d and %d is %d\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movl	$15, %ecx
	movl	$10, %edx
	xorl	%eax, %eax
	movl	$5, %esi
	leaq	.LC0(%rip), %rdi
	call	printf@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 15.1.1 20250425"
	.section	.note.GNU-stack,"",@progbits
