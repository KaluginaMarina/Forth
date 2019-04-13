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
