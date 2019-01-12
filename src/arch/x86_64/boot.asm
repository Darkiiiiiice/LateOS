; Boot.asm
; Date: 2019-01-12
; Author: MarioMang


global start
extern long_mode_start
[section .multiboot2_header]

MAGIC equ 0xE85250D6
ARCH equ 0x00000000

header_start:
    dd MAGIC            ; magic number
    dd ARCH             ; archituecture 0 (protected mode i386)
    dd header_end - header_start ; header length
    ; checksum
    dd 0x100000000 - (MAGIC + ARCH + (header_end - header_start))
    ; required end tag
    dw 0x0000       ; type
    dw 0x0000       ; flags
    dd 0x00000008   ; size

header_end:

[section .text]
bits 32

start:

    LABEL_GDT64:        dq 0x0000000000000000
    LABEL_DESC_CODE64:  dq 0x0020980000000000
    LABEL_DESC_DATA64:  dq 0x0000920000000000

    GdtLen64 equ $ - LABEL_GDT64
    GdtPtr64 dw GdtLen64 - 1
             dd LABEL_GDT64

    SelectorCode64  equ LABEL_DESC_CODE64 - LABEL_GDT64
    SelectorData64  equ LABEL_DESC_DATA64 - LABEL_GDT64


    mov esp, stack_top

    call check_multiboot
    call check_cpuid
    call check_long_mode


    ; init templete page table 0x90000
    mov dword [0x90000], 0x91007
    mov dword [0x90800], 0x91007

    mov dword [0x91000], 0x92007

    mov dword [0x92000], 0x000083
    mov dword [0x92008], 0x200083
    mov dword [0x92010], 0x400083
    mov dword [0x92018], 0x600083
    mov dword [0x92020], 0x800083
    mov dword [0x92028], 0xa00083

    ; load GDTR
    db 0x66
    lgdt [GdtPtr64]
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x7E00

    ; open PAE
    mov eax, cr4
    bts eax, 5
    mov cr4, eax

    ; load cr3
    mov eax, 0x90000
    mov cr3, eax

    ; enable long mode
    mov ecx, 0x0C0000080
    rdmsr

    bts eax, 0x08
    wrmsr

    ; open PE and paging
    mov eax, cr0
    bts eax, 0
    bts eax, 0x1F
    mov cr0, eax

    jmp SelectorCode64:long_mode_start

    mov dword [0xB8000], 0x2F4B2F4F



check_multiboot:
    cmp eax,0x36D76289
    jne .no_multiboot
    ret
.no_multiboot:
    mov al, '0'
    jmp error

check_cpuid:
    pushfd
    pop eax

    mov ecx, eax
    xor eax, 1 << 21

    push eax
    popfd

    pushfd
    pop eax

    push ecx
    popfd

    cmp eax, ecx
    je .no_cpuid
    ret
.no_cpuid:
    mov al, '1'
    jmp error


check_long_mode:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    setnb al
    jb .no_long_mode
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .no_long_mode
    ret
.no_long_mode:
    mov al, '2'
    jmp error


error:
    mov dword [0xB8000], 0x4F524F45
    mov dword [0xB8004], 0x4F324F52
    mov dword [0xB8008], 0x4F204F20
    mov byte [0xB800a], al

    hlt

[section .bss]
stack_bottom:
    resb 64
stack_top:

