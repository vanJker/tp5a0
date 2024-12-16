SECTION BOOT vstart=0x7c00
    mov ax, cs
    mov dx, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00
    mov ax, 0xb800
    mov gs, ax
    
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

    ; print string by modify display memory
    mov byte [gs:0x00], 'H'
    mov byte [gs:0x01], 0x92
    mov byte [gs:0x02], 'e'
    mov byte [gs:0x03], 0x92
    mov byte [gs:0x04], 'l'
    mov byte [gs:0x05], 0x92
    mov byte [gs:0x06], 'l'
    mov byte [gs:0x07], 0x92
    mov byte [gs:0x08], 'o'
    mov byte [gs:0x09], 0x92
    mov byte [gs:0x0a], ','
    mov byte [gs:0x0b], 0x92
    mov byte [gs:0x0c], ' '
    mov byte [gs:0x0d], 0x92
    mov byte [gs:0x0e], 'w'
    mov byte [gs:0x0f], 0x92
    mov byte [gs:0x10], 'o'
    mov byte [gs:0x11], 0x92
    mov byte [gs:0x12], 'r'
    mov byte [gs:0x13], 0x92
    mov byte [gs:0x14], 'l'
    mov byte [gs:0x15], 0x92
    mov byte [gs:0x16], 'd'
    mov byte [gs:0x17], 0x92
    mov byte [gs:0x18], '!'
    mov byte [gs:0x19], 0x92

    jmp $

times 510 - ($ - $$) db 0
db 0x55, 0xaa
