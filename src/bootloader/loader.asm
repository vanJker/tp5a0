%include "boot.inc"

SECTION LOADER vstart=LOADER_BASE_ADDR
    mov sp, LOADER_STACK_TOP

    ; print string by subfunction 0x13 of int 0x10
    mov bp, loader_message
    mov cx, 25
    mov ax, 0x1301
    mov bx, 0x001F
    mov dx, 0x1800
    int 0x10

    ; Enter protected mode
    ; 1. Enable A20
    in al, 0x92
    or al, 0x02
    out 0x92, al

    xchg bx, bx

    ; 2. load GDT to GDTR
    lgdt [GDT_PTR]

    ; 3. Enable CR0's PE flag
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    jmp dword SELECTOR_CODE:protected_mode_start

[bits 32]
protected_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov ax, SELECTOR_VIDEO
    mov gs, ax
    mov esp, LOADER_STACK_TOP

    ; print string by modify display memory
    mov byte [gs:160], 'E'
    mov byte [gs:161], 0xed
    mov byte [gs:162], 'n'
    mov byte [gs:163], 0xed
    mov byte [gs:164], 'a'
    mov byte [gs:165], 0xed
    mov byte [gs:166], 'b'
    mov byte [gs:167], 0xed
    mov byte [gs:168], 'l'
    mov byte [gs:169], 0xed
    mov byte [gs:170], 'e'
    mov byte [gs:171], 0xed
    mov byte [gs:172], ' '
    mov byte [gs:173], 0xed
    mov byte [gs:174], 'p'
    mov byte [gs:175], 0xed
    mov byte [gs:176], 'r'
    mov byte [gs:177], 0xed
    mov byte [gs:178], 'o'
    mov byte [gs:179], 0xed
    mov byte [gs:180], 't'
    mov byte [gs:181], 0xed
    mov byte [gs:182], 'e'
    mov byte [gs:183], 0xed
    mov byte [gs:184], 'c'
    mov byte [gs:185], 0xed
    mov byte [gs:186], 't'
    mov byte [gs:187], 0xed
    mov byte [gs:188], ' '
    mov byte [gs:189], 0xed
    mov byte [gs:180], 'm'
    mov byte [gs:181], 0xed
    mov byte [gs:182], 'o'
    mov byte [gs:183], 0xed
    mov byte [gs:184], 'd'
    mov byte [gs:185], 0xed
    mov byte [gs:186], 'e'
    mov byte [gs:187], 0xed

    jmp $

loader_message db "Enter loader in real mode"

GDT_BASE:
    dd 0x00000000
    dd 0x00000000
CODE_DESC:
    dd DESC_CODE_L4B
    dd DESC_CODE_H4B
DATA_DESC:
    dd DESC_DATA_L4B
    dd DESC_DATA_H4B
VIDEO_DESC:
    dd DESC_VIDEO_L4B
    dd DESC_VIDEO_H4B
GDT_SIZE equ $ - GDT_BASE
GDT_LIMIT equ GDT_SIZE - 1

GDT_PTR:
    dw GDT_LIMIT
    dd GDT_BASE
