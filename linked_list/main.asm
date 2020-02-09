section .data
  struc node
    .value: resb 4
    .next:  resb 4
  endstruc

section .text
  extern printf
  extern malloc
  global main

main:
  push ebp
  mov ebp, esp

  mov esp, ebp
  pop ebp
  ret