section .bss
    input_buffer resb 600          ; Buffer to store input from fgets
    struct1 resb 1                 ; Store size of the structure (unsigned char)
    struct1_num resb 300            ; Store multi-precision number (up to 300 bytes)
    struct2 resb 1                 ; Store size of the structure (unsigned char)
    struct2_num resb 300            ; Store multi-precision number (up to 300 bytes)

section .data
    x_struct: db 5
    x_num: db 0xaa, 1,2,0x44,0x4f
    y_struct: db 7
    y_num: db 0xab, 0xaa, 1,2,3,0x44,0x4f
    format: db "%d",10,0
    string_format: db "%s",10,0
    structs_got : db "structs got:", 10,0
    hex_format: db "%02hhx",0
    newLine: db 10,0
    prompt db "Enter a hexadecimal number: ", 0
    fgets_format db "%s", 0        ; Format for fgets

section .text
    global main                  ; Make 'main' visible to the linker
    extern printf, puts, fgets, stdin, malloc         ; Declare external C functions

main:
    push    ebp
    mov     ebp, esp

    mov     eax, struct1
    push    eax
    call    get_and_create_struct
    add     esp,4

    mov     eax, struct2
    push    eax
    call    get_and_create_struct
    add     esp,4

    mov ecx, structs_got
    push ecx
    call printf
    add esp,4

    mov eax, struct1
    push eax
    call print_struct


    mov ebx, struct2
    push ebx
    call print_struct
    
    call add_multi
    add esp,8

    push eax
    call print_struct


    mov     esp, ebp
    pop     ebp
    ret

; function get_and_create_struct
; input: pointer tto unintialized struct
; inputs from user hexa num and pputs in the struct
get_and_create_struct:
    push    ebp
    mov     ebp,esp

    call    get_input          ;cl holds the size
    mov     eax, [ebp + 4 * 2] ; eax <<- pointer tto the struct

    push    eax                 ;pointer to the struct
    push    ecx                 ;size of buffer
    call    string_to_hexa
    pop     ecx
    pop     eax

    rcr     cl, 1
    adc     cl, 0
    mov     byte [eax], cl

    mov     esp,ebp
    pop     ebp
    ret



;; ffunction getStructt
; inpput: pointer to empty struct
; inpputs from user to input_buffer
;returns input size -> cl
get_input:
    push    ebp
    mov     ebp, esp

    ; Prompt the user
    push    prompt
    call    puts
    add     esp, 4

    ; Read input using fgets
    mov     eax, input_buffer
    push    dword [stdin]          ; stdin
    push    600                    ; Length of the buffer
    push    eax                    ; Buffer address
    call    fgets                  ; fgets(input_buffer, 600, stdin)
    add     esp, 12

    mov     eax, input_buffer
    xor     ecx, ecx
    xor     edx, edx

check_size:
    mov     dl, [eax]

    cmp     dl, 0
    je      end_check_size
    cmp     dl, 10
    je      end_check_size

    inc     cl
    inc     eax
    jmp     check_size

end_check_size:             ;cl <- size
    mov     esp,ebp
    pop     ebp
    ret


;function. input: size, string. converts into hexa number. -> struct_num
string_to_hexa:
    push    ebp
    mov     ebp, esp
    
    mov     esi, [ebp + 4*3]                        ; index to struct_num array
    inc     esi
    xor     edi, edi
    mov     ecx, [ebp + 4*2]                    ;size
    mov     ebx, input_buffer                   ;string

    mov edi, ecx

    rcr     edi, 1
    jnc     even_size
    ; odd size
    xor     eax, eax
    mov     al, [ebx]
    push    eax
    call    make_hexa_num
    add     esp, 4
    mov     byte [esi + edi], al

    inc     ebx
    dec     cl

even_size:
    dec     edi
continue_:
    cmp     cl, 0
    jle     end_string_to_hexa

    ;; high hexa digit
    xor     eax, eax
    mov     al, [ebx]
    push    eax
    call    make_hexa_num
    add     esp, 4



    mov     dl, al
    ; low hexa digit
    xor     eax, eax
    mov     al, [ebx + 1]
    push    eax
    call    make_hexa_num
    shl     edx, 4
    or      edx, eax

    mov     byte [esi + edi], dl

    add     cl, -2
    add     ebx, 2
    dec     edi
    jmp     continue_

end_string_to_hexa:
    mov     esp,ebp
    pop     ebp
    ret


; function. 
;; input: single char
;; output: hex value of the char (eax)
make_hexa_num: 
    push    ebp
    mov     ebp, esp

    mov     eax, [ebp + 2*4]
    cmp     eax, '9'             ;57 = '9'
    jle     numeric_char
    cmp     eax, 'z'            ; 122 = 'z'
    jg      wrong_char
    cmp     eax, 'a'             ; 97 = 'a'
    jl      wrong_char
    sub     eax, 'a'
    add     eax, 10
    jmp     end_make_hexa_num
numeric_char:
    cmp     eax, '0'             ; 48 = '0'
    jl      wrong_char
    sub     eax, '0'
    jmp     end_make_hexa_num

wrong_char:
    ;do something

end_make_hexa_num:
    mov     esp,ebp
    pop     ebp
    ret

    mov     esp,ebp
    pop     ebp
    ret


