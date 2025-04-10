/*-*- mode:unix-assembly; indent-tabs-mode:t; tab-width:8; coding:utf-8     -*-│
│ vi: set noet ft=asm ts=8 sw=8 fenc=utf-8                                 :vi │
╞══════════════════════════════════════════════════════════════════════════════╡
│ Copyright 2022 Justine Alexandra Roberts Tunney                              │
│                                                                              │
│ Permission to use, copy, modify, and/or distribute this software for         │
│ any purpose with or without fee is hereby granted, provided that the         │
│ above copyright notice and this permission notice appear in all copies.      │
│                                                                              │
│ THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL                │
│ WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED                │
│ WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE             │
│ AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL         │
│ DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR        │
│ PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER               │
│ TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR             │
│ PERFORMANCE OF THIS SOFTWARE.                                                │
╚─────────────────────────────────────────────────────────────────────────────*/
#include "libc/macros.h"
.privileged

//	Invokes clone() system call on GNU/Systemd.
//
//	@param	rdi	x0	is flags
//	@param	rsi	x1	is top of stack
//	@param	rdx	x2	is ptid
//	@param	rcx	x3	is ctid
//	@param	r8	x4	is tls
//	@param	r9	x5	is func(void*)→int
//	@param	8(rsp)	x6	is arg
//	@return	tid of child on success, or -errno on error
sys_clone_linux:
	beg
	pro
#ifdef __x86_64__
	cpush	%rbx
	mov	%rcx,%r10
	mov	16(%rbp),%rbx
	mov	$56,%eax		// __NR_clone
	syscall
	test	%rax,%rax
	jz	2f
0:	cpop	%rbx
	epi
	ret
2:	xor	%ebp,%ebp		// child thread
	mov	%rbx,%rdi		// arg
	call	*%r9			// func(arg,tid)
	xchg	%eax,%edi		// func(arg,tid) → exitcode
	mov	$60,%eax		// __NR_exit(exitcode)
	syscall
#elif defined(__aarch64__)
	mov	x8,x3			// swap x3 and x4
	mov	x3,x4			// swap x3 and x4
	mov	x4,x8			// swap x3 and x4
	mov	x8,#220			// __NR_clone
	svc	#0
	cbz	x0,2f
	epi
	ret
2:	mov	x29,#0			// wipe backtrace
	mov	x28,x3			// set cosmo tls
	mov	x0,x6			// child thread
	blr	x5
	mov	x8,#93			// __NR_exit
	svc	#0
#else
#error "unsupported architecture"
#endif
	end
	.endfn	sys_clone_linux,globl,hidden
