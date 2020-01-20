; Converts a 32-bit number to string, so it can be printed by sys_write
;
; nasm -f elf32 int32_to_string.asm
; ld -m elf_i386 int32_to_string.o -o int32_to_string
; $ ./int32_to_string
; 
; The program works that way:
;   * number = 12345 (i'm using 12345 as an example)
;   * buffer = array of 11 bytes (that means the number can have up to 10 digits + '\n' included at the end)
;   * Parse each digit by dividing 'number' by 10.
;   * Sums the current digit with 0x30 to create the ascii form of the digit. 0x5 + 0x30 = 0x35 (or the character '5')
;   * After creating the ascii form of the digit, push it into the stack, so the first digit (from rigth to left) will be at the top
;     of the stack, while the last digit will be at the bottom. in the end, the stack will be [top]'1', '2', '3', '4', '5'[bottom]
;   * If number > 0 divide 'number' by 10 and do all the process again
;   * Else, all digits has been parsed, so it's time to make the string
;   * For that, pop each character from the stack and store at a location in 'buffer'
;   * In the and, the characters will be in the correct sequence inside 'buffer'
;
; I believe this code is not so fast, because it uses the stack. If i think in a better way to do that, i'll update it :)

section .data
  ; >>>>>>>>>> (EDIT HERE FOR OTHER NUMBERS) <<<<<<<<<<<<<
  number: equ 478492981    ; number to be converted to string

section .bss
  buffer: resb 11          ; reserve 11 bytes in memory to buffer that will contain the number in string format

section .text
  global _start

_start:
  nop                      ; for debugging reasons
  mov esi, buffer          ; save buffer's address in esi
  mov ebp, esp             ; save esp in edp

  mov eax, number          ; dividend
  mov ebx, 10              ; divisor
loop:
  xor edx, edx             ; zoroing edx to prevent integer overflow
  div ebx                  ; dividing eax by ebx

  ; edx store the rest of division, so after '12345 / 10', eax = 1234 and edx = 5
  add edx, 0x30            ; sum the rest with 0x30. Example: 0x5 + 0x30 = 0x35 (character 5)
  push dx                  ; push the character onto the stack. Actually i'm pushing 2 bytes, including the character
  
  cmp eax, 0               ; verify if has no more digits to parse
  je make_string           ; if no, then jump to make_string

  inc esi                  ; else, increment esi to point to the next character and
  jmp loop                 ; jump to loop to do the process again

; pop all the characters from the stack into the buffer
make_string:
  pop word [buffer + ecx]  ; pop a character(actually 2 bytes) from the stack
  inc ecx                  ; increment ecx to calculate string's length and next offset in buffer
  cmp ebp, esp             ; compare ebp with esp
  jne make_string          ; if they aren't equal, there are more characters to be popped from stack

  mov [buffer + ecx], byte 0xA ; '\n'
  inc ecx                      ; increment ecx again to include '\n' in buffer's length

write:
  mov edx, ecx             ; buffer's length
  mov ecx, buffer          ; buffer to be printed
  mov ebx, 1               ; file descriptor (stdout)
  mov eax, 4               ; sys_write
  int 0x80                 ; syscall

exit:
  mov eax, 1               ; sys_exit 
  xor ebx, ebx             ; ebx = 0 (return value)
  int 0x80                 ; syscall