;function
;input: struct1, struct2
; outpu(eax) : struct3 = struct1+struct2
add_multi:
    push    ebp
    mov     ebp, esp
    sub     esp, 12               ;local var for new struct pointer

    mov eax, [ebp + 4 * 2]      ;eax = struct1
    mov ebx, [ebp + 4 * 3]      ;ebx = struct2

    xor ecx, ecx
    xor edx, edx
    mov cl, [eax]           ;cl = size 1
    mov dl, [ebx]           ;dl = size 2

    cmp cl,dl
    jg s1_bigger
    ;s2 is bigger -> xchange them so the bigger will be in eax size in cl
    xchg eax, ebx
    xchg ecx, edx

s1_bigger:                          ;the bigger struct is in eax
    mov dword [ebp - 4*2], ecx      ; save the bigger size localy
    mov dword [ebp - 4*3], edx      ; save the smaller size localy
    mov esi,ecx
    add esi,2
    push edx
    pushad
    push    esi
    call    malloc
    mov     dword [ebp-4], eax
    pop     esi
    popad
    pop edx

    dec esi                         ;real size
    mov edi, [ebp - 4]                ; pointer to the struct
    mov ecx, esi
    mov byte [edi], cl             ; put the size field

        ; Assumptions:
    ; EAX - pointer to the larger array (starts from the second byte)
    ; EBX - pointer to the smaller array (starts from the second byte)
    ; EDX - size of the smaller array (number of data bytes to sum)
    ; [EBP - 8] - size of the larger array (number of data bytes to sum)
    ; EDI - pointer to the result array (starting from the second byte)

    ; Clear carry flag at the start of the addition
    clc

    ; Adjust pointers to skip the first byte (length byte) in each array
    inc eax  ; Now EAX points to the second byte of the larger array
    inc ebx  ; Now EBX points to the second byte of the smaller array
    inc edi  ; Now EDI points to the second byte of the result array
    xor ecx, ecx    ;ecx will bee thee last carry

    ; Start the loop to process the bytes from both arrays
sum_loop:
    ; Check if we have finished processing the bytes of the smaller array
    cmp edx, 0           ; Compare the size of the smaller array with 0
    je finish_smaller_array ; If we finished the smaller array, jump to the finish_smaller_array section

    ; Preserve EAX and EBX before modifying AL and BL
    push eax
    push ebx

    ; Load the next byte from the larger array and the smaller array into temporary registers
    mov al, byte [eax]    ; Load byte from larger array into AL
    mov bl, byte [ebx]    ; Load byte from smaller array into BL

    ; Add the two bytes with carry
carry:
    add al, cl            ;adding the last carry
    mov ecx,0
    adc cl, 0             ;if carried,, move it to next iteration
    add al, bl            ; AL = AL + BL (addition)
    adc cl, 0             ; Add the carry to CL (to the next addition)

    ; Store the result in the result array
    mov byte [edi], al    ; Store the result byte in the result array

    ; Restore the values of EAX and EBX
    pop ebx
    pop eax

    ; Increment the pointers to move to the next byte in the arrays
    inc eax
    inc ebx
    inc edi

    ; Decrement the loop counter and continue the loop
    dec edx
    jmp sum_loop

finish_smaller_array:
    ; Process remaining bytes from the larger array (if any)
    ; EDX == 0, but we still have bytes left in the larger array
    mov esi, dword [ebp - 4*3]
    mov edx, [ebp - 8]
    sub edx, esi                ;get the size of bytes to complete
    
    jz finish_addition        ; If no bytes are left in the larger array, jump to finish_addition
    

process_larger_array:
    ; Preserve EAX before modifying AL
    push eax

    ; Load the next byte from the larger array into AL
    mov al, byte [eax]    ; Load byte from larger array into AL

    ; Add the carry if any
carry1:
    add al, cl             ; Add the last carry to AL
    mov ecx,0              ; from now on no carry
    adc cl,0

    ; Store the result in the result array
    mov byte [edi], al    ; Store the result byte in the result array

    ; Restore EAX after modification
    pop eax

    ; Increment the pointers to move to the next byte in the arrays
    inc eax
    inc edi

    ; Decrement the loop counter for the larger array
    dec edx   ; Decrease the remaining size of the larger array
    cmp edx, 0 ; Check if we have processed all bytes of the larger array
    jz finish_addition
    jmp process_larger_array ; Continue if there are more bytes left in the larger array
    
    

finish_addition:
    ; The carry flag (CF) will indicate if there was an overflow in the final sum
    ; If desired, you can handle this overflow here
    mov byte [edi], cl              ;if there was carry in last addition
    
    mov     eax, dword [ebp-4]          ;save the allocated array to return
    ; Clean up the stack
    mov esp, ebp
    pop ebp
    ret


; function print_struct
; inputt pointer to a struct
; prints it
print_struct:
    push    ebp                  ; Save base pointer
    mov     ebp, esp             ; Set base pointer to current stack pointer

    mov     eax, [ebp + 2*4]     ; eax <- struct

    xor     ecx,ecx
    mov     cl, [eax]
    mov     ebx, format

    push    ecx
    push    ebx
    call    printf
    add     esp, 8

    
    mov     eax, [ebp + 2*4]
    xor     ecx, ecx
    mov     cl, [eax]
    ; rcr     cl,1
    ; jnc     con
    ; inc     cl
con:
    add     eax, ecx
    mov     edx, hex_format

print_loop:
    cmp     cl, 0
    je      end_print_loop

    push    ecx
    push    eax
    xor     ebx, ebx
    mov     bl, [eax]
    push    ebx
    push    edx
    call    printf
    pop     edx
    add     esp, 4
    pop     eax
    pop     ecx

    dec     eax
    dec     cl
    jmp     print_loop

end_print_loop:
    mov     eax, newLine
    push    eax
    call    printf

    mov     esp, ebp
    pop     ebp
    ret
