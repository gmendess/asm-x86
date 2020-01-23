; Read a binary file from stdin by Linux input redirection and converts it's bytes to an ascii string,
; so the binary file contents can be read.
;
; nasm -f elf32 ascii_dump.asm
; ld -m elf_i386 ascii_dump.o -o ascii_dump
; ./ascii_dump < [BINARY_FILE]
;
; Output example:
;
; .ELF............
; ............4...
; ........4.....(.
; ................
; ................
; ................
; ........$.......
; ................
; ................
; ..........T5..1.
; 1...............
; ....A9.R........
; ................
; ......1.........
; ......
; .........
; .............!"#
; $%&'()*+,-./0123
; 456789:;<=>?@ABC
; DEFGHIJKLMNOPQRS
; TUVWXYZ[\]^_`ABC
; DEFGHIJKLMNOPQRS
; TUVWXYZ{|}~.....

section .rodata
  translation_table:
    ;   0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 0Ah, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   0 
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   1
    db 2Eh, 21h, 22h, 23h, 24h, 25h, 26h, 27h, 28h, 29h, 2Ah, 2Bh, 2Ch, 2Dh, 2Eh, 2Fh ;   2
    db 30h, 31h, 32h, 33h, 34h, 35h, 36h, 37h, 38h, 39h, 3Ah, 3Bh, 3Ch, 3Dh, 3Eh, 3Fh ;   3
    db 40h, 41h, 42h, 43h, 44h, 45h, 46h, 47h, 48h, 49h, 4Ah, 4Bh, 4Ch, 4Dh, 4Eh, 4Fh ;   4
    db 50h, 51h, 52h, 53h, 54h, 55h, 56h, 57h, 58h, 59h, 5Ah, 5Bh, 5Ch, 5Dh, 5Eh, 5Fh ;   5
    db 60h, 41h, 42h, 43h, 44h, 45h, 46h, 47h, 48h, 49h, 4Ah, 4Bh, 4Ch, 4Dh, 4Eh, 4Fh ;   6
    db 50h, 51h, 52h, 53h, 54h, 55h, 56h, 57h, 58h, 59h, 5Ah, 7Bh, 7Ch, 7Dh, 7Eh, 2Eh ;   7
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   8
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   9
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   A
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   B
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   C
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   D
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   E
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   F

section .data
  MAX_BYTES: equ 16
  output: db "................", 0xA
  output_len: equ $ - output
  
section .bss
  ; buffer that will store the bytes read from stdin
  buffer: resb MAX_BYTES

section .text
  global _start

_start:
  nop

read:
  mov eax, 3              ; sys_read
  mov ebx, 0              ; file descriptor (stdin)
  mov ecx, buffer         ; buffer that will store the bytes read from stdin
  mov edx, MAX_BYTES      ; max bytes to be read
  int 0x80                ; calling sys_read

  cmp eax, 0              ; checking the return from sys_read
  je exit                 ; if eax == 0, no bytes were read by sys_read, so jump to exit

  mov esi, eax            ; else, store the number of bytes read in esi

  xor eax, eax            ; cleaning eax
  xor ecx, ecx            ; cleaning ecx (will be used as an index)

; scan each byte stored in 'buffer'
scan:
  mov al, byte [buffer + ecx] ; store in al the byte pointed by [buffer + ecx]. 
  mov al, [translation_table + eax] ; move to al the byte translated

  mov byte [output + ecx], al ; move to [output + ecx] the byte translated previously
  inc ecx                 ; increment ecx

  cmp ecx, esi            
  jb scan                 ; if ecx < esi, jump to scan label to scan another byte

write:
  mov eax, 4              ; sys_write
  mov ebx, 1              ; file descriptor (stdout)
  mov ecx, output         ; buffer to be printed
  mov edx, output_len     ; number of bytes to be printed
  int 0x80                ; calling sys_write

  jmp read                ; jump to read to read more 16 bytes

exit:
  mov eax, 1              ; sys_exit
  xor ebx, ebx            ; ebx = 0
  int 0x80                ; calling sys_exit