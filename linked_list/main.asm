; Assemble and link with:
;   $ nasm -f elf32 main.asm
;   $ gcc -m32 main.o -o main
;   $ ./main

%include 'linked_list.asm'

section .bss
  list_head: resb 4

section .data
  fmt_list:       db "The entire list is:", 0
  fmt_node:       db "  - Node value: %d", 0xa, 0
  fmt_last_node:  db "Last node: %d", 0xa, 0
  fmt_prior_node: db "The node prior the last: %d", 0xa, 0
  fmt_pop_value:  db "The value of the popped node is: %d", 0xa, 0

section .text
  extern printf
  extern puts
  global main

main:
  nop             ; debug reasons

  push ebp
  mov ebp, esp

  push 123456
  call add_node   ; pushing first node
  add esp, 4

  push 323232
  call add_node   ; pushing second node
  add esp, 4

  push 999999
  call add_node   ; pushing third node
  add esp, 4

  ; print the entire list
  push fmt_list
  call puts
  add esp, 4

  mov ebx, [list_head]          ; points to first node
  push dword [ebx + node.value]
  push fmt_node
  call printf                   ; print the first node
  add esp, 8

  mov ebx, [ebx + node.next]    ; points to next node (2nd)
  push dword [ebx + node.value]
  push fmt_node
  call printf                   ; print the second node
  add esp, 8

  mov ebx, [ebx + node.next]    ; points to next node (3rd)
  push dword [ebx + node.value]
  push fmt_node
  call printf                   ; print the third node
  add esp, 8

  ; print the last node
  mov ebx, list_head            ; points to first node
  call get_last_node            ; get the last node and store address in ebx
  push dword [ebx + node.value]
  push fmt_last_node
  call printf                   ; print the last node
  add esp, 8

  ; print the node prior the last one
  push dword [edi + node.value]
  push fmt_prior_node
  call printf                   ; print the node prior the last one
  add esp, 8

  call pop_node                 ; pop the last node
  ; print the value of the popped node
  push eax
  push fmt_pop_value
  call printf                   ; print the value of the popped node        
  add esp, 8


  ; print the last node after call pop_node
  mov ebx, list_head            ; points to first node
  call get_last_node            ; get the current last node and store the address in ebx
  push dword [ebx + node.value]
  push fmt_last_node            ; print the last node
  call printf
  add esp, 8

  mov esp, ebp
  pop ebp
  ret