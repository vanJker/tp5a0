%include "boot.inc"

SECTION LOADER vstart=LOADER_BASE_ADDR
    ; print string by modify display memory
    mov byte [gs:0x00], 'E'
    mov byte [gs:0x01], 0x9d
    mov byte [gs:0x02], 'n'
    mov byte [gs:0x03], 0x9d
    mov byte [gs:0x04], 't'
    mov byte [gs:0x05], 0x9d
    mov byte [gs:0x06], 'e'
    mov byte [gs:0x07], 0x9d
    mov byte [gs:0x08], 'r'
    mov byte [gs:0x09], 0x9d
    mov byte [gs:0x0a], ' '
    mov byte [gs:0x0b], 0x9d
    mov byte [gs:0x0c], 'l'
    mov byte [gs:0x0d], 0x9d
    mov byte [gs:0x0e], 'o'
    mov byte [gs:0x0f], 0x9d
    mov byte [gs:0x10], 'a'
    mov byte [gs:0x11], 0x9d
    mov byte [gs:0x12], 'd'
    mov byte [gs:0x13], 0x9d
    mov byte [gs:0x14], 'e'
    mov byte [gs:0x15], 0x9d
    mov byte [gs:0x16], 'r'
    mov byte [gs:0x17], 0x9d

    jmp $
