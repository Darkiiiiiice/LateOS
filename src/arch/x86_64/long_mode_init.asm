global long_mode_start

extern kmain
[section .text]
bits 64

long_mode_start:
    mov rax, 0x2f592F412F4B2F4F
    mov qword [0xB8000], rax

    call kmain

    hlt