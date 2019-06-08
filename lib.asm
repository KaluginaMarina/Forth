%include "lib1.asm"

global print_char  
global read_word
global read_char  
global string_equals
global string_length
        
section .text
   
; результат в rax
read_char:
    dec rsp                 ; выделение 1 байта на стеке
    xor rax, rax            ; syscall number
    xor rdi, rdi            ; stdout number
    mov rsi, rsp            ; адрес буфера для хранения символа
    mov rdx, 1              ; чтение только одного символа
    syscall
    test rax, rax           ; это eof?
    jz return               ;
    mov al, byte[rsp]       ; rax=char
return:
    inc rsp                 ; востановление rsp
    ret 



; rdi -- buffer, rsi -- buffer size
; возвращает указатель на слово, если оно не помещается в буфер, возвращает 0
read_word:
    mov r10, rdi            ; сохранение аргументов
    mov r9, rsi              
.skip:     
    call read_char          ; чтение след. символа
    xor rcx, rcx            ; rcx=0 -- количество символов
    cmp rax, 0x20           ; если это пробел - пропускаем
    je .skip                
    cmp rax, 0x0            ; если это NULL - выходим
    jle .return              
.next:											; след. символ
    cmp rax, 0x0            ; если NULL - выходим
    jle .return              
    cmp rax, 0x20           ; если пробел - выходим
    je .return              ; 
    cmp rax, 0x9            ; ели \t - выход
    je .return              
    cmp rax, 0xA            ; если \n - выход
    je .return              
    mov byte[r10+rcx], al   ; сохраняем символ
    push rcx                ; сохраняем rcx
    call read_char          ; читаем следующий символ
    pop rcx                 ; восстонавлиивем rcx
    inc rcx                 ; если мы все еще здесь -- это новый символ
    cmp r9, rcx             ; проверка, входит ли в буфер, если нет -- failed
    je .failed              
    jmp .next               ; else continue
.failed:
    mov rax, 0x0            ; 0x0 -- указатель на неудачу
    ret
.return:
    mov rdx, rcx            ; вернуть кол-во символов
    mov byte[r10+rcx], 0x0  ; добавление null-terminator 
    mov rax, r10            ; вернуть указатель
    ret

; печать символа в rdi
print_char:
    dec rsp                 ; выделить 1 байт на стеке
    mov byte[rsp], dil      ; сохранить символ в буфер
    mov rsi, rsp            ; адрес символа
    mov rdi, 1              ; stdin desсriptor
    mov rax, 1              ; syscall number
    mov rdx, 1              ; только один символ
    inc rsp                 ; восстановить rsp
    syscall
    ret


; rsi - указатель на первую строку, rdi - указатель на вторую строку
; возвращает 0 в rax, если указанные строки равны, 1 в противном случае 
string_equals:
.loop:
    mov r10b, byte[rdi]     ; символ сохранения первой строки
    cmp r10b, byte[rsi]     ; сравнение
    jne .false              ; если символы не равны -- строки не равны
    test r10b, r10b         ; если конец строки -- то строки равны
    jz .true                
    inc rdi                 ; если нет -- переход к следующему символу. Увеличиваем счетчик
    inc rsi                 
    jmp .loop               ; проверяем следующий символ
.true:
    mov rax, 0              ; rax=0 (true)
    ret
.false:
    mov rax, 1              ; rax=1 (false)
    ret


; указатель на строку в rdi
string_length:
    xor rax, rax            ; rax = 0
.loop: 
    mov dl, byte[rdi+rax]   ; берем след. символ
    test dl, dl             ; если это 0 - заканчиваем, иначе - увеличиваем счетчик и продолжаем
    jz .return              
    inc rax                 
    jmp .loop               
.return:
    ret



