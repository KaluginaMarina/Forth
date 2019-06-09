%ifndef _MACRO_
%define _MACRO_

%define _lw 0

%macro colon 3
    section .data
    w_%1: dq _lw
    db %2, 0
    db %3
    
    %define _lw w_%1 
    xt_%1:  dq docol_impl
%endmacro

%macro colon 2
    colon %1, %2, 0
%endmacro

%endif
