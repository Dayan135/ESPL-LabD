section .bss
    input_buffer resb 600          ; Buffer to store input from fgets
    struct_size resb 1             ; Store size of the structure (unsigned char)
    struct_num resb 300            ; Store multi-precision number (up to 300 bytes)


section .data
    x_struct: db 5
    x_num: db 0xaa, 1,2,0x44,0x4f
    format: db "%d",10,0
    string_format: db "%s",10,0
    hex_format: db "%02hhx",0
    newLine: db 10,0
    prompt db "Enter a hexadecimal number: ", 0
    fgets_format db "%s", 0        ; Format for fgets

section .text
    global main                  ; Make 'main' visible to the linker
    extern printf, puts, fgets, stdin         ; Declare external C functions

main:
    push    ebp
    mov     ebp, esp

    call    get_input          ; size -> cl
    mov     eax, struct_size
    mov     byte [eax], cl


    mov     eax, input_buffer
    push    eax
    push    ecx
    call    string_to_hexa
    add     esp, 8


    ; pushad
    ; push ecx
    ; mov eax, format
    ; push eax
    ; call printf
    ; add esp,8
    ; popad

    mov     eax, struct_size
    push    eax
    call    print_struct
    add     esp,4


    mov     esp, ebp
    pop     ebp
    ret

;; ffunction getStructt
; none input
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
    
    mov     esi, struct_num                        ; index to struct_num array
    xor     edi, edi
    mov     ecx, [ebp + 4*2]                    ;size
    mov     ebx, [ebp + 4*3]                    ;string


    rcr     cl, 1
    jnc     even_size
    ; odd size
    rcl     cl, 1
    xor     eax, eax
    mov     al, [ebx]
    push    eax
    call    make_hexa_num
    add     esp, 4
    mov     byte [esi], al


    inc     ebx
    dec     cl
    inc     edi
    jmp     continue_

even_size:
    rcl     cl, 1
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
    inc     edi
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


;;funtion print struc 
;; input: pointer to a struct( char size, char* arr )
;; prints the sruct
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
    rcr     cl,1
    jnc     con
    inc     cl
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

;; task0 function.
;; input: int argc,  char** argv
;; pprints: the size and the argv
task0:
    push    ebp                  ; Save base pointer
    mov     ebp, esp             ; Set base pointer to current stack pointer

    mov     ecx, [ebp + 4*2]      ; ecx <- argc

    mov     eax, format
    push    ecx
    push    eax
    call    printf
    add     esp, 8               ; recover stack

    mov     ecx, [ebp + 4*2]      ; ecx <- argc
    mov     edx, [ebp + 4*3]      ; edx <- argv

print_loop1:
    cmp     ecx,0
    jle     end
    dec     ecx

    mov     eax, dword [edx]
    push    edx
    push    ecx
    push    eax
    call    puts
    add     esp, 4
    pop     ecx
    pop     edx

    add     edx,4
    jmp     print_loop1

end:
    mov     esp, ebp
    pop     ebp
    ret

