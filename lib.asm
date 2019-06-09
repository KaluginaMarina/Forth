    global exit
    global string_length
    global print_string
    global print_char  
    global print_newline
    global print_uint
    global print_int
    global string_equals
    global read_char
    global read_word
    global parse_uint
    global parse_int
    global string_copy 
 


section .text
 


; exit program with exitcode in rdi
exit:
    mov rax, 60             ; syscall number
    syscall


; count length of th string which pointer is in rdi
string_length:
    xor rax, rax            ; rax = 0
.loop: 
    mov dl, byte[rdi+rax]   ; get the next symbol
    test dl, dl             ; is it zero?
    jz .return              ; if it is then we're finish
    inc rax                 ; counter++
    jmp .loop               ; else
.return:
    ret


; prints string which pointer in rdi
print_string:
    call string_length      ; we need to know length of accepted string
    mov rdx, rax            ; saving length into rdx
    mov rax, 1              ; syscall number
    mov rsi, rdi            ; address of the string
    mov rdi, 1              ; stdin desсriptor
    syscall
    ret



; print out \n
print_newline:
    mov rdi, 0xA            ; code of \n 



; prints char in rdi
print_char:
    dec rsp                 ; allocate 1 byte on stack
    mov byte[rsp], dil      ; saving the character into buffer
    mov rsi, rsp            ; address of the character
    mov rdi, 1              ; stdin desсriptor
    mov rax, 1              ; syscall number
    mov rdx, 1              ; only one character
    inc rsp                 ; restoring rsp
    syscall
    ret



; print out unsigned number in rdi
print_uint:  
    mov rax, rdi            ; saving the number into rax
    xor rcx, rcx            ; count of digits
    mov r10, 10             ; r10 is temporary
    mov r8, rsp             ; saving rsp
    dec rsp                 ; allocate byte for 0x0
    mov byte[rsp], 0x0      ; making string null-terminated
.loop:
    dec rsp                 ; rsp--  
    xor rdx, rdx            ; rdx should be zero before next div
    div r10                 ; divide the number  
    mov byte[rsp], dl       ; saving the next digit 
    add byte[rsp], 0x30     ; code of a digit = digit + 0x30
    test rax, rax           ; is quotient = 0?              
    jnz .loop               ; if it isn't - continue
    mov rdi, rsp            ; pointer to a string
    call print_string       ; print out our number
    mov rsp, r8             ; restoring rsp
    ret



; print out signed number in rdi
print_int:
    cmp rdi, 0              ; is number < 0 ?
    jl .less                ; if it isn't, just print it as unsigned
    call print_uint         ; using print_uint
    ret
.less:
    push rdi                ; else firstly print '-'
    mov rdi, 45             ; code of '-'
    call print_char         ; print it out
    pop rdi                 ; and after that print out
    neg rdi                 ; the module of our number
    call print_uint
    ret



; rsi - pointer to a first string, rdi - pointer to a second string
; returns 0 in rax if pointed strings are equals, 1 otherwise
string_equals:
.loop:
    mov r10b, byte[rdi]     ; saving symbol of the first string
    cmp r10b, byte[rsi]     ; comparing symbols
    jne .false              ; if it isn't equal, then strings aren't equals
    test r10b, r10b         ; is there end of the string?
    jz .true                ; then we're done
    inc rdi                 ; increment pointers
    inc rsi                 ;
    jmp .loop               ; check the next character
.true:
    mov rax, 0              ; rax=0 (true)
    ret
.false:
    mov rax, 1              ; rax=1 (false)
    ret



; returns charcode in rax
read_char:
    dec rsp                 ; allocating 1 byte on stack
    xor rax, rax            ; syscall number
    xor rdi, rdi            ; stdout number
    mov rsi, rsp            ; address of buffer to store a char
    mov rdx, 1              ; we need to read only 1 char
    syscall
    test rax, rax           ; is it eof?
    jz return               ;
    mov al, byte[rsp]       ; rax=character
return:
    inc rsp                 ; restoring rsp
    ret 



