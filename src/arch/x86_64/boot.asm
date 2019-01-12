; Boot.asm
; Date: 2019-01-12
; Author: MarioMang

global start

[section .text]
bits 32

start:
    mov dword [0xB8000], 0x2F4B2F4F
    hlt


