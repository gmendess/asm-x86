; Read a binary file from stdin by Linux input redirection and converts it's bytes to an
; hexadecimal string and ascii string then prints the result on stdout.
;
; nasm -f elf32 hex_dump_v2.asm
; ld -m elf_i386 hex_dump_v2.o -o hex_dump_v2
; $ ./hex_dump_v2 < [binary file] > [output file]
;
; Output example:
;
; 7F 45 4C 46 01 01 01 00 00 00 00 00 00 00 00 00 |.ELF............|
; 02 00 03 00 01 00 00 00 80 80 04 08 34 00 00 00 |............4...|

section .data
  hex_buffer:   db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
  hex_length:   equ $ - hex_buffer
  ascii_buffer: db "|................|", 0xA
  ascii_length: equ $ - ascii_buffer
  full_length:  equ $ - hex_buffer
  MAX_BYTES:    equ 16

section .rodata
  ascii_table:
    ;   0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   0
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   1
    db 20h, 21h, 22h, 23h, 24h, 25h, 26h, 27h, 28h, 29h, 2Ah, 2Bh, 2Ch, 2Dh, 2Eh, 3Fh ;   2
    db 30h, 31h, 32h, 33h, 34h, 35h, 36h, 37h, 38h, 39h, 3Ah, 3Bh, 3Ch, 3Dh, 3Eh, 4Fh ;   3
    db 40h, 41h, 42h, 43h, 44h, 45h, 46h, 47h, 48h, 49h, 4Ah, 4Bh, 4Ch, 4Dh, 4Eh, 5Fh ;   4
    db 50h, 51h, 52h, 53h, 54h, 55h, 56h, 57h, 58h, 59h, 5Ah, 5Bh, 5Ch, 5Dh, 5Eh, 5Fh ;   5
    db 60h, 61h, 62h, 63h, 64h, 65h, 66h, 67h, 68h, 69h, 6Ah, 6Bh, 6Ch, 6Dh, 6Eh, 6Fh ;   6
    db 70h, 71h, 72h, 73h, 74h, 75h, 76h, 77h, 78h, 79h, 7Ah, 7Bh, 7Ch, 7Dh, 7Eh, 2Eh ;   7
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   8
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   9
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   A
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   B
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   C
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   D
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   E
    db 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh, 2Eh ;   F

  hex_digits: db "0123456789ABCDEF"

section .bss
  buffer: resb MAX_BYTES

section .text
  global _start

; ------------------ _start and PROCEDURES ------------------ ;

; read up to 16 bytes from stdin and store in 'buffer'.
; return in esi the number of bytes read
load_buffer:
  push eax            ; save caller's registers
  push ebx
  push ecx
  push edx

  mov eax, 3          ; sys_read
  mov ebx, 0          ; stdin
  mov ecx, buffer     ; buffer that will store the bytes read from stdin
  mov edx, MAX_BYTES  ; max numbers of bytes to be read
  int 0x80            ; sys_call

  mov esi, eax        ; save the number of bytes read from stdin

  pop edx             ; restore caller's registers 
  pop ecx
  pop ebx
  pop eax
  ret                 ; return to caller

; translate the byte stored in eax to a hexadecimal string format and dump it in hex_buffer
; each byte's nibble will be stored in a different register: eax will store the lower nibble
; and ebx will store the higher nibble. 
dump_hex:
  push eax ; save caller's register
  push ebx
  push edx

  mov ebx, eax ; copy eax to ebx

  and eax, 0x0000000F ; bit-mask eax to get the lower nibble
  shr ebx, 4          ; shift left ebx 4 times to get the higher nibble

  mov al, [hex_digits + eax] ; translate the lower nibble to its respective hex digit 
  mov bl, [hex_digits + ebx] ; translate the higher niblle to its respective hex digit

  ; after getting the hex digits, we have to dump it in hex_buffer. But first, is necessary to
  ; calculate the offset to dump the digits in the correct position into hex_buffer. For that
  ; we have to multiply ecx by 3, because each hex_buffer's element is represented by the string
  ; " 00", which is 3 bytes in length
  lea edx, [ecx * 2 + ecx]

  mov [hex_buffer + edx + 1], bl ; hex_buffer + offset + 1(higher nibble)
  mov [hex_buffer + edx + 2], al ; hex_buffer + offset + 2(lower nibble)

  pop edx ; restore caller's register
  pop ebx
  pop eax
  ret     ; return to caller

; translate the byte stored in eax to a ascii character using the ascii_table. After it, 
; dump the ascii char into ascii_buffer
dump_ascii:
  push eax ; save caller's eax

  mov al, [ascii_table + eax]      ; translate the byte to its respective ascii character
  mov [ascii_buffer + ecx + 1], al ; dump into ascii_buffer the ascii character

  pop eax  ; restore calle's eax
  ret      ; return to caller

; clean the hex_buffer and ascii_buffer
clean_line:
  push eax        ; save caller's register
  push ecx

  mov ecx, 15     ; 16 iterations, starting at 0
  xor eax, eax    ; reset eax 
l1:
  call dump_hex   ; call dump_hex to fill hex_buffer with 0
  call dump_ascii ; call dump_ascii to fill ascii_buffer with .
  sub ecx, 1      ; decrement ecx by 1 (i used sub instead of dec, because dec doesn't change EFLAGS)
  jae l1          ; jump to l1 if ecx is above or equal 0

  pop ecx         ; restore caller's register
  pop eax
  ret             ; return to caller

; starting point for the linker
_start:
  nop
  nop

; read up to 16 bytes and check if some byte were read
read_loop:
  call load_buffer
  cmp esi, 0           ; check if esi == 0
  je exit              ; if so, sys_read reached EOF reading from stdin, then jump to exit

  mov ebp, buffer      ; ebp points to buffer
  xor ecx, ecx         ; reset ecx to be used as an index

; iterate over each byte in buffer to dump it to hex string and ascii format
iterate_buffer:
  mov al, [ebp + ecx]  ; move the byte stored in [ebp + ecx] to the lower byte of eax
  call dump_hex        ; translate and dump the byte into hex_buffer
  call dump_ascii      ; translate and dump the byte into ascii_buffer 
  inc ecx              ; increment ecx
  cmp ecx, esi         ; check if ecx is lower than esi
  jb iterate_buffer    ; if so, then jump iterate_buffer, because there are more bytes to translate

; after iterate the whole buffer, write hex_buffer and ascii_buffer
write_line:
  mov eax, 4           ; sys_write
  mov ebx, 1           ; stdout
  mov ecx, hex_buffer  ; start printing at hex_buffer
  mov edx, full_length ; max number of bytes to be printed (include both hex_buffer and ascii_buffer)
  int 0x80             ; syscall

  call clean_line      ; clean hex_buffer and ascii_buffer
  jmp read_loop        ; read more 16 bytes

; exit the program correctly
exit:
  mov eax, 1          ; sys_exit
  xor ebx, ebx        ; reset ebx
  int 0x80            ; syscall