; Assemble and link with:
;   $ nasm -f elf32 main.asm
;   $ gcc -m32 main.o -o main
;   $ ./main

%include 'linked_list.asm'

section .bss
  list_head: resb 4

section .data
  fmt: db "Node value: %d", 0xa, 0

section .text
  extern printf
  global main

main:
  nop             ; debug reasons

  push ebp
  mov ebp, esp

  push 123456
  call add_node
  add esp, 4

  push 323232
  call add_node
  add esp, 4

  push 999999
  call add_node
  add esp, 4

  mov ebx, [list_head] ; points to first node
  push dword [ebx + node.value]
  push fmt
  call printf
  add esp, 8

  mov ebx, [ebx + node.next] ; points to next node (2nd)
  push dword [ebx + node.value]
  push fmt
  call printf
  add esp, 8

  mov ebx, [ebx + node.next] ; points to next node (3rd)
  push dword [ebx + node.value]
  push fmt
  call printf
  add esp, 8

  mov esp, ebp
  pop ebp
  ret