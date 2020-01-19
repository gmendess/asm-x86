; Lê um texto da entrada padrão e converte cada caractere minúsculo para
; um caractere maiúsculo. Após isso, imprime todo o texto em maiúsculo
;
; nasm -f elf32 lower_to_upper.asm
; ld -m elf_i386 lower_to_upper.o -o lower_to_upper
; $ ./lower_to_upper > saida.txt < entrada.txt

; initialized read-only data
section .rodata
  max_bytes: equ 256     ; create a variable just to prevent "magic numbers"

; non initialized data
section .bss
  buffer: resb max_bytes ; reserve 'max_bytes' to store user input
  bytes_read: resb 1     ; reserve 1 byte to store the number of bytes read (will be used in sys_write)

section .text
  global _start

; entry point for linker
_start:

; Read user input and store in 'buffer'
read:
  mov eax, 3             ; sys_read
  mov ebx, 0             ; file descriptor (stdin)
  mov ecx, buffer        ; destination buffer
  mov edx, max_bytes     ; max bytes to read
  int 0x80               ; syscall

  cmp eax, 0             ; compare eax with 0
  je exit                ; if eax = 0, no character was read by sys_read. Jump to exit
  mov esi, eax           ; else, store in esi the number of bytes read

  dec esi                ; decrement esi to prevent 'off by one' errors
  mov [bytes_read], eax  ; do the same as 'mov esi, eax', but store eax in memory to use later in sys_write
  mov ebp, buffer        ; ebp points to first character in 'buffer'

; iterate over each byte stored in 'buffer' and verify if it is uppercase or lowercase
scan:
  mov al, [ebp + esi]    ; store in eax the byte stored in [ebp + esi]
  cmp al, 0x61           ; compare al to 0x61 ('a' in ascii)
  jb next                ; if al is below 0x61, it isn't a lowercase character, so jump to next
  cmp al, 0x7A           ; else if, compare al to 0x7A ('z' in ascii)
  ja next                ; if al is above 0x7A, it isn't a lowercase character, so jump to next

  sub byte [ebp + esi], 0x20 ; else, al is a lowercase character, so subtract 0x20 to make it uppercase

; points to the next character in 'buffer'. Actually, the scan goes from the higher byte to lower
next:
  dec esi                ; decrement esi
  jns scan               ; jump to scan if 'dec esi' didn't set SF to 1, that is, esi is still positive (or 0), thus there are more bytes to scan

; write the buffer to stdout, but with all characters in uppercase
write:
  mov eax, 4             ; sys_write
  mov ebx, 1             ; file descriptor (stdout)
  mov ecx, ebp           ; 'buffer' address
  mov edx, [bytes_read]  ; number of bytes to write
  int 0x80               ; syscall
  jmp read               ; read more bytes from stdin

; exit the program correctly
exit:
  mov eax, 1             ; sys_exit
  xor ebx, ebx           ; zeroing ebx
  int 0x80               ; syscall