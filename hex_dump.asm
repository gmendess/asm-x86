; Read a binary file from stdin by Linux input redirection and converts it's bytes to an
; hexadecimal string  and prints the result on  stdout (you can also  redirect the output
; to a file by output redirection) 
;
; nasm -f elf32 hex_dump.asm
; ld -m elf_i386 hex_dump.o -o hex_dump
; $ ./hex_dump < [binary file] > [output file]
;
; Output example:
;
; 7F 45 4C 46 01 01 01 00 00 00 00 00 00 00 00 00
; 02 00 03 00 01 00 00 00 80 80 04 08 34 00 00 00

; @hex_string: buffer that will be used to store each 16 bytes read from sys_read in
; hexadecimal string format. This buffer will be printed by sys_write at the end
; @hex_str_len: length of hex_string
section .data
  hex_string: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00", 0xA
  hex_str_len: equ $ - hex_string 

; @buffer_len: constant with number 16
; @buffer: buffer that will contain the (16) bytes read by sys_read
section .bss
  buffer_len: equ 16
  buffer: resb buffer_len

; @hex_digits: all the hex digits in a read only buffer
section .rodata
  hex_digits: db "0123456789ABCDEF"

section .text
  global _start

_start:
  nop                         ; for debug reasons

read:
  mov eax, 3                  ; sys_read
  mov ebx, 0                  ; file descriptor (stdin)
  mov ecx, buffer             ; store the bytes read in buffer
  mov edx, buffer_len         ; max bytes to be read
  int 0x80                    ; syscall

  cmp eax, 0                  ; verify if sys_read reached EOF
  je exit                     ; if so, then jump to exit, because there are no more bytes to convert to hexadecimal string
  mov esi, eax                ; else, store the number of bytes read in esi
  mov ebp, buffer             ; ebp points to 'buffer'

  ; zeroing register eax and ecx
  xor eax, eax                ; eax will be used to store some byte stored in 'buffer'
  xor ecx, ecx                ; ecx will be used as an index to iterate over 'buffer', which is pointed by ebp

; convert a byte to a hexadecimal string format. Example. 1001 1010b = 0x9A --converts-to--> "9A"
byte_to_hex_str:
  ; calculate the offset to store the hexadecimal string in the correct order inside hex_string
  mov edx, ecx                ; move the current byte's index to edx
  shl edx, 1                  ; shift left edx by 1 bit, basically multiplying by 2
  add edx, ecx                ; add ecx in edx. In the end, "edx = (ecx << 1) + ecx", and that's the same thing as "edx = ecx * 3"
                              ;                                    ----------
                              ;                                         `> (ecx * 2)

  mov al, byte [ebp + ecx]    ; store in al the byte stored in [ebp + ecx]. Example 1001 1010
  mov bl, al                  ; copy al to bl. al will represent the lower 4 bits, while bh will represent the higher 4 bits  

  and al, 0x0F                ; bit-mask so al can contain just the lower nibble. 1001 1010 and 0000 1111 = 0000 1010 => A
  shr bl, 4                   ; shift right bl 4 bits. 1001 0011 >> 4 = 0000 1001 => 9

  ; now, it's possible to get an hex character from hex_digits buffer, because al and bl works as an index
  mov al, [hex_digits + eax]  ; get the equilavent hex character stored in al. 9 = '9'
  mov bl, [hex_digits + ebx]  ; get the equilavent hex character stored in bl. A(10) = 'A'

  mov [hex_string + edx + 1], bl ; store the bytes's higher nibble in hex_string
  mov [hex_string + edx + 2], al ; store the bytes's lower nibble in hex_string

  inc ecx                     ; increment ecx
  cmp ecx, esi                ; compare ecx (index) with esi (bytes read)
  jne byte_to_hex_str         ; if they aren't equal, there are more bytes in 'buffer' to be iterated

write:
  mov eax, 4                  ; sys_write
  mov ebx, 1                  ; file descriptor (stdout)
  mov ecx, hex_string         ; buffer to be printed (all bytes converted to a hexadecimal string)
  mov edx, hex_str_len        ; buffer's length
  int 0x80                    ; syscall

  jmp read                    ; jump to label 'read' to read more 16 bytes from stdin

exit:
  mov eax, 1                  ; sys_exit
  xor ebx, ebx                ; return 0
  int 0x80                    ; sys_call
