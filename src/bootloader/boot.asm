%include "boot.inc"

SECTION BOOT vstart=0x7c00
    ; init registers
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

    ; load loader from disk to memory
    mov eax, LOADER_START_SECTOR
    mov bx, LOADER_BASE_ADDR
    mov cx, 4
    call read_disk_m16

    ; jump into loader
    jmp LOADER_BASE_ADDR

; Read data from disk in 16-bit mode.
; @param    eax     LBA of start sector to be read
; @param    bx      base address about write in memory
; @param    cx      number of sector(s) to be read
; @return   none
read_disk_m16:
    mov esi, eax
    mov di, cx

    ; first, setup number of sector(s) to be read
    mov dx, 0x1f2
    mov al, cl
    out dx, al
    mov eax, esi

    ; second, setup LBA of start sector to be read
    mov dx, 0x1f3
    out dx, al

    mov dx, 0x1f4
    mov cl, 8
    shr eax, cl
    out dx, al

    mov dx, 0x1f5
    shr eax, cl
    out dx, al

    mov dx, 0x1f6
    shr eax, cl
    and al, 0x0f
    or al, 0xe0
    out dx, al

    ; third, send read command
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; fourth, check status of disk
.not_ready:
    nop
    in al, dx
    and al, 0x88
    cmp al, 0x08
    jnz .not_ready

    ; fifth, read data from port
    mov ax, di
    mov dx, 256
    mul dx
    mov cx, ax ; port 0x1f0 is 16-bit equals 2 Bytes
    mov dx, 0x1f0
.read_data_loop:
    in ax, dx
    mov [bx], ax
    add bx, 2
    loop .read_data_loop

    ret

times 510 - ($ - $$) db 0
db 0x55, 0xaa
