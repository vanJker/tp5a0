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

    ; detect memory capacity
    call detect_memory

    ; enter protected mode
    ; 1. enable A20
    in al, 0x92
    or al, 0x02
    out 0x92, al

    ; 2. load GDT to GDTR
    lgdt [GDT_PTR]

    ; 3. enable cr0's PE flag
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    jmp dword SELECTOR_CODE:protected_mode_start

; Detect memory capacity in 16-bit mode.
; @param    void
; @return   void
detect_memory:
    ; detect memory capacity by subfunction 0xE820 of int 0x15
    xor ebx, ebx
    mov edx, 0x534D4150
    mov di, ARDS_BUF
.e820_detect_memory_loop:
    mov eax, 0xE820
    mov ecx, 20
    int 0x15
    jc .e801_detect_memory_loop ; e820 failed try e801
    add di, cx
    inc word[ARDS_CNT]
    cmp ebx, 0
    jnz .e820_detect_memory_loop

    mov cx, [ARDS_CNT]
    mov ebx, ARDS_BUF
    xor edx, edx
.find_max_memory_area:
    mov eax, [ebx]
    add eax, [ebx + 8]
    add ebx, 20
    cmp edx, eax
    jge .next_ards
    mov edx, eax
.next_ards:
    loop .find_max_memory_area
    jmp .detect_memory_end

    ; detect memory capacity by subfunction 0xE801 of int 0x15
.e801_detect_memory_loop:
    mov ax, 0xE801
    int 0x15
    jc .88_detect_memory

    mov cx, 0x400
    mul cx ; equals to `mul ax, cx`, and result's high 16-bit in dx, low 16-bit in ax
    shl edx, 16
    and eax, 0x0000FFFF
    or edx, eax
    add edx, 0x100000

    mov esi, edx
    xor eax, eax
    mov ax, bx
    mov ecx, 0x10000
    mul ecx ; equals to `mul eax, ecx`, and result's high 32-bit in edx, low 32-bit in eax
    add esi, eax
    mov edx, esi

    jmp .detect_memory_end

.88_detect_memory:
    mov ah, 0x88
    int 0x15
    jc .error_hlt

    mov cx, 0x400
    mul cx ; equals to `mul ax, cx`, and result's high 16-bit in dx, low 16-bit in ax
    shl edx, 16
    and eax, 0x0000FFFF
    or edx, eax
    add edx, 0x100000

    jmp .detect_memory_end

.error_hlt:
    ; print string by subfunction 0x13 of int 0x10
    mov bp, detect_memory_error_message
    mov cx, detect_memory_error_message_end - detect_memory_error_message
    mov ax, 0x1301
    mov bx, 0x001F
    mov dx, 0x1800
    int 0x10

    jmp $

.detect_memory_end:
    mov [TOTAL_MEMORY_SIZE], edx
    ret

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

    ; enable paging
    ; 1. setup page directory and page table
    call setup_page_table

    ; 2. reset address in GDT and GDTR to be virtual address
    sgdt [GDT_PTR]
    mov ebx, [GDT_PTR + 2]                  ; get base address of GDT
    or dword [ebx + 0x18 + 4], 0xC0000000   ; map high 4 byet of base address of video segment to kernel space
                                            ; since low 4 byte is under 1MB
    add dword [GDT_PTR + 2], 0xC0000000     ; map base address of GDT to kernel space

    ; 3. reset stack pointer to be virtual address
    add esp, 0xC0000000

    ; 4. setup cr3 (PDR3)
    mov eax, PAGE_DIR_ADDR
    mov cr3, eax

    ; 5. enable cr0's PG flag
    mov eax, cr0
    or eax, (0x1 << 31)
    mov cr0, eax

    ; 6. reload GDTR and GDT which reset by virtual address
    lgdt [GDT_PTR]

    ; print string by modify display memory
    mov byte [gs:320], 'V'
    mov byte [gs:321], 0xfe
    mov byte [gs:322], 'i'
    mov byte [gs:323], 0xfe
    mov byte [gs:324], 'r'
    mov byte [gs:325], 0xfe
    mov byte [gs:326], 't'
    mov byte [gs:327], 0xfe
    mov byte [gs:328], 'u'
    mov byte [gs:329], 0xfe
    mov byte [gs:330], 'a'
    mov byte [gs:331], 0xfe
    mov byte [gs:332], 'l'
    mov byte [gs:333], 0xfe
    mov byte [gs:334], ' '
    mov byte [gs:335], 0xfe
    mov byte [gs:336], 'm'
    mov byte [gs:337], 0xfe
    mov byte [gs:338], 'e'
    mov byte [gs:339], 0xfe
    mov byte [gs:340], 'm'
    mov byte [gs:341], 0xfe
    mov byte [gs:342], 'o'
    mov byte [gs:343], 0xfe
    mov byte [gs:344], 'r'
    mov byte [gs:345], 0xfe
    mov byte [gs:346], 'y'
    mov byte [gs:347], 0xfe

    xchg bx, bx

    jmp $

; Setup page directory and page table about 1MB memory space in 32-bit mode
; @param    void
; @return   void
setup_page_table:
    mov ecx, 0x1000 ; 4KB
    mov esi, 0
.clear_page_dir:
    mov byte [PAGE_DIR_ADDR + esi], 0
    inc esi
    loop .clear_page_dir

    ; create pdes about low 1MB of physical memory
    mov eax, PAGE_TBL_ADDR
    mov ebx, eax

    or eax, PG_US_U | PG_RW_W | PG_P
    mov [PAGE_DIR_ADDR + 0x0], eax      ; map to same addr
    mov [PAGE_DIR_ADDR + 0xC00], eax    ; map to kernel space
    mov eax, PAGE_DIR_ADDR
    or eax, PG_US_U | PG_RW_W | PG_P
    mov [PAGE_DIR_ADDR + 4092], eax     ; map self (page directory) as page table

    ; create ptes about low 1MB of physical memory
    mov ecx, 256 ; 1MB / 4K = 256
    mov esi, 0
    mov edx, PG_US_U | PG_RW_W | PG_P
.create_pte:
    mov [ebx + esi * 4], edx
    inc esi
    add edx, 4096 ; a page about size 4KB
    loop .create_pte

    ; create pdes about high 1GB kernel space
    mov eax, PAGE_TBL_ADDR
    add eax, 0x1000 ; address of 2nd page table
    or eax, PG_US_U | PG_RW_W | PG_P
    mov ebx, PAGE_DIR_ADDR
    mov ecx, 254    ; 1GB / 4MB - 2 = 254 since high 1GB has 2 pde have been set
    mov esi, 0xC04
.create_pde_of_kernel:
    mov [ebx + esi], eax
    add eax, 0x1000
    add esi, 4
    loop .create_pde_of_kernel

    ret

loader_message:
    db "Enter loader in real mode"
loader_message_end:

detect_memory_error_message:
    db "Failed to detect memory capacity"
detect_memory_error_message_end:

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

TOTAL_MEMORY_SIZE:
    dd 0

ARDS_CNT:
    dw 0
ARDS_BUF:
