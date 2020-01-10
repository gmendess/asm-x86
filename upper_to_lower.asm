section .data
      palavra: db "GABRIEL", 0xA
      tamanho: equ $ - palavra ; tamanho da minha palavra (inclui '\n')

section .text
      global _start

_start:
      mov ebx, palavra     ; endereço de 'palavra' é atribuído à ebx
      mov eax, tamanho - 1 ; uso o eax como acumulador para armazenar o tamanho da palavra - 1

loop: add byte [ebx], 32   ; somo o caractere contido no endereço apontado por bx (byte [ebx]) com o número 32
      inc ebx              ; incremento ebx (passa a apontar para o próximo caractere)
      dec eax              ; decremento eax
      jnz loop             ; jump para o label 'loop' caso a última operação (dec eax) resulte em 0

      mov eax, 4           ; sys_write
      mov ebx, 1           ; file descriptor 1 (stdout)
      mov ecx, palavra
      mov edx, tamanho
      int 0x80             ; kernel call

      mov eax, 1           ; sys_exit
      xor ebx, ebx         ; zero o conteúdo em ebx (xor de um número por ele mesmo = 0)
      int 0x80             ; kernel call
