;; MultiBoot2 Header

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
