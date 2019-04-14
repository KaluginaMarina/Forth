%macro native 3
    section .data
    w_%1: dq _lw
    db %2, 0
    db %3
    
    %define _lw w_%1 
    xt_%1:  dq %1_impl

    section .text
    %1_impl:
%endmacro

%macro native 2
native %1, %2, 0
%endmacro

;---------------------------------

native drop, "drop"
  pop rax
  jmp next

native swap, "swap"
	pop rax
	pop rdx
	push rax
	push rdx
	jmp next

native dup, "dup"
	push qword[rsp]
	jmp next

native plus, "+"
	pop r10 
	pop rax
	add rax, r10
	push rax
	jmp next

native minus, "-"
	pop r10
	pop rax
	sub rax, r10
	push rax
	jmp next

native mul, "*"
	pop r10
	pop rax
	imul r10
	push rax
	jmp next

native div, "/"
	pop r10
	pop rax
	xor rdx, rdx
	idiv r10
	push rax
	jmp next

native mod, "%"
	pop r10
	pop rax
	xor rdx, rdx
	idiv r10
	push rdx
	jmp next

native equals, "="
	pop r10
	pop r11
	cmp r10, r11
	je .equals
	push 0
	jmp next

.equals:
	push 1
	jmp next

native greater, "<"
	pop r10
	pop r11
	cmp r10, r11
	jg .greater
	push 1
	jmp next

.greater:
	push 0
	jmp next

native lesser, ">"
	pop r10
	pop r11
	cmp r11, r10
	jg .lesser
	push 1
	jmp next

.lesser:
	push 0
	jmp next

native and, "and"
   pop rax
   pop rdx
   and rax, rdx
   push rax
   jmp next

native or, "or"
   pop rax
   pop rdx
   or rax, rdx
   push rax
   jmp next

native land, "land"
   pop rax
   pop rdx
   test rax, rax
   jz .no
   push rdx
   jmp next

.no:
   push rax
   jmp next

native not, "not"
   pop rax
   test rax, rax
   jz .zero
   xor rax, rax
   push rax
   jmp next
 
.zero:
   mov rax, 1
   push rax
   jmp next

native lor, "lor"
   pop rax
   pop rdx
   test rax, rax
   jnz .yes
   push rdx
   jmp next

.yes:
   push rax
   jmp next

native to_ret, ">r"
	pop rax
	sub rstack, 8
	mov qword [rstack], rax
	jmp next

native from_ret, "r>"
	mov rax, qword[rstack]
	add rstack, 8
	push rax
	jmp next

native ret_fetch, "r@"
	push qword [rstack]
	jmp next

native fetch, "@"
	pop rax
	mov r10, [rax]
	push r10
	jmp next

native wr_by_address, "!"
	pop rax
	pop r10
	mov [r10], rax	
	jmp next

native wr_char, "c!"
  pop rax
  pop r10
  mov byte[r10], al
  jmp next

native read_char, "c@"
	pop rax
	movzx r10, byte[rax]
	push r10
	jmp next

native execute, "execute"
	pop rax
	mov w, rax
	jmp [rax]

native docol, "docol"
   sub rstack, 8
   mov [rstack], pc
   add w, 8
   mov pc, w
   jmp next

native branch, "branch"
   mov pc, [pc]
   jmp next

native branch0, "branch0"
   pop rax
   test rax, rax
   jnz .skip
   mov pc, [pc]
   jmp next

.skip:
   add pc, 8
   jmp next
 
