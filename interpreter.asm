%include "util.inc"

global _start

%define pc r15
%define w r14
%define rstack r13

;----------------------------------
section .text

%include "functions.asm"

;----------------------------------
section .data

not_found: db "Unknown command: ", 0

program_stub: dq xt_selector    
last_word: dq _lw                 ; указатель на последнее слово
here: dq dict                     ; указатель на текущее
pointer: dq mem                   
stack_start: dq 0                 ; forth-db

;----------------------------------
section .bss

resq 1023
rstack_start: resq 1              

dict: resq 65536                  
mem: resq 65536                  
state: resq 1                     ; 1 -- compiling
input_buf: resb 1024             

;----------------------------------
section .text

_start:
   mov rstack, rstack_start
   mov [stack_start], rsp
   mov pc, program_stub 
   jmp next

next: 
    mov w, pc
    add pc, 8
    mov w, [w]
    jmp [w]

