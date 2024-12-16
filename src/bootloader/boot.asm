SECTION BOOT vstart=0x7c00
    mov ax, cs
    mov dx, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00
    
    ; clear by subfunction 0x06 of int 0x10
    mov ax, 0x600
    mov bx, 0x700
    mov cx, 0
    mov dx, 0x184f
    int 0x10

    ; get position of cursor by subfunction 0x3 of int 0x10
    mov ah, 0x3
    mov bh, 0
    int 0x10

    ; print string bu subfunction 0x13 of int 10
    mov ax, message
    mov bp, ax
    mov cx, 0xd
    mov ax, 0x1301
    mov bx, 0x2
    int 0x10

    jmp $

message db "Hello, world!"
times 510 - ($ - $$) db 0
db 0x55, 0xaa