; rdi points to a buffer, rsi is buffer size
; returns a pointer to a word, if it doesn't fit the buffer, returns 0
read_word:
    mov r10, rdi            ; saving arguments
    mov r9, rsi             ; 
.skip:     
    call read_char          ; reading the next symbol
    xor rcx, rcx            ; rcx=count of symbols=0
    cmp rax, 0x20           ; is it space?
    je .skip                ; if it is then we skip it
    cmp rax, 0x0            ; is it NUL?
    jle .return             ; if it is then we're done  
.next:
    cmp rax, 0x0            ; is it NUL?
    jle .return             ; if it is then we're done
    cmp rax, 0x20           ; is it space?
    je .return              ; if it is then we're done
    cmp rax, 0x9            ; is it \t?
    je .return              ; if it is then we're done
    cmp rax, 0xA            ; is it \n?
    je .return              ; if it is then we're done
    mov byte[r10+rcx], al   ; saving a character
    push rcx                ; saving rcx
    call read_char          ; reading the next symbol
    pop rcx                 ; restoring rcx
    inc rcx                 ; if we still here then it is a new symbol
    cmp r9, rcx             ; is length=size of buffer?
    je .failed              ; if it is then we're failed
    jmp .next               ; else continue
.failed:
    mov rax, 0x0            ; 0x0 as pointer mean that we're failed
    ret
.return:
    mov rdx, rcx            ; return count of symbols
    mov byte[r10+rcx], 0x0  ; adding a null-terminator
    mov rax, r10            ; return the pointer
    ret



; rdi points to a string
; returns rax: number, rdx : length
parse_uint:
    xor rax, rax            ; rax = 0 (here will be our number)
    xor rcx, rcx            ; rcx aka count of digits=0
    mov r10, 10             ; r10 is tempory register to store 10
    xor r8, r8              ; r8 is temporary register to store next digit
.loop:
    mov r8b, byte[rdi+rcx]  ; reading next symbol
    test r8, r8             ; is here end ot the string?
    jz .return              ; then we're done
    cmp r8, 0x39            ; if charcode > 0x39 - it is not a digit
    ja .return              ; and we're done
    cmp r8, 0x30            ; if charcode < 0x30 - it is not a digit
    jb .return              ; and we're done
    mul r10                 ; rax=rax*10.
    add rax,r8              ; rax=rax+ next digit
    sub rax, 0x30           ; because number = digitcode - 0x30
    inc rcx                 ; count++
    jmp .loop               ; continue
.return:
    mov rdx, rcx            ; rdx = count of digits
    ret



; rdi points to a string
; returns rax: number, rdx : length
parse_int:   
    cmp byte[rdi], 0x2D     ; is first char equals '-' ?
    jne .return             ; if it is, we're parsing it like unsigned
    inc rdi                 ; otherwise we also parse it like unsigned
    call parse_uint         ; pretty obviosly
    neg rax                 ; but after that we use neg
    inc rdx                 ; because of '-'
    ret
.return: 
    call parse_uint         ; just call parse usnsigned
    ret 



; rdi is a source pointer, rsi is a destination pointer, rdx = size of buffer
; rax = pointer to a destination if string fits buffer, 0 otherwise
string_copy:
    xor rcx, rcx            ; rcx aka count of symbols = 0
.loop:
    mov r10b, byte[rdi+rcx] ; reading next character
    test r10b, r10b         ; is it NUL?
    jz .return_succed       ; if it is then we're done
    mov byte[rsi+rcx], r10b ; else copy it to the buffer
    inc rcx                 ; count++
    cmp rdx, rcx            ; is count > size of buffer?
    je .return_failed       ; if it is, we're failed
    jmp .loop               ; else continue
.return_failed:
    xor rax, rax            ; if we're failed rax=0
    ret                      
.return_succed:
    mov byte[rsi+rcx], 0x0  ; we still should null-terminate the string
    mov rax, rsi            ; else rax = pointer to a string
    mov rdx, rcx
    ret
