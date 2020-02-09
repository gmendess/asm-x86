%include 'linked_list.asm'

section .data
  fmt: db "%d", 0xa, 0

section .text
  extern printf
  global main

main:
  push ebp
  mov ebp, esp

  push 112233
  call create_node
  add esp, 4

  push dword [eax + node.value]
  push fmt
  call printf
  add esp, 8

  mov esp, ebp
  pop ebp
  ret