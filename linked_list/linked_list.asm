extern malloc

struc node
  .value: resb 4
  .next:  resb 4
endstruc

; Function that creates a struct node on heap and return a pointer to the region allocated
; @prototype:
;   struct node* create_node(int value);
;
; @return:
;   return the pointer in 'eax'    
create_node:
  push ebp        ; save ebp onto the stack
  mov ebp, esp    ; ebp points to the top of the stack, creating a stack frame
  push ebx        ; save caller's ebx 

  mov ebx, [ebp + 8] ; move to ebx the argument passed to the function

  push node_size  ; push argument to malloc
  call malloc     ; alloc 'node_size' bytes on the heap (return in eax)
  add esp, 4      ; clear the stack

  mov [eax + node.value], ebx     ; initialize node.value with ebx
  mov dword [eax + node.next], 0  ; node.next = null pointer

  mov esp, ebp    ; esp points to the old top of the stack, saved in ebp
  pop ebp         ; pop the old ebp value into ebp, destroying the stack frame

  ret             ; return to caller