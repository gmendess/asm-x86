; Write on stdout all the command-line arguments passed to the program
; The number of arguments that can be printed is defined by MAX_ARGS, which has 
; 10 as default value. Change it if you want to print more than 10 arguments!

; nasm -f elf32 show_args.asm
; ld -m elf_i386 show_args.o -o show_args
; ./show_args [ARG1] [ARG2] [ARG3] ...

section .data
  MAX_ARGS: equ 10 ; max number of arguments the program supports

section .rodata
  show_args_msg:       db "The arguments are:", 0xA, 0xA
  show_args_len:       equ $ - show_args_msg

  err_max_args_msg:    db "Number of arguments exceeds MAX_ARGS", 0x0A
  err_max_args_len:    equ $ - err_max_args_msg

  err_invalid_str_msg: db "The string is in an invalid format. Must be up to 0xFFFF bytes long and end with byte 0", 0x0A
  err_invalid_str_len: equ $ - err_invalid_str_msg

section .bss
  argc:     resd 1         ; number of arguments passed to the program
  argv:     resd MAX_ARGS  ; array that stores pointers to the arguments strings
  argv_len: resd MAX_ARGS  ; array that stores the length of each argument string

section .text
  global _start

; macro that encapsulate the sys_write call 
; Basically print on stdout the string pointed by %1 with %2 bytes in length
%macro write 2
  push eax
  push ebx
  push ecx
  push edx

  mov eax, 4  ; sys_write
  mov ebx, 1  ; stdout
  mov ecx, %1 ; string pointer
  mov edx, %2 ; string length
  int 0x80

  pop edx
  pop ecx
  pop ebx
  pop eax
%endmacro

_start:
  nop

  pop ecx                   ; pop in ecx the number of arguments passed to the program
  cmp ecx, MAX_ARGS         ; check if ecx is greater than MAX_ARGS
  ja error_max_args         ; if so, number of arguments exceeded, jump to error message

  mov [argc], ecx           ; copy to argc the number of arguments popped in ecx
  xor edx, edx              ; edx = 0

load_argv:
  pop dword [argv + edx * 4]; load in the position argv[edx] the address of the argument string
  inc edx                   ; increment counter
  cmp edx, ecx              ; edx < ecx
  jb load_argv              ; if so, jump again to load_argv

  xor edx, edx              ; edx = 0 (reset edx to use as a counter)
  xor eax, eax              ; eax = 0 (byte to search in the string)

load_argv_len:
  mov ecx, 0x0000FFFF       ; max bytes to be scanned in the string
  mov edi, [argv + edx * 4] ; store in edi the address of the string to be scanned
  mov ebp, edi              ; save in ebp the same address

  repne scasb               ; iterate ecx times over edi while the current byte is different than 0x00 (byte store in eax)
  jne error_invalid_str     ; if no 0x00 was found, the string is invalid, jump to error message

  mov byte [edi - 1], 0x0A  ; replace 0x00 with 0x0A
  sub edi, ebp              ; calculate the string's length
  mov [argv_len+edx*4], edi ; store in argv_len[edx] the string's length pointed by argv[edx]
  inc edx                   ; increment edx
  cmp edx, [argc]           ; edx < argc
  jb load_argv_len          ; if so, jump again to load_argv_len

  xor edx, edx              ; edx = 0
  write show_args_msg, show_args_len

; write all the arguments passed to the program
write_args:
  write [argv + edx * 4], [argv_len + edx * 4]
  inc edx
  cmp edx, [argc]           ; edx < argc
  jb write_args             ; if so, jump again to load_argv_len
  jmp exit                  ; if there are no more args to print, jump to exit

error_max_args:
  write err_max_args_msg, err_max_args_len
  jmp exit

error_invalid_str:
  write err_invalid_str_msg, err_invalid_str_len
  jmp exit

exit:
  mov eax, 1
  xor ebx, ebx
  int 0x80