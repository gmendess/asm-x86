extern malloc

struc node
  .value: resb 4
  .next:  resb 4
endstruc

; Function that creates a struct node on heap and return a pointer to the region allocated
; @prototype:
;   struct node* create_node(int value)
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


; Function that appends a node in the list
; @prototype:
;   void add_node(int value);
add_node:
  push ebp      ; save ebp onto the stack
  mov ebp, esp  ; ebp points to the top of the stack, creating a stack frame
  push ebx      ; save caller's ebx

  push dword [ebp + 8] ; pass to create_node the parameter 'value' passed to add_node
  call create_node     ; alloc memory to a node and initialize the member .value (return pointer in eax)
  add esp, 4           ; clean up the list

  mov ebx, list_head   ; copy to ebx the address of list_head
  test dword [ebx], 0xFFFFFFFF ; check if ebx is a null pointer (all 32 bits = 0)
  jnz .last_node       ; if no, the list is not empty, so call get_last_node

  mov [ebx], eax       ; list_head points to eax (first node)
  jmp .return_now      ; return to caller

.last_node:
  call get_last_node   ; iterate the list to get the last node (return pointer in ebx)

  mov [ebx + node.next], eax  ; last node .next member points to the new node

.return_now:
  pop ebx         ; restore caller's ebx
  mov esp, ebp    ; esp points to the old top of the stack, saved in ebp
  pop ebp         ; pop the old ebp value into ebp, destroying the stack frame

  ret             ; return to caller

; Function that gets the last node in a list
; @prototype:
;   struct node* get_last_node(void)
;   struct node* -´
; @return:
;   return the last node in ebx
;   return previews node in edx
get_last_node:
  push ebp
  mov ebp, esp

  xor edx, edx
.iterate_list:
  mov ebx, [ebx]    ; ebx stores the address of the current node
  test dword [ebx + node.next], 0xFFFFFFFF ; check if the next node is a null pointer
  jz .return_now    ; if yes, we reached the last node, so it's .next member must point to eax
  mov edx, ebx      ; save the node address in edx
  add ebx, 4        ; now ebx is the pointer to the next node
  jmp .iterate_list ; jump again to .iterate_list to check if the current node is the last one

.return_now:
  mov esp, ebp
  pop ebp
  ret